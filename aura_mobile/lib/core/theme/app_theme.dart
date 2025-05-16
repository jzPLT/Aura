import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static final primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.blue.shade900, Colors.purple.shade900],
  );

  static final buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.blue.shade800, Colors.purple.shade800],
  );

  static final overlayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.blue.shade500.withOpacity(0.2),
      Colors.purple.shade300.withOpacity(0.2),
      Colors.pink.shade200.withOpacity(0.2),
    ],
  );

  // Text Styles
  static TextStyle get titleStyle => GoogleFonts.outfit(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get headerStyle => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get bodyStyle =>
      GoogleFonts.outfit(fontSize: 16, color: Colors.white);

  // Decorations
  static BoxDecoration get gradientBackground =>
      BoxDecoration(gradient: primaryGradient);

  static BoxDecoration get glassmorphicCard => BoxDecoration(
    gradient: overlayGradient,
    borderRadius: BorderRadius.circular(28.0),
    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.purple.withOpacity(0.1),
        blurRadius: 12,
        spreadRadius: 2,
      ),
    ],
  );

  static InputDecoration get inputDecoration => InputDecoration(
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white),
    ),
  );

  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white),
    ),
  );

  // Theme Data
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
    inputDecorationTheme: inputDecorationTheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.purple.shade900,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.1),
        side: BorderSide(color: Colors.white.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.white),
    ),
  );
}
