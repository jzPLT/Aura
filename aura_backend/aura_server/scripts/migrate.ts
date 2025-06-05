import dotenv from 'dotenv';
import path from 'path';
import { runMigrations } from '../src/lib/db/migrations';

// Load environment variables from .env file
dotenv.config({ path: path.join(process.cwd(), '.env') });

async function main() {
  try {
    await runMigrations();
    process.exit(0);
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  }
}

main();
