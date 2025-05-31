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

  Future<void> _loadUserData(User user, {bool isNewUser = false}) async {
    if (_context == null) return;

    try {
      final userDataProvider = _context!.read<UserDataProvider>();

      if (isNewUser) {
        // For new users, create account in database
        final success = await userDataProvider.createUserAccount(user);
        if (!success && _context!.mounted) {
          ScaffoldMessenger.of(_context!).showSnackBar(
            const SnackBar(
              content: Text('Failed to create user account. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        // For existing users, load their data
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
      // Clear user data when signing out
      if (_context != null && user == null) {
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

      // Load user data after successful sign-in
      if (_user != null && _context != null) {
        await _loadUserData(_user!, isNewUser: false);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailPassword(
    String email,
    String password, {
    String? displayName,
    String preferencesTheme = 'dark',
    bool preferencesNotifications = true,
    int defaultDurationForScheduling = 30,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create Firebase Auth user
      await _authService.signUpWithEmailPassword(email, password);

      // Create user account in database
      if (_user != null && _context != null) {
        final userDataProvider = _context!.read<UserDataProvider>();
        await userDataProvider.createUserAccount(
          _user!,
          displayName: displayName,
          preferencesTheme: preferencesTheme,
          preferencesNotifications: preferencesNotifications,
          defaultDurationForScheduling: defaultDurationForScheduling,
        );
      }
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

      // Load user data after successful sign-in
      if (_user != null && _context != null) {
        await _loadUserData(_user!, isNewUser: false);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithGoogle({
    String preferencesTheme = 'dark',
    bool preferencesNotifications = true,
    int defaultDurationForScheduling = 30,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sign in with Google (this also handles account creation)
      await _authService.signInWithGoogle();

      // Try to create user account in database (will fail if already exists)
      if (_user != null && _context != null) {
        final userDataProvider = _context!.read<UserDataProvider>();
        try {
          await userDataProvider.createUserAccount(
            _user!,
            displayName: _user!.displayName,
            preferencesTheme: preferencesTheme,
            preferencesNotifications: preferencesNotifications,
            defaultDurationForScheduling: defaultDurationForScheduling,
          );
        } catch (e) {
          // If user already exists, just load their data
          if (e.toString().contains('already exists')) {
            await userDataProvider.loadUserData(_user!);
          } else {
            rethrow;
          }
        }
      }
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
