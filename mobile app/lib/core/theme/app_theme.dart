import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final cairoTextTheme = GoogleFonts.cairoTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: cairoTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: GoogleFonts.cairo(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surfaceLight,
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.cairo(),
        hintStyle: GoogleFonts.cairo(),
        errorStyle: GoogleFonts.cairo(color: Colors.red),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final cairoTextTheme = GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme);
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: cairoTextTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surfaceDark,
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shadowColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}