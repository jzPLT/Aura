import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static const String baseUrl = 'http://localhost:3000/api';

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return UserData.fromJson(data['data']);
        }
        throw Exception(data['message'] ?? 'Failed to fetch user data');
      }

      if (response.statusCode == 404) {
        // If user data doesn't exist, create it
        return await saveUserData(firebaseUser);
      }

      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to fetch user data',
      );
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<UserData> saveUserData(User firebaseUser) async {
    try {
      final idToken = await firebaseUser.getIdToken();

      // Create initial user data
      final userData = {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'preferences': {'theme': 'dark', 'notifications': true},
        'scheduleSettings': {
          'defaultDuration': 30,
          'workingHours': {'start': '09:00', 'end': '17:00'},
        },
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final response = await http.put(
        Uri.parse('$baseUrl/user/${firebaseUser.uid}'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return UserData.fromJson(data['data']);
        }
        throw Exception(data['message'] ?? 'Failed to save user data');
      }

      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Failed to save user data',
      );
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
