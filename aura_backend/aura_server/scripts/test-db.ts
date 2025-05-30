#!/usr/bin/env tsx
import { config } from 'dotenv';
import pool, { executeQuery } from '../src/lib/db/pool';

// Load environment variables
config();

async function testConnection() {
  try {
    console.log('Testing database connection...');
    
    // Test basic connection
    const result = await executeQuery('SELECT NOW() as current_time');
    console.log('✅ Database connection successful!');
    console.log('Current time from database:', result[0]?.current_time);
    
    // Test if tables exist
    const tables = await executeQuery(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('users', 'static_entries', 'dynamic_entries', 'resulting_entries')
    `);
    
    console.log('\n📋 Existing tables:');
    if (tables.length === 0) {
      console.log('No tables found. Please run migrations first.');
    } else {
      tables.forEach((table: any) => {
        console.log(`  - ${table.table_name}`);
      });
    }
    
    await pool.end();
    console.log('\n✅ Test completed successfully!');
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    console.error('\nPlease check your .env file and ensure PostgreSQL is running.');
    process.exit(1);
  }
}

testConnection();
