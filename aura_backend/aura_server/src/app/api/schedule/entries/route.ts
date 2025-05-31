import { NextRequest, NextResponse } from 'next/server';
import { auth } from '@/lib/firebase/admin';
import { ScheduleEntryService } from '../service';

/**
 * GET /api/schedule/user
 * 
 * Get all schedule entries for the authenticated user
 */
export async function GET(request: NextRequest) {
  try {
    // Get the Authorization header
    const authHeader = request.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Missing or invalid authorization header' },
        { status: 401 }
      );
    }

    // Extract the token
    const idToken = authHeader.split('Bearer ')[1];

    try {
      // Verify the Firebase token
      const decodedToken = await auth.verifyIdToken(idToken);
      
      // Get user's schedule entries
      const scheduleEntries = await ScheduleEntryService.getUserScheduleEntries(decodedToken.uid);

      return NextResponse.json({ 
        success: true,
        data: scheduleEntries
      });

    } catch (error) {
      console.error('Token verification failed:', error);
      return NextResponse.json(
        { error: 'Invalid authentication token' },
        { status: 401 }
      );
    }
  } catch (error) {
    console.error('Error fetching schedule entries:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
