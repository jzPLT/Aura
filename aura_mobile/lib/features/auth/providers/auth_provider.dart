import 'package:firebase_auth/firebase_auth.dart';
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
    } catch (e) {
      // Show specific error message to user
      if (_context != null && _context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      rethrow; // Re-throw so UI can handle it if needed
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
    } catch (e) {
      // Show specific error message to user
      if (_context != null && _context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      rethrow; // Re-throw so UI can handle it if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔑 Starting Google Sign-In...');
      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential?.user;

      if (user == null) {
        print('❌ No user returned from Google Sign-In');
        return;
      }

      print('✅ Google Sign-In successful: ${user.uid} (${user.email})');

      // Try to load user data, and if user doesn't exist, create them
      if (_context != null) {
        final userDataProvider = _context!.read<UserDataProvider>();

        try {
          print('📡 Attempting to load user data from server...');
          // First try to load existing user data
          final success = await userDataProvider.loadUserData(user);
          if (!success) {
            try {
              await userDataProvider.createUserAccount(user);
              print('✅ User account created successfully');
              if (_context!.mounted) {
                ScaffoldMessenger.of(_context!).showSnackBar(
                  const SnackBar(
                    content: Text('Welcome! Your account has been created.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            } catch (createError) {
              print('❌ Failed to create user account: $createError');
              if (_context!.mounted) {
                ScaffoldMessenger.of(_context!).showSnackBar(
                  SnackBar(
                    content: Text('Failed to create account: $createError'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            }
          }
          if (_context!.mounted) {
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
          print('❌ Error loading user data: $e');
          // If user doesn't exist (404 error), create them
        }
      } else {
        print('❌ No context available for user data operations');
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

  // Check what sign-in methods are available for an email
  Future<List<String>> getSignInMethodsForEmail(String email) async {
    try {
      return await _authService.getSignInMethodsForEmail(email);
    } catch (e) {
      // Return empty list if there's an error checking
      return [];
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

      if (_user == null) {
        throw Exception('User not logged in');
      }

      // Call UserService to soft delete user from backend
      await _context!.read<UserDataProvider>().deleteUserAccount(_user!);

      // Then delete from Firebase Auth
      await _authService.deleteAccount();

      // Sign out locally
      _user = null;
      _context!.read<UserDataProvider>().clearUserData();
      // No need to call _authService.signOut() as deleteAccount() handles it.
    } catch (e) {
      // Potentially rethrow or handle specific errors for UI
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
