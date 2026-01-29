import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_tokens.dart';

class AppTheme {
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppTokens.primary,
        onPrimary: Colors.white,
        primaryContainer: AppTokens.primaryContainer,
        onPrimaryContainer: AppTokens.primaryDark,
        secondary: AppTokens.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppTokens.secondaryContainer,
        onSecondaryContainer: AppTokens.primaryDark,
        surface: AppTokens.surface,
        onSurface: AppTokens.textPrimary,
        surfaceContainerHighest: AppTokens.surface2,
        outline: AppTokens.outline,
        error: AppTokens.error,
        onError: Colors.white,
        tertiary: AppTokens.info,
      ),
      scaffoldBackgroundColor: AppTokens.background,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTokens.primary,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        color: AppTokens.surface,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppTokens.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppTokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppTokens.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.lg,
          vertical: AppTokens.md,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.xl,
            vertical: AppTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.manropeTextTheme(),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 80,
        indicatorColor: AppTokens.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTokens.primary,
            );
          }
          return GoogleFonts.manrope(
            fontSize: 12,
            color: AppTokens.textSecondary,
          );
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusBottomSheet),
          ),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppTokens.primary,
        onPrimary: Colors.white,
        primaryContainer: AppTokens.primaryDark,
        onPrimaryContainer: AppTokens.primaryContainer,
        secondary: AppTokens.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppTokens.secondaryContainer,
        onSecondaryContainer: AppTokens.textPrimaryDark,
        surface: AppTokens.surfaceDark,
        onSurface: AppTokens.textPrimaryDark,
        surfaceContainerHighest: AppTokens.surface2Dark,
        outline: AppTokens.outlineDark,
        error: AppTokens.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppTokens.backgroundDark,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTokens.surfaceDark,
        foregroundColor: AppTokens.textPrimaryDark,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTokens.textPrimaryDark,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
        color: AppTokens.surfaceDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.surface2Dark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppTokens.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppTokens.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.xl,
            vertical: AppTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 80,
        backgroundColor: AppTokens.surfaceDark,
        indicatorColor: AppTokens.primaryDark,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTokens.primaryContainer,
            );
          }
          return GoogleFonts.manrope(
            fontSize: 12,
            color: AppTokens.textTertiary,
          );
        }),
      ),
    );
  }
}
