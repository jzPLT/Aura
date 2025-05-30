import { PoolClient } from 'pg';
import pool, { executeQuery, getClient } from './pool';

export class DatabaseError extends Error {
  constructor(message: string, public originalError?: any) {
    super(message);
    this.name = 'DatabaseError';
  }
}

export async function withTransaction<T>(
  callback: (client: PoolClient) => Promise<T>
): Promise<T> {
  const client = await getClient();
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw new DatabaseError('Transaction failed', error);
  } finally {
    client.release();
  }
}

export async function healthCheck(): Promise<boolean> {
  try {
    await executeQuery('SELECT 1');
    return true;
  } catch (error) {
    console.error('Database health check failed:', error);
    return false;
  }
}

// Helper function to build WHERE clauses
export function buildWhereClause(
  conditions: Record<string, any>,
  startIndex = 1
): { text: string; values: any[] } {
  const values: any[] = [];
  const clauses: string[] = [];

  Object.entries(conditions).forEach(([key, value], index) => {
    if (value !== undefined && value !== null) {
      clauses.push(`${key} = $${startIndex + index}`);
      values.push(value);
    }
  });

  return {
    text: clauses.length ? ` WHERE ${clauses.join(' AND ')}` : '',
    values,
  };
}

// Helper function to build SET clause for updates
export function buildSetClause(
  updates: Record<string, any>,
  startIndex = 1
): { text: string; values: any[] } {
  const values: any[] = [];
  const clauses: string[] = [];

  Object.entries(updates).forEach(([key, value], index) => {
    if (value !== undefined) {
      clauses.push(`${key} = $${startIndex + index}`);
      values.push(value);
    }
  });

  return {
    text: clauses.join(', '),
    values,
  };
}

export { pool, executeQuery, getClient };
