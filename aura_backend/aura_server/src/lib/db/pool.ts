import { Pool, PoolConfig, Client, PoolClient, QueryConfig, QueryResult, QueryResultRow  } from 'pg';

const config: PoolConfig = {
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  host: process.env.POSTGRES_HOST,
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  database: process.env.POSTGRES_DB,
  max: parseInt(process.env.POSTGRES_MAX_CONNECTIONS || '20'),
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
};

// Create a new Pool instance
const pool = new Pool(config);

pool.on('connect', (client: PoolClient) => {
  console.log('Client connected to the database');
});

pool.on('remove', (client: PoolClient) => {
  console.log('Client removed from the database pool');
});

pool.on('error', (err: Error, client: PoolClient) => {
  console.error('Unexpected error on idle client', err);
  // process.exit(-1); // Don't exit process in Next.js API routes, handle gracefully
});

// Function to get a client from the pool
export async function getClient(): Promise<PoolClient> {
  const client = await pool.connect();
  
  // Store reference to original methods with proper binding
  const originalQuery = client.query.bind(client);
  const originalRelease = client.release.bind(client);

  // Simple wrapper that preserves all query method signatures
  const wrappedQuery = async (...args: Parameters<typeof originalQuery>) => {
    try {
      // Log query for debugging
      const queryText = typeof args[0] === 'string' 
        ? args[0] 
        : (args[0] as any)?.text || 'Complex Query';
      console.log('Executing query:', queryText.slice(0, 100) + (queryText.length > 100 ? '...' : ''));
      
      // Call original query with all arguments and await the result
      const result = await originalQuery(...args);
      return result;
    } catch (error: any) {
      console.error('Error executing query:', error);
      throw error;
    }
  };

  // Replace the query method
  client.query = wrappedQuery as any;

  // Wrapper for release method
  client.release = (err?: Error | boolean) => {
    if (err) {
      console.log('Releasing client due to error:', err);
    }
    originalRelease(err);
  };

  return client;
}

// Function to execute a query using a pooled connection
export async function executeQuery<T>(
  queryText: string,
  params?: any[]
): Promise<T[]> {
  const client = await getClient();
  try {
    const result = await client.query(queryText, params); // This query() is now the wrapped one
    return result.rows;
  } finally {
    client.release();
  }
}

// Add to pool.ts
export async function closePool(): Promise<void> {
  await pool.end();
  console.log('Database pool closed');
}

// Handle process termination
process.on('SIGINT', async () => {
  await closePool();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  await closePool();
  process.exit(0);
});

// Export the pool instance for direct use when needed
export default pool;
