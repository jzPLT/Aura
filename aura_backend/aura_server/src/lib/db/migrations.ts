import { Pool } from 'pg';
import pool from './pool';

const migrations = [
  // Create users table
  `
  CREATE TABLE IF NOT EXISTS users (
    uid VARCHAR(255) PRIMARY KEY, -- Firebase UID
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255) NULL,
    preferences_theme VARCHAR(50) NULL,
    preferences_notifications BOOLEAN NULL,
    schedule_settings_default_duration INTEGER NULL, -- Default duration in minutes
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  );
  `,

  // Create static_entries table
  `
  CREATE TABLE IF NOT EXISTS static_entries (
    id SERIAL PRIMARY KEY,
    user_uid VARCHAR(255) NOT NULL REFERENCES users(uid), -- Link to user
    original_input_text TEXT NULL, -- Original text from LLM, for context
    description VARCHAR(255) NOT NULL,
    starting_datetime TIMESTAMP WITH TIME ZONE NULL, -- Can be NULL if frequency defines only period/duration
    ending_datetime TIMESTAMP WITH TIME ZONE NULL,   -- Can be NULL if frequency defines only period/duration
    frequency_per_period INTEGER NULL, -- e.g., 2 times
    frequency_period VARCHAR(10) NOT NULL DEFAULT 'never', -- 'day', 'week', 'month', 'year', 'never'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  );
  `,

  // Create dynamic_entries table
  `
  CREATE TABLE IF NOT EXISTS dynamic_entries (
    id SERIAL PRIMARY KEY,
    user_uid VARCHAR(255) NOT NULL REFERENCES users(uid), -- Link to user
    original_input_text TEXT NULL, -- Original text from LLM, for context
    description_of_entry VARCHAR(255) NOT NULL,
    starting_datetime TIMESTAMP WITH TIME ZONE NULL, -- Optional preferred start
    ending_datetime TIMESTAMP WITH TIME ZONE NULL,   -- Optional preferred end
    frequency_per_period INTEGER NULL, -- e.g., 2 times (for goals like "run 2 times a week")
    frequency_period VARCHAR(10) NULL, -- 'day', 'week', 'month', 'year' (if it's a recurring goal)
    
    -- Dependency fields (assuming string names for now)
    dependency_name VARCHAR(255) NULL,
    dependency_type VARCHAR(50) NULL, -- 'before', 'after', 'during', 'not_same_day', 'same_day', 'not_same_week', 'same_week', 'not_same_month', 'same_month'
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  );
  `,

  // Create resulting_entries table
  `
  CREATE TABLE IF NOT EXISTS resulting_entries (
    id SERIAL PRIMARY KEY,
    user_uid VARCHAR(255) NOT NULL REFERENCES users(uid), -- Link to user
    
    -- Link to the origin of this scheduled instance (at least one should be NOT NULL)
    origin_static_entry_id INTEGER NULL REFERENCES static_entries(id),
    origin_dynamic_entry_id INTEGER NULL REFERENCES dynamic_entries(id),
    
    description VARCHAR(255) NOT NULL, -- The description of the activity
    starting_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    ending_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Constraint to ensure an origin is linked
    CONSTRAINT chk_origin_link CHECK (origin_static_entry_id IS NOT NULL OR origin_dynamic_entry_id IS NOT NULL)
  );
  `,

  // Create indexes for performance
  `
  CREATE INDEX IF NOT EXISTS idx_static_entries_user_uid ON static_entries (user_uid);
  CREATE INDEX IF NOT EXISTS idx_dynamic_entries_user_uid ON dynamic_entries (user_uid);
  CREATE INDEX IF NOT EXISTS idx_resulting_entries_user_uid ON resulting_entries (user_uid);
  CREATE INDEX IF NOT EXISTS idx_resulting_entries_datetime ON resulting_entries (starting_datetime, ending_datetime);
  `,
];

async function runMigrations() {
  const client = await pool.connect();
  
  try {
    // Create migrations table if it doesn't exist
    await client.query(`
      CREATE TABLE IF NOT EXISTS migrations (
        id SERIAL PRIMARY KEY,
        migration_name VARCHAR(255) NOT NULL,
        executed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Run each migration in a transaction
    for (const [index, migration] of migrations.entries()) {
      const migrationName = `migration_${index + 1}`;
      
      // Check if migration has been run
      const { rows } = await client.query(
        'SELECT id FROM migrations WHERE migration_name = $1',
        [migrationName]
      );

      if (rows.length === 0) {
        try {
          await client.query('BEGIN');
          
          // Run the migration
          await client.query(migration);
          
          // Record the migration
          await client.query(
            'INSERT INTO migrations (migration_name) VALUES ($1)',
            [migrationName]
          );
          
          await client.query('COMMIT');
          console.log(`Successfully executed migration: ${migrationName}`);
        } catch (error) {
          await client.query('ROLLBACK');
          console.error(`Error executing migration ${migrationName}:`, error);
          throw error;
        }
      }
    }
    
    console.log('All migrations completed successfully');
  } finally {
    client.release();
  }
}

export { runMigrations };
