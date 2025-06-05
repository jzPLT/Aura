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

export { pool, executeQuery, getClient };
