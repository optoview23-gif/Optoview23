import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary),
          bodyMedium: GoogleFonts.inter(color: AppColors.textSecondary),
          titleLarge: GoogleFonts.inter(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.drawerText,
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.drawerText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          floatingLabelStyle: const TextStyle(color: AppColors.primary),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
      );
}
