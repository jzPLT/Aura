import { NextRequest, NextResponse } from 'next/server';
import { UserData } from '../types';
import { auth } from '@/lib/firebase/admin';
import { UserService } from '../service';

export async function GET(
  request: NextRequest,
  { params }: { params: { uid: string } }
) {
  try {
    const { uid } = await params;

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
      if (decodedToken.uid !== uid) {
        return NextResponse.json(
          { error: 'Unauthorized access' },
          { status: 403 }
        );
      }

      // Get user from database
      const userData = await UserService.getUserByUid(uid);
      
      if (!userData) {
        return NextResponse.json(
          { error: 'User not found' },
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
    const { uid } = await params;

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
      if (decodedToken.uid !== uid) {
        return NextResponse.json(
          { error: 'Unauthorized access' },
          { status: 403 }
        );
      }

      // Parse the request body
      const requestData = await request.json();

      // Prepare user data for upsert (create or update)
      const userData: Omit<UserData, 'createdAt' | 'updatedAt'> = {
        uid: uid,
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

export async function DELETE(
  request: NextRequest,
  { params }: { params: { uid: string } }
) {
  try {
    const { uid } = await params;

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
      if (decodedToken.uid !== uid) {
        return NextResponse.json(
          { error: 'Unauthorized access to delete this user' },
          { status: 403 }
        );
      }

      // Hard delete the user
      await UserService.deleteUser(uid);

      return NextResponse.json({
        success: true,
        message: 'User deleted successfully',
      });
    } catch (error) {
      console.error('Token verification or user deletion failed:', error);
      // Check if the error is because the user is not found
      if (error instanceof Error && error.message.includes('not found')) {
        return NextResponse.json(
          { error: 'User not found' },
          { status: 404 }
        );
      }
      return NextResponse.json(
        { error: 'Invalid authentication token or failed to delete user' },
        { status: 401 }
      );
    }
  } catch (error) {
    console.error('Error processing DELETE request:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
