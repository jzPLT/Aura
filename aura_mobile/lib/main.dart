import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:aura_mobile/core/app.dart';
import 'package:aura_mobile/features/auth/providers/auth_provider.dart';
import 'package:aura_mobile/features/user/services/user_service.dart';
import 'package:aura_mobile/features/user/providers/user_data_provider.dart';
import 'package:aura_mobile/features/calendar/state/calendar_state.dart';

import 'features/auth/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authService = AuthService();
  final userService = UserService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => UserDataProvider(userService)),
        ChangeNotifierProvider(create: (_) => CalendarState()),
      ],
      child: const AuraMobileApp(),
    ),
  );
}
