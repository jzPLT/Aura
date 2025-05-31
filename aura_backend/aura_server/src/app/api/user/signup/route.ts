import { NextRequest, NextResponse } from 'next/server';
import { UserData } from '../types';
import { auth } from '@/lib/firebase/admin';
import { UserService } from '../service';

/**
 * POST /api/user/signup
 * 
 * Creates a new user account in the database when they first sign up.
 * This endpoint is designed to be called right after Firebase Auth registration.
 */
export async function POST(request: NextRequest) {
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
      
      // Parse the request body for additional user preferences
      const requestData = await request.json();

      // Check if the user already exists in the database      
      if (await UserService.userExists(decodedToken.uid)) {
        return NextResponse.json(
          { error: 'User already exists' },
          { status: 409 }
        );
      }

      // Create new user with Firebase data and any provided preferences
      const newUserData: Omit<UserData, 'createdAt' | 'updatedAt'> = {
        uid: decodedToken.uid,
        email: decodedToken.email || requestData.email,
        displayName: requestData.displayName || decodedToken.name,
        preferencesTheme: requestData.preferencesTheme || 'dark',
        preferencesNotifications: requestData.preferencesNotifications !== undefined 
          ? requestData.preferencesNotifications 
          : true,
        defaultDurationForScheduling: requestData.defaultDurationForScheduling || 30,
      };

      // Create the user in the database
      const createdUser = await UserService.createUser(newUserData);

      console.log('✅ SIGNUP API COMPLETED - User created successfully');
      return NextResponse.json({
        success: true,
        message: 'User created successfully',
        data: createdUser,
      }, { status: 201 });

    } catch (error) {
      console.error('Token verification failed:', error);
      return NextResponse.json(
        { error: 'Invalid authentication token' },
        { status: 401 }
      );
    }
  } catch (error) {
    console.error('Error creating user:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
