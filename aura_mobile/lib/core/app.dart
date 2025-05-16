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
          // Show landing page if authenticated, login screen otherwise
          return authProvider.isAuthenticated
              ? const LandingPage(title: 'Aura')
              : const LoginScreen();
        },
      ),
    );
  }
}
