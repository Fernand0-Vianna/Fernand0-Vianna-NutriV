import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores principais - Verde NutriVision (#43825C)
  static const Color primary = Color(0xFF43825C);
  static const Color primaryContainer = Color(0xFFD4E8DD);
  static const Color primaryDim = Color(0xFF35664A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1A3323);

  // Cores secundárias - Laranja NutriVision (#E68D40)
  static const Color secondary = Color(0xFFE68D40);
  static const Color secondaryContainer = Color(0xFFF5D9C3);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF5C3A1D);

  // Cores terciárias - Cinza escuro (#37373D)
  static const Color tertiary = Color(0xFF37373D);
  static const Color tertiaryContainer = Color(0xFFE5E5E7);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF1A1A1D);

  // Fundos - Neutros limpos
  static const Color surface = Color(0xFFF8F9F8);
  static const Color surfaceContainerLow = Color(0xFFEDEEED);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E3E2);
  static const Color surfaceContainerHighest = Color(0xFFD1D2D1);
  static const Color surfaceVariant = Color(0xFFF1F2F1);
  static const Color surfaceDim = Color(0xFFE2E3E2);
  static const Color surfaceBright = Color(0xFFFFFFFF);

  // Texto
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF4A4A4A);
  static const Color onBackground = Color(0xFF1A1A1A);

  // Bordas
  static const Color outline = Color(0xFFE2E3E2);
  static const Color outlineVariant = Color(0xFFD1D2D1);

  // Erro
  static const Color error = Color(0xFFDC4446);
  static const Color errorContainer = Color(0xFFFDE8E8);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF9B1C1C);

  // Inversos
  static const Color inverseSurface = Color(0xFF1A1A1A);
  static const Color inverseOnSurface = Color(0xFFF8F9F8);
  static const Color inversePrimary = Color(0xFF8FBC8F);

  // Cores para macronutrientes (usando verde, laranja e cinza da paleta)
  static const Color proteinColor = Color(0xFF43825C);
  static const Color carbsColor = Color(0xFFE68D40);
  static const Color fatColor = Color(0xFF37373D);
  static const Color caloriesColor = Color(0xFF43825C);

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
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: onSurfaceVariant, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
        backgroundColor: surfaceContainerLowest,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerLow,
        selectedColor: primaryContainer,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: Color(0xFF2A4D38),
        onPrimaryContainer: Color(0xFFD4E8DD),
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: Color(0xFF5C3A1D),
        onSecondaryContainer: Color(0xFFF5D9C3),
        tertiary: Color(0xFFE5E5E7),
        onTertiary: Color(0xFF1A1A1D),
        tertiaryContainer: Color(0xFF4A4A4D),
        onTertiaryContainer: Color(0xFFF8F9F8),
        error: error,
        onError: onError,
        errorContainer: Color(0xFF5C1C1C),
        onErrorContainer: Color(0xFFFDE8E8),
        surface: Color(0xFF1A1A1A),
        onSurface: Color(0xFFF8F9F8),
        surfaceContainerHighest: Color(0xFF2D2D2D),
        onSurfaceVariant: Color(0xFFA0A0A0),
        outline: Color(0xFF404040),
        outlineVariant: Color(0xFF505050),
        inverseSurface: Color(0xFFF8F9F8),
        onInverseSurface: Color(0xFF1A1A1A),
        inversePrimary: Color(0xFF6B9E7F),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF8F9F8),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF8F9F8),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: Color(0xFF808080), fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFFB0B0B0),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
        backgroundColor: Color(0xFF1E1E1E),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        selectedColor: primaryContainer,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: Color(0xFFF8F9FA),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: const Color(0xFFF8F9FA),
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: const Color(0xFFF8F9FA),
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8F9FA),
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: const Color(0xFFF8F9FA),
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8F9FA),
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF8F9FA),
        ),
        titleLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8F9FA),
        ),
        titleMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF8F9FA),
        ),
        titleSmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF8F9FA),
        ),
        bodyLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w400,
          color: const Color(0xFFF8F9FA),
        ),
        bodyMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w400,
          color: const Color(0xFFF8F9FA),
        ),
        bodySmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w400,
          color: const Color(0xFFB0B0B0),
        ),
        labelLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF8F9FA),
        ),
        labelMedium: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF8F9FA),
        ),
        labelSmall: GoogleFonts.manrope(
          fontWeight: FontWeight.w500,
          color: const Color(0xFFB0B0B0),
        ),
      ),
    );
  }
}
