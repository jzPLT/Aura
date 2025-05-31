import { executeQuery, getClient } from '@/lib/db/pool';
import { UserData, UserDbRow } from './types';
import { transformUserDbRowToUserData, validateUserData } from './transformers';

export class UserService {
  /**
   * Get user by Firebase UID
   */
  static async getUserByUid(uid: string): Promise<UserData | null> {
    try {
      const query = `
        SELECT 
          firebase_uid as uid,
          email,
          display_name,
          preferences_theme,
          preferences_notifications,
          schedule_settings_default_duration as default_duration_for_scheduling,
          created_at,
          updated_at
        FROM users 
        WHERE firebase_uid = $1
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
          firebase_uid,
          email,
          display_name,
          preferences_theme,
          preferences_notifications,
          schedule_settings_default_duration,
          created_at,
          updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        RETURNING 
          firebase_uid as uid,
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
        WHERE firebase_uid = $${paramIndex}
        RETURNING 
          firebase_uid as uid,
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
          firebase_uid,
          email,
          display_name,
          preferences_theme,
          preferences_notifications,
          schedule_settings_default_duration,
          created_at,
          updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        ON CONFLICT (firebase_uid) 
        DO UPDATE SET
          email = EXCLUDED.email,
          display_name = EXCLUDED.display_name,
          preferences_theme = EXCLUDED.preferences_theme,
          preferences_notifications = EXCLUDED.preferences_notifications,
          schedule_settings_default_duration = EXCLUDED.schedule_settings_default_duration,
          updated_at = CURRENT_TIMESTAMP
        RETURNING 
          firebase_uid as uid,
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
      const query = 'SELECT 1 FROM users WHERE firebase_uid = $1 LIMIT 1';
      const rows = await executeQuery(query, [uid]);
      const exists = rows.length > 0;
      console.log(`🔍 [UserService.userExists] User exists: ${exists}`);
      return exists;
    } catch (error) {
      console.error('Error checking if user exists:', error);
      throw new Error('Failed to check user existence');
    }
  }
}
