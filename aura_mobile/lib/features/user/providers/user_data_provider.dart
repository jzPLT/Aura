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
          if (attempt == maxRetries) {
            _error =
                'Failed to load user data after $maxRetries attempts. Please try again later.';
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

  void clearUserData() {
    _userData = null;
    _error = null;
    notifyListeners();
  }
}
