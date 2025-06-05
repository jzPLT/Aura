import { auth } from '@/lib/firebase/admin';
import { withTransaction } from '@/lib/db';
import { UserService } from './service';
import { UserData } from './types';

export class UserTransactionService {
  /**
   * Atomically create user in both Firebase Auth and database
   * Firebase is created first to get the UID, then database. If database fails, Firebase is cleaned up.
   */
  static async createUserAtomic(
    email: string,
    password: string,
    userData: Omit<UserData, 'uid' | 'email' | 'createdAt' | 'updatedAt'>
  ): Promise<UserData> {
    let firebaseUser: any = null;
    
    try {
      // First, create user in Firebase Auth (we need the UID for the database)
      console.log('🔐 Creating Firebase Auth user...');
      firebaseUser = await auth.createUser({
        email,
        password,
        displayName: userData.displayName,
      });

      console.log(`✅ Firebase user created: ${firebaseUser.uid}`);

      // Then, create user in database within a transaction
      const dbUser = await withTransaction(async (client) => {
        const fullUserData = {
          uid: firebaseUser.uid,
          email: firebaseUser.email || email,
          ...userData,
        };

        return await UserService.createUser(fullUserData);
      });

      console.log(`✅ Database user created: ${dbUser.uid}`);
      return dbUser;

    } catch (error) {
      console.error('❌ User creation failed:', error);
      
      // If database operation failed but Firebase user was created, clean up Firebase
      if (firebaseUser) {
        try {
          console.log('🧹 Cleaning up Firebase user due to database failure...');
          await auth.deleteUser(firebaseUser.uid);
          console.log('✅ Firebase user cleanup successful');
        } catch (cleanupError) {
          console.error('❌ Failed to cleanup Firebase user:', cleanupError);
          // This is a critical error - we have an orphaned Firebase user
          throw new Error(
            `Critical: User created in Firebase (${firebaseUser.uid}) but database creation failed and cleanup failed. Manual intervention required.`
          );
        }
      }
      
      throw error;
    }
  }

  /**
   * Atomically delete user from both database and Firebase Auth
   * Database is deleted first, then Firebase. If Firebase fails, we can recreate the user.
   */
  static async deleteUserAtomic(uid: string): Promise<void> {
    let userBackup: UserData | null = null;
    
    try {
      // First, get user data for potential rollback
      console.log(`📋 Backing up user data for: ${uid}`);
      userBackup = await UserService.getUserByUid(uid);
      if (!userBackup) {
        throw new Error(`User not found: ${uid}`);
      }

      // Delete from database within a transaction
      console.log(`🗑️ Deleting user from database: ${uid}`);
      await withTransaction(async (client) => {
        await UserService.deleteUser(uid);
      });
      console.log(`✅ Database user deleted: ${uid}`);

      // Then, delete from Firebase Auth
      console.log(`🔐 Deleting Firebase Auth user: ${uid}`);
      await auth.deleteUser(uid);
      console.log(`✅ Firebase user deleted: ${uid}`);

    } catch (error) {
      console.error('❌ User deletion failed:', error);
      
      // If Firebase deletion failed but database deletion succeeded, restore database user
      if (userBackup && error instanceof Error && error.message.includes('Firebase')) {
        try {
          console.log('🔄 Rolling back database deletion due to Firebase failure...');
          await withTransaction(async (client) => {
            await UserService.createUser({
              uid: userBackup!.uid,
              email: userBackup!.email,
              displayName: userBackup!.displayName,
              preferencesTheme: userBackup!.preferencesTheme,
              preferencesNotifications: userBackup!.preferencesNotifications,
              defaultDurationForScheduling: userBackup!.defaultDurationForScheduling,
            });
          });
          console.log('✅ Database rollback successful');
        } catch (rollbackError) {
          console.error('❌ Failed to rollback database deletion:', rollbackError);
          throw new Error(
            `Critical: User deleted from database (${uid}) but Firebase deletion failed and rollback failed. Manual intervention required.`
          );
        }
      }
      
      throw error;
    }
  }

  /**
   * Atomically update user in both database and Firebase Auth
   * Database is updated first, then Firebase. If Firebase fails, database can be rolled back.
   */
  static async updateUserAtomic(
    uid: string,
    updates: {
      email?: string;
      displayName?: string;
      password?: string;
      dbUpdates?: Partial<Omit<UserData, 'uid' | 'createdAt' | 'updatedAt'>>;
    }
  ): Promise<UserData> {
    let originalDbData: UserData | null = null;
    let dbUpdated = false;
    
    try {
      // Get original database data for potential rollback
      console.log(`📋 Backing up database data for: ${uid}`);
      originalDbData = await UserService.getUserByUid(uid);
      if (!originalDbData) {
        throw new Error(`User not found: ${uid}`);
      }

      // First, update database within a transaction
      console.log(`🗑️ Updating database user: ${uid}`);
      const dbUpdatesData = {
        ...updates.dbUpdates,
        ...(updates.email && { email: updates.email }),
        ...(updates.displayName && { displayName: updates.displayName }),
      };
      
      const dbUser = await withTransaction(async (client) => {
        return await UserService.updateUser(uid, dbUpdatesData);
      });
      
      dbUpdated = true;
      console.log(`✅ Database user updated: ${uid}`);

      // Then, update Firebase Auth user if needed
      if (updates.email || updates.displayName || updates.password) {
        console.log(`🔐 Updating Firebase Auth user: ${uid}`);
        const firebaseUpdates: any = {};
        if (updates.email) firebaseUpdates.email = updates.email;
        if (updates.displayName) firebaseUpdates.displayName = updates.displayName;
        if (updates.password) firebaseUpdates.password = updates.password;
        
        await auth.updateUser(uid, firebaseUpdates);
        console.log(`✅ Firebase user updated: ${uid}`);
      }

      return dbUser;

    } catch (error) {
      console.error('❌ User update failed:', error);
      
      // If Firebase update failed but database was updated, rollback database
      if (dbUpdated && originalDbData) {
        try {
          console.log('🔄 Rolling back database update due to Firebase failure...');
          await withTransaction(async (client) => {
            return await UserService.updateUser(uid, {
              email: originalDbData!.email,
              displayName: originalDbData!.displayName,
              preferencesTheme: originalDbData!.preferencesTheme,
              preferencesNotifications: originalDbData!.preferencesNotifications,
              defaultDurationForScheduling: originalDbData!.defaultDurationForScheduling,
            });
          });
          console.log('✅ Database rollback successful');
        } catch (rollbackError) {
          console.error('❌ Failed to rollback database update:', rollbackError);
          throw new Error(
            `Critical: Database updated (${uid}) but Firebase update failed and rollback failed. Manual intervention required.`
          );
        }
      }
      
      throw error;
    }
  }

  /**
   * Health check to verify both Firebase and database connections
   */
  static async healthCheck(): Promise<{ firebase: boolean; database: boolean }> {
    const results = { firebase: false, database: false };
    
    try {
      // Test Firebase connection
      await auth.listUsers(1);
      results.firebase = true;
    } catch (error) {
      console.error('Firebase health check failed:', error);
    }
    
    try {
      // Test database connection
      const { pool } = await import('@/lib/db');
      const client = await pool.connect();
      await client.query('SELECT 1');
      client.release();
      results.database = true;
    } catch (error) {
      console.error('Database health check failed:', error);
    }
    
    return results;
  }
}