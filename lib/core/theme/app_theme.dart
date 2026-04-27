import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/tokens.dart';

class AppTheme {
  AppTheme._();

  // Legacy accessors for code that still references these
  static const Color primaryBlue = SeeUColors.accent;
  static const Color likeRed = SeeUColors.like;
  static const Color secondaryText = SeeUColors.textSecondary;

  static const LinearGradient storyGradient = SeeUColors.storyGradient;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [SeeUColors.accent, Color(0xFFC04CFD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get light {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: SeeUColors.accent,
        onPrimary: Colors.white,
        secondary: Color(0xFFC04CFD),
        onSecondary: Colors.white,
        error: SeeUColors.error,
        onError: Colors.white,
        surface: SeeUColors.surface,
        onSurface: SeeUColors.textPrimary,
        surfaceContainerHighest: SeeUColors.surfaceElevated,
        surfaceContainerLowest: SeeUColors.background,
        outline: SeeUColors.borderSubtle,
        outlineVariant: SeeUColors.borderSubtle,
      ),
      scaffoldBackgroundColor: SeeUColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: SeeUColors.background,
        foregroundColor: SeeUColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.inter(
          color: SeeUColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: SeeUColors.textPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: SeeUColors.borderSubtle,
        thickness: 0.5,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SeeUColors.surfaceElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide:
              const BorderSide(color: SeeUColors.accentSoft, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SeeUColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(
          color: SeeUColors.textTertiary,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.inter(
          color: SeeUColors.textTertiary,
          fontSize: 15,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: SeeUTypography.displayXL,
        headlineMedium: SeeUTypography.displayL,
        titleLarge: SeeUTypography.title,
        titleMedium: SeeUTypography.subtitle,
        titleSmall: SeeUTypography.caption,
        bodyLarge: SeeUTypography.body,
        bodyMedium: SeeUTypography.caption,
        bodySmall: SeeUTypography.micro,
        labelLarge: SeeUTypography.subtitle,
        labelSmall: SeeUTypography.micro,
      ),
    );
  }

  static ThemeData get dark {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    const darkBg = Color(0xFF121212);
    const darkSurface = Color(0xFF1E1E1E);
    const darkSurfaceElevated = Color(0xFF2A2A2A);
    const darkTextPrimary = Color(0xFFF5F5F5);
    const darkTextSecondary = Color(0xFFA0A0A0);
    const darkTextTertiary = Color(0xFF6A6A6A);
    const darkBorder = Color(0xFF333333);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: SeeUColors.accent,
        onPrimary: Colors.white,
        secondary: Color(0xFFC04CFD),
        onSecondary: Colors.white,
        error: SeeUColors.error,
        onError: Colors.white,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkSurfaceElevated,
        surfaceContainerLowest: darkBg,
        outline: darkBorder,
        outlineVariant: darkBorder,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.inter(
          color: darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 0.5,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          borderSide: BorderSide(color: SeeUColors.accent.withValues(alpha: 0.5), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SeeUColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(color: darkTextTertiary, fontSize: 15),
        labelStyle: GoogleFonts.inter(color: darkTextTertiary, fontSize: 15),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: SeeUTypography.displayXL.copyWith(color: darkTextPrimary),
        headlineMedium: SeeUTypography.displayL.copyWith(color: darkTextPrimary),
        titleLarge: SeeUTypography.title.copyWith(color: darkTextPrimary),
        titleMedium: SeeUTypography.subtitle.copyWith(color: darkTextPrimary),
        titleSmall: SeeUTypography.caption.copyWith(color: darkTextSecondary),
        bodyLarge: SeeUTypography.body.copyWith(color: darkTextPrimary),
        bodyMedium: SeeUTypography.caption.copyWith(color: darkTextSecondary),
        bodySmall: SeeUTypography.micro.copyWith(color: darkTextTertiary),
        labelLarge: SeeUTypography.subtitle.copyWith(color: darkTextPrimary),
        labelSmall: SeeUTypography.micro.copyWith(color: darkTextTertiary),
      ),
    );
  }
}
