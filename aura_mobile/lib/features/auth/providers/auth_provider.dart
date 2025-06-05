import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../features/user/providers/user_data_provider.dart';
import '../../../features/user/services/user_service.dart';

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

      // Check system health before proceeding
      final isHealthy = await _checkSystemHealth();
      if (!isHealthy) {
        throw Exception(
          'System is temporarily unavailable. Please try again later.',
        );
      }

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

      // Check system health before proceeding with deletion
      final isHealthy = await _checkSystemHealth();
      if (!isHealthy) {
        throw Exception(
          'Cannot delete account while system is unavailable. Please try again later.',
        );
      }

      print('🗑️ Starting atomic account deletion...');

      // Call backend to atomically delete from both database and Firebase Auth
      // The backend handles both operations to ensure consistency
      await _context!.read<UserDataProvider>().deleteUserAccount(_user!);

      print('✅ Account deletion completed successfully');

      // Clear local user data
      _user = null;
      _context!.read<UserDataProvider>().clearUserData();

      // The user should now be signed out automatically since Firebase Auth user was deleted
    } catch (e) {
      print('❌ Account deletion failed: $e');
      // If deletion fails, we need to check if it was a partial failure
      if (e.toString().contains('Critical:')) {
        // This indicates a system inconsistency that requires manual intervention
        if (_context != null && _context!.mounted) {
          ScaffoldMessenger.of(_context!).showSnackBar(
            SnackBar(
              content: Text(
                'Account deletion encountered a system error. Please contact support. Error: ${e.toString()}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 10),
            ),
          );
        }
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify system health before performing critical operations
  Future<bool> _checkSystemHealth() async {
    try {
      final userService = UserService();
      final healthStatus = await userService.checkSystemHealth();

      if (!healthStatus['success']) {
        print('⚠️ System health check failed: ${healthStatus['error']}');
        if (_context != null && _context!.mounted) {
          ScaffoldMessenger.of(_context!).showSnackBar(
            SnackBar(
              content: Text(
                'System temporarily unavailable. Please try again later.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return false;
      }

      final services = healthStatus['services'] as Map<String, dynamic>?;
      final isFirebaseHealthy = services?['firebase']?['connected'] == true;
      final isDatabaseHealthy = services?['database']?['connected'] == true;

      if (!isFirebaseHealthy || !isDatabaseHealthy) {
        print(
          '⚠️ Some services are unhealthy - Firebase: $isFirebaseHealthy, Database: $isDatabaseHealthy',
        );
        if (_context != null && _context!.mounted) {
          ScaffoldMessenger.of(_context!).showSnackBar(
            SnackBar(
              content: Text(
                'Some services are temporarily unavailable. Account operations may fail.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Health check error: $e');
      return false; // Fail safe - don't allow operations if we can't verify health
    }
  }
}
