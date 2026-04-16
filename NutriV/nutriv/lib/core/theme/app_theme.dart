import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF006A35);
  static const Color primaryContainer = Color(0xFF6BFE9C);
  static const Color primaryDim = Color(0xFF005C2D);
  static const Color onPrimary = Color(0xFFCDFFD4);
  static const Color onPrimaryContainer = Color(0xFF005f2f);

  static const Color secondary = Color(0xFF006946);
  static const Color secondaryContainer = Color(0xFF72FBBD);
  static const Color onSecondary = Color(0xFFC9FFDF);
  static const Color onSecondaryContainer = Color(0xFF005E3E);

  static const Color tertiary = Color(0xFF006576);
  static const Color tertiaryContainer = Color(0xFF00DCFF);
  static const Color onTertiary = Color(0xFFDDF7FF);
  static const Color onTertiaryContainer = Color(0xFF004956);

  static const Color surface = Color(0xFFDBFFE8);
  static const Color surfaceContainerLow = Color(0xFFC4FEDD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFAEF1CC);
  static const Color surfaceContainerHighest = Color(0xFFA4ECC5);
  static const Color surfaceVariant = Color(0xFFA4ECC5);
  static const Color surfaceDim = Color(0xFF98E4BC);
  static const Color surfaceBright = Color(0xFFDBFFE8);

  static const Color onSurface = Color(0xFF003622);
  static const Color onSurfaceVariant = Color(0xFF35654D);
  static const Color onBackground = Color(0xFF003622);

  static const Color outline = Color(0xFF518168);
  static const Color outlineVariant = Color(0xFF86B89C);

  static const Color error = Color(0xFFB31B25);
  static const Color errorContainer = Color(0xFFFB5151);
  static const Color onError = Color(0xFFFFEFEE);
  static const Color onErrorContainer = Color(0xFF570008);

  static const Color inverseSurface = Color(0xFF001209);
  static const Color inverseOnSurface = Color(0xFF76A78D);
  static const Color inversePrimary = Color(0xFF6BFE9C);

  static const Color proteinColor = Color(0xFF2196F3);
  static const Color carbsColor = Color(0xFFFF9800);
  static const Color fatColor = Color(0xFFE91E63);
  static const Color caloriesColor = Color(0xFF006A35);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        titleLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        titleSmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodySmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        labelMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        labelSmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primaryContainer,
        secondary: secondaryContainer,
        error: error,
        brightness: Brightness.dark,
        surface: const Color(0xFF0D1F14),
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryContainer,
        foregroundColor: primaryDim,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2E22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: primaryDim,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryContainer,
        unselectedItemColor: Color(0xFF76A78D),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
