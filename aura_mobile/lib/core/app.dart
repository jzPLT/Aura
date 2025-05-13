import 'package:aura_mobile/core/theme/app_theme.dart';
import 'package:aura_mobile/features/calendar/screens/landing_page.dart';
import 'package:flutter/material.dart';

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
