import { NextRequest, NextResponse } from 'next/server';
import { UserData } from '../types';
import { auth } from '@/lib/firebase/admin';

// Mock database for now - in production, this would be your database
const mockUserData: Record<string, UserData> = {};

export async function GET(
  request: NextRequest,
  { params }: { params: { uid: string } }
) {
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
      
      // Check if the token UID matches the requested UID
      if (decodedToken.uid !== params.uid) {
        return NextResponse.json(
          { error: 'Unauthorized access' },
          { status: 403 }
        );
      }

      // In production, fetch from your database
      // For now, return mock data or create it if it doesn't exist
      if (!mockUserData[params.uid]) {
        mockUserData[params.uid] = {
          uid: params.uid,
          email: decodedToken.email || '',
          displayName: decodedToken.name,
          preferencesTheme: 'dark',
          preferencesNotifications: true,
          defaultDurationForScheduling: 30,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        };
      }

      return NextResponse.json({
        success: true,
        data: mockUserData[params.uid],
      });
    } catch (error) {
      console.error('Token verification failed:', error);
      return NextResponse.json(
        { error: 'Invalid authentication token' },
        { status: 401 }
      );
    }
  } catch (error) {
    console.error('Error processing request:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: { uid: string } }
) {
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
      
      // Check if the token UID matches the requested UID
      if (decodedToken.uid !== params.uid) {
        return NextResponse.json(
          { error: 'Unauthorized access' },
          { status: 403 }
        );
      }

      // Parse the request body
      const userData = await request.json();

      // Create or update user data
      const updatedUserData: UserData = {
        uid: params.uid,
        email: decodedToken.email || userData.email,
        displayName: userData.displayName || decodedToken.name,
        preferencesTheme: userData.preferencesTheme || 'dark',
        preferencesNotifications: userData.preferencesNotifications !== undefined 
          ? userData.preferencesNotifications 
          : true,
        defaultDurationForScheduling: userData.defaultDurationForScheduling || 30,
        createdAt: mockUserData[params.uid]?.createdAt || new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      mockUserData[params.uid] = updatedUserData;

      return NextResponse.json({
        success: true,
        data: updatedUserData,
      });
    } catch (error) {
      console.error('Token verification failed:', error);
      return NextResponse.json(
        { error: 'Invalid authentication token' },
        { status: 401 }
      );
    }
  } catch (error) {
    console.error('Error processing request:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
