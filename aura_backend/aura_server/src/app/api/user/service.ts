import { executeQuery } from '@/lib/db/pool';
import { UserData, UserDbRow } from './types';
import pool from '@/lib/db/pool';
import { validateUserData, transformUserDbRowToUserData } from './transformers';

export class UserService {
  /**
   * Get user by Firebase UID
   */
  static async getUserByUid(uid: string): Promise<UserData | null> {
    try {
      const query = `
        SELECT 
          uid,
          email,
          display_name,
          preferences_theme,
          preferences_notifications,
          schedule_settings_default_duration as default_duration_for_scheduling,
          created_at,
          updated_at
        FROM users 
        WHERE uid = $1
      `;
      
      const rows = await executeQuery<UserDbRow>(query, [uid]);
      
      if (rows.length === 0) {
        return null;
      }
      
      return transformUserDbRowToUserData(rows[0]);
    } catch (error) {
      console.error('Error fetching user by UID:', error);
      throw new Error('Failed to fetch user data');
    }
  }

  /**
   * Create a new user
   */
  static async createUser(userData: Omit<UserData, 'createdAt' | 'updatedAt'>): Promise<UserData> {
    try {
      console.log(`🔍 [UserService.createUser] Creating user for UID: ${userData.uid}`);
      // Validate the user data
      const validatedData = validateUserData(userData);
      
      const query = `
        INSERT INTO users (
          uid,
          email,
          display_name,
          preferences_theme,
          preferences_notifications,
          schedule_settings_default_duration,
          created_at,
          updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        RETURNING 
          uid,
          email,
          display_name,
          preferences_theme,
          preferences_notifications,
          schedule_settings_default_duration as default_duration_for_scheduling,
          created_at,
          updated_at
      `;
      
      const values = [
        validatedData.uid,
        validatedData.email,
        validatedData.displayName,
        validatedData.preferencesTheme,
        validatedData.preferencesNotifications,
        validatedData.defaultDurationForScheduling,
      ];
      
      const rows = await executeQuery<UserDbRow>(query, values);
      
      if (rows.length === 0) {
        throw new Error('User creation failed - no data returned');
      }
      
      console.log(`✅ [UserService.createUser] User created successfully for UID: ${validatedData.uid}`);
      return transformUserDbRowToUserData(rows[0]);
    } catch (error) {
      console.error('Error creating user:', error);
      throw new Error('Failed to create user');
    }
  }

  /**
   * Update an existing user
   */
  static async updateUser(uid: string, updates: Partial<Omit<UserData, 'uid' | 'createdAt' | 'updatedAt'>>): Promise<UserData> {
    try {
      // Build the update query dynamically based on provided fields
      const updateFields: string[] = [];
      const values: any[] = [];
      let paramIndex = 1;

      if (updates.email !== undefined) {
        updateFields.push(`email = $${paramIndex++}`);
        values.push(updates.email);
      }
      
      if (updates.displayName !== undefined) {
        updateFields.push(`display_name = $${paramIndex++}`);
        values.push(updates.displayName);
      }
      
      if (updates.preferencesTheme !== undefined) {
        updateFields.push(`preferences_theme = $${paramIndex++}`);
        values.push(updates.preferencesTheme);
      }
      
      if (updates.preferencesNotifications !== undefined) {
        updateFields.push(`preferences_notifications = $${paramIndex++}`);
        values.push(updates.preferencesNotifications);
      }
      
      if (updates.defaultDurationForScheduling !== undefined) {
        updateFields.push(`schedule_settings_default_duration = $${paramIndex++}`);
        values.push(updates.defaultDurationForScheduling);
      }

      if (updateFields.length === 0) {
        // No fields to update, just return the current user
        const currentUser = await this.getUserByUid(uid);
        if (!currentUser) {
          throw new Error('User not found');
        }
        return currentUser;
      }

      // Always update the updated_at timestamp
      updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
      
      // Add the UID parameter at the end
      values.push(uid);
      
      const query = `
        UPDATE users 
        SET ${updateFields.join(', ')}
        WHERE uid = $${paramIndex}
        RETURNING 
          uid,
          email,
          display_name,
          preferences_theme,
          preferences_notifications,
          schedule_settings_default_duration as default_duration_for_scheduling,
          created_at,
          updated_at
      `;
      
      const rows = await executeQuery<UserDbRow>(query, values);
      
      if (rows.length === 0) {
        throw new Error('User not found or update failed');
      }
      
      return transformUserDbRowToUserData(rows[0]);
    } catch (error) {
      console.error('Error updating user:', error);
      throw new Error('Failed to update user');
    }
  }

  /**
   * Create or update user (upsert functionality)
   * This is useful for the sign-up flow where we want to create a user if they don't exist
   * or update them if they do
   */
  static async upsertUser(userData: Omit<UserData, 'createdAt' | 'updatedAt'>): Promise<UserData> {
    try {
      // Validate the user data
      const validatedData = validateUserData(userData);
      
      const query = `
        INSERT INTO users (
          uid,
          email,
          display_name,
          preferences_theme,
          preferences_notifications,
          schedule_settings_default_duration,
          created_at,
          updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT (uid) 
        DO UPDATE SET
          email = EXCLUDED.email,
          display_name = EXCLUDED.display_name,
          preferences_theme = EXCLUDED.preferences_theme,
          preferences_notifications = EXCLUDED.preferences_notifications,
          schedule_settings_default_duration = EXCLUDED.schedule_settings_default_duration,
          updated_at = CURRENT_TIMESTAMP
        RETURNING 
          uid,
          email,
          display_name,
          preferences_theme,
          preferences_notifications,
          schedule_settings_default_duration as default_duration_for_scheduling,
          created_at,
          updated_at
      `;
      
      const values = [
        validatedData.uid,
        validatedData.email,
        validatedData.displayName,
        validatedData.preferencesTheme,
        validatedData.preferencesNotifications,
        validatedData.defaultDurationForScheduling,
      ];
      
      const rows = await executeQuery<UserDbRow>(query, values);
      
      if (rows.length === 0) {
        throw new Error('User upsert failed - no data returned');
      }
      
      return transformUserDbRowToUserData(rows[0]);
    } catch (error) {
      console.error('Error upserting user:', error);
      throw new Error('Failed to create or update user');
    }
  }

  /**
   * Check if user exists
   */
  static async userExists(uid: string): Promise<boolean> {
    try {
      console.log(`🔍 [UserService.userExists] Checking existence for UID: ${uid}`);
      const query = 'SELECT 1 FROM users WHERE uid = $1 LIMIT 1';
      const rows = await executeQuery(query, [uid]);
      const exists = rows.length > 0;
      console.log(`🔍 [UserService.userExists] User exists: ${exists}`);
      return exists;
    } catch (error) {
      console.error('Error checking if user exists:', error);
      throw new Error('Failed to check user existence');
    }
  }

  /**
   * Hard delete a user by removing them from the database
   */
  static async deleteUser(uid: string): Promise<void> {
    try {
      console.log(`🗑️ [UserService.deleteUser] Attempting to delete user UID: ${uid}`);
      
      // First, check if the user exists
      const existingUserQuery = `
        SELECT uid FROM users WHERE uid = $1
      `;
      const existingUserRows = await executeQuery<{ uid: string }>(existingUserQuery, [uid]);

      if (existingUserRows.length === 0) {
        console.warn(`⚠️ [UserService.deleteUser] User not found for UID: ${uid}`);
        throw new Error('User not found');
      }

      // If user exists, proceed with hard deletion
      const query = `
        DELETE FROM users 
        WHERE uid = $1
        RETURNING uid
      `;
      
      const rows = await executeQuery<{ uid: string }>(query, [uid]);
      
      if (rows.length === 0) {
        console.error(`❌ [UserService.deleteUser] Failed to delete user for UID: ${uid}`);
        throw new Error('User deletion failed');
      }
      
      console.log(`✅ [UserService.deleteUser] User deleted successfully for UID: ${uid}`);
    } catch (error) {
      console.error(`❌ [UserService.deleteUser] Error deleting user for UID ${uid}:`, error);
      if (error instanceof Error && error.message.includes('User not found')) {
        throw error; // Re-throw specific errors for the route handler
      }
      throw new Error('Failed to delete user');
    }
  }

  /**
   * Upsert user on login
   * Handles user creation and updates considering potential conflicts.
   */
  static async upsertUserOnLogin(uid: string, email: string, displayName: string | null): Promise<UserDbRow> {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const { rows: emailMatchRows } = await client.query<UserDbRow>(
        `SELECT * FROM users WHERE email = $1`,
        [email]
      );
      const existingUserByEmail = emailMatchRows[0] || null;

      const { rows: uidMatchRows } = await client.query<UserDbRow>(
        `SELECT * FROM users WHERE uid = $1`,
        [uid]
      );
      const existingUserByUid = uidMatchRows[0] || null;

      let userToReturn: UserDbRow;

      if (existingUserByEmail) {
        // Email exists in database
        if (existingUserByEmail.uid === uid) {
          // Case A: Email exists and UID matches. Standard update.
          const { rows: updatedRows } = await client.query<UserDbRow>(
            `UPDATE users SET display_name = $1, updated_at = NOW()
             WHERE uid = $2 AND email = $3 RETURNING *`,
            [displayName, uid, email]
          );
          if (updatedRows.length === 0) {
            await client.query('ROLLBACK');
            throw new Error('Failed to update active user details.');
          }
          userToReturn = updatedRows[0];
        } else {
          // Case B: Email exists but UID is different. Conflict.
          await client.query('ROLLBACK');
          throw new Error('Email_Conflict: Email is already in use by another account.');
        }
      } else {
        // Email does not exist in database
        if (existingUserByUid) {
          // Case C: Email does not exist, but UID exists.
          // User exists with this UID but with a different email; update to new email.
          const { rows: updatedRows } = await client.query<UserDbRow>(
            `UPDATE users SET email = $1, display_name = $2, updated_at = NOW()
             WHERE uid = $3 RETURNING *`,
            [email, displayName, uid]
          );
          if (updatedRows.length === 0) {
            await client.query('ROLLBACK');
            throw new Error('Failed to update email for existing user.');
          }
          userToReturn = updatedRows[0];
        } else {
          // Case D: Email does not exist, UID does not exist. Clean new user creation.
          const scheduleSettingsDefaultDuration = 30; // Default value
          const { rows: createdRows } = await client.query<UserDbRow>(
            `INSERT INTO users (uid, email, display_name, schedule_settings_default_duration)
             VALUES ($1, $2, $3, $4)
             RETURNING *`,
            [uid, email, displayName, scheduleSettingsDefaultDuration]
          );
          if (createdRows.length === 0) {
            await client.query('ROLLBACK');
            throw new Error('Failed to create new user.');
          }
          userToReturn = createdRows[0];
        }
      }

      await client.query('COMMIT');
      return userToReturn;

    } catch (error) {
      await client.query('ROLLBACK');
      // Log the error for debugging
      console.error('Error in upsertUserOnLogin:', error);
      if (error instanceof Error) {
        if (error.message.includes('users_email_key')) {
          throw new Error('Email_Conflict: This email address is already registered.');
        }
        if (error.message.includes('users_uid_key')) {
          throw new Error('UID_Conflict: This user identifier is already registered with a different email.');
        }
        // Re-throw specific errors caught in the logic
        if (error.message.startsWith('Email_Conflict:') || error.message.startsWith('UID_Conflict:')) {
          throw error;
        }
      }
      // Fallback for other errors
      throw new Error('An unexpected error occurred during user processing.');
    } finally {
      client.release();
    }
  }
}
