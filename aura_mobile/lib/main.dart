import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:aura_mobile/core/app.dart';
import 'package:aura_mobile/core/services/auth_service.dart';
import 'package:aura_mobile/features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authService = AuthService();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(authService),
      child: const AuraMobileApp(),
    ),
  );
}
