import 'package:aura_mobile/core/app.dart';
import 'package:aura_mobile/features/calendar/state/calendar_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CalendarState(),
      child: const AuraMobileApp(),
    ),
  );
}
