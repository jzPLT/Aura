import 'package:aura_mobile/core/theme/app_theme.dart';
import 'package:aura_mobile/features/calendar/screens/landing_page.dart';
import 'package:aura_mobile/features/auth/screens/login_screen.dart';
import 'package:aura_mobile/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuraMobileApp extends StatelessWidget {
  const AuraMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura',
      theme: AppTheme.darkTheme,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Set the context for the AuthProvider to handle user data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.setContext(context);
          });

          // Show landing page if authenticated, login screen otherwise
          return authProvider.isAuthenticated
              ? const LandingPage(title: 'Aura')
              : const LoginScreen();
        },
      ),
    );
  }
}
