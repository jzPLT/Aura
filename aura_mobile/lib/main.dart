import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/calendar/screens/landing_page.dart';

void main() {
  runApp(const AuraMobileApp());
}

class AuraMobileApp extends StatelessWidget {
  const AuraMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura',
      theme: AppTheme.darkTheme,
      home: const LandingPage(title: 'Aura'),
    );
  }
}
