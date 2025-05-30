import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../features/user/providers/user_data_provider.dart';

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

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> _loadUserData(User user) async {
    if (_context == null) return;

    try {
      final userDataProvider = _context!.read<UserDataProvider>();
      final success = await userDataProvider.loadUserData(user);

      if (!success && _context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          const SnackBar(
            content: Text(
              'Having trouble loading your data. Some features may be limited.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (_context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _init() {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      // Handle user data when auth state changes
      if (_context != null && user != null) {
        await _loadUserData(user);
      } else if (_context != null) {
        _context!.read<UserDataProvider>().clearUserData();
      }
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

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signInWithGoogle();
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

  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.deleteAccount();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
