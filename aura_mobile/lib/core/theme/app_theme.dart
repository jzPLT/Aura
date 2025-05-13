import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
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

  static LinearGradient get appBarGradient {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.blue.shade900,
        Colors.purple.shade900,
        Colors.pink.shade300,
      ],
    );
  }

  static LinearGradient get containerGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.blue.shade800, Colors.purple.shade800],
    );
  }

  static LinearGradient get backgroundGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.blue.shade900.withOpacity(0.05),
        Colors.purple.shade900.withOpacity(0.05),
        Colors.pink.shade300.withOpacity(0.05),
      ],
    );
  }
}
