import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 6, 114, 133)),
  );

  return base.copyWith(
    textTheme: GoogleFonts.fredokaTextTheme(base.textTheme),
    primaryTextTheme: GoogleFonts.fredokaTextTheme(base.primaryTextTheme),
    visualDensity: VisualDensity.standard,
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
