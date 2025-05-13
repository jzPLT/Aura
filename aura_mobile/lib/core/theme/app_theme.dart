import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: Colors.purple.shade300,
      secondary: Colors.blue.shade300,
      surface: Colors.grey.shade900,
      background: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.black,
    textTheme: GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white),
  );
}
