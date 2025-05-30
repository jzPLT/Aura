import { NextRequest, NextResponse } from 'next/server';
import { UserData } from '../types';
import { auth } from '@/lib/firebase/admin';
import { UserService } from '../service';

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

      // Try to get user from database
      const userData = await UserService.getUserByUid(params.uid);
      
      if (!userData) {
        return NextResponse.json(
          { error: 'User does not exist' },
          { status: 404 }
        );
      }

      return NextResponse.json({
        success: true,
        data: userData,
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
      const requestData = await request.json();

      // Prepare user data for upsert (create or update)
      const userData: Omit<UserData, 'createdAt' | 'updatedAt'> = {
        uid: params.uid,
        email: decodedToken.email || requestData.email,
        displayName: requestData.displayName || decodedToken.name,
        preferencesTheme: requestData.preferencesTheme || 'dark',
        preferencesNotifications: requestData.preferencesNotifications !== undefined 
          ? requestData.preferencesNotifications 
          : true,
        defaultDurationForScheduling: requestData.defaultDurationForScheduling || 30,
      };

      // Use upsert to create or update the user
      const updatedUser = await UserService.upsertUser(userData);

      return NextResponse.json({
        success: true,
        data: updatedUser,
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
