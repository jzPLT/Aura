import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';
import '../services/user_service.dart';

class UserDataProvider extends ChangeNotifier {
  final UserService _userService;
  UserData? _userData;
  bool _isLoading = false;
  String? _error;

  UserDataProvider(this._userService);

  UserData? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> loadUserData(User firebaseUser) async {
    const maxRetries = 3;
    const retryDelayMs = 1000; // 1 second delay between retries

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      for (var attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          _userData = await _userService.getUserData(firebaseUser);
          _error = null;
          return true;
        } catch (e) {
          // Don't retry on legitimate client errors (404, 409, etc.)
          // Only retry on network/server errors (5xx, connection issues)
          if (_shouldNotRetry(e) || attempt == maxRetries) {
            _error = e.toString();
            throw _error!;
          }
          // Wait before retrying
          await Future.delayed(const Duration(milliseconds: retryDelayMs));
        }
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new user account during signup
  Future<bool> createUserAccount(
    User firebaseUser, {
    String? displayName,
    String preferencesTheme = 'dark',
    bool preferencesNotifications = true,
    int defaultDurationForScheduling = 30,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userData = await _userService.createUserAccount(
        firebaseUser,
        displayName: displayName,
        preferencesTheme: preferencesTheme,
        preferencesNotifications: preferencesNotifications,
        defaultDurationForScheduling: defaultDurationForScheduling,
      );

      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates user data
  Future<bool> updateUserData(
    User firebaseUser,
    Map<String, dynamic> updates,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userData = await _userService.updateUserData(firebaseUser, updates);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearUserData() {
    _userData = null;
    _error = null;
    notifyListeners();
  }

  /// Determines if an error should not be retried
  /// Returns true for client errors (4xx) that are legitimate and shouldn't be retried
  bool _shouldNotRetry(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    // Don't retry on client errors that indicate legitimate issues
    return errorMessage.contains('user not found') ||
        errorMessage.contains('404') ||
        errorMessage.contains('not found') ||
        errorMessage.contains('unauthorized') ||
        errorMessage.contains('401') ||
        errorMessage.contains('forbidden') ||
        errorMessage.contains('403') ||
        errorMessage.contains('conflict') ||
        errorMessage.contains('409') ||
        errorMessage.contains('bad request') ||
        errorMessage.contains('400');
  }
}
