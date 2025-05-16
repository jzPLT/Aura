import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;

  AuthProvider(this._authService) {
    _init();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  void _init() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signInWithEmailPassword(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signUpWithEmailPassword(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.resetPassword(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
