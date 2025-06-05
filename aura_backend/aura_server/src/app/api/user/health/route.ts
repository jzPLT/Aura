import { NextRequest, NextResponse } from 'next/server';
import { UserTransactionService } from '../transaction-service';

/**
 * GET /api/user/health
 * 
 * Health check endpoint to verify both Firebase Auth and database connectivity
 */
export async function GET(request: NextRequest) {
  try {
    console.log('🏥 Running system health check...');
    
    const healthStatus = await UserTransactionService.healthCheck();
    
    const isHealthy = healthStatus.firebase && healthStatus.database;
    const status = isHealthy ? 200 : 503;
    
    const response = {
      success: isHealthy,
      timestamp: new Date().toISOString(),
      services: {
        firebase: {
          status: healthStatus.firebase ? 'healthy' : 'unhealthy',
          connected: healthStatus.firebase,
        },
        database: {
          status: healthStatus.database ? 'healthy' : 'unhealthy',
          connected: healthStatus.database,
        },
      },
      overall: isHealthy ? 'All systems operational' : 'System degraded - some services unavailable',
    };

    console.log(`🏥 Health check completed:`, response);
    
    return NextResponse.json(response, { status });
  } catch (error) {
    console.error('❌ Health check failed:', error);
    
    return NextResponse.json({
      success: false,
      timestamp: new Date().toISOString(),
      error: 'Health check failed',
      message: error instanceof Error ? error.message : 'Unknown error',
    }, { status: 500 });
  }
}
