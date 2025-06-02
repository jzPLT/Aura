import 'dart:convert';
import 'package:aura_mobile/core/config.dart';
import 'package:http/http.dart' as http;
import '../models/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  Future<UserData> getUserData(User firebaseUser) async {
    try {
      // Get the ID token
      final idToken = await firebaseUser.getIdToken();

      final response = await http.get(
        Uri.parse('$baseUrl/user/${firebaseUser.uid}'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response: ${response.statusCode}');
      print('📡 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return UserData.fromJson(data['data']);
        }
        throw Exception(data['message'] ?? 'Failed to fetch user data');
      }

      if (response.statusCode == 404) {
        throw Exception('User not found');
      }

      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to fetch user data',
      );
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  /// Creates a new user account in the database (for signup flow)
  Future<UserData> createUserAccount(
    User firebaseUser, {
    String? displayName,
    String preferencesTheme = 'dark',
    bool preferencesNotifications = true,
    int defaultDurationForScheduling = 30,
  }) async {
    try {
      final idToken = await firebaseUser.getIdToken();

      // Create user data matching the backend schema
      final userData = {
        'displayName': displayName ?? firebaseUser.displayName,
        'preferencesTheme': preferencesTheme,
        'preferencesNotifications': preferencesNotifications,
        'defaultDurationForScheduling': defaultDurationForScheduling,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/user/signup'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return UserData.fromJson(data['data']);
        }
        throw Exception(data['message'] ?? 'Failed to create user account');
      }

      if (response.statusCode == 409) {
        throw Exception('User account already exists');
      }

      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to create user account',
      );
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  /// Updates existing user data
  Future<UserData> updateUserData(
    User firebaseUser,
    Map<String, dynamic> updates,
  ) async {
    try {
      final idToken = await firebaseUser.getIdToken();

      final response = await http.put(
        Uri.parse('$baseUrl/user/${firebaseUser.uid}'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return UserData.fromJson(data['data']);
        }
        throw Exception(data['message'] ?? 'Failed to update user data');
      }

      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to update user data',
      );
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
