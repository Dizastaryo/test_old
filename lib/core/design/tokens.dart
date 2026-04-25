import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colors ───────────────────────────────────────────────────────────────

class SeeUColors {
  SeeUColors._();

  // Light theme
  static const Color background = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFEFCF9);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9A9A9A);
  static const Color borderSubtle = Color(0xFFEFEBE5);
  static const Color accent = Color(0xFFFF5A3C);
  static const Color accentSoft = Color(0xFFFFE8E0);
  static const Color like = Color(0xFFFF3366);
  static const Color success = Color(0xFF2FA84F);
  static const Color error = Color(0xFFFF3366);

  // Story ring gradient
  static const List<Color> storyRingColors = [
    Color(0xFFFFB547),
    Color(0xFFFF5A3C),
    Color(0xFFC04CFD),
  ];

  static const LinearGradient storyGradient = LinearGradient(
    colors: storyRingColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Signal colors (scanner)
  static const Color signalClose = Color(0xFF2FA84F);
  static const Color signalMedium = Color(0xFFFFB547);
  static const Color signalFar = Color(0xFFFF5A3C);
}

// ─── Typography ───────────────────────────────────────────────────────────

class SeeUTypography {
  SeeUTypography._();

  static TextStyle displayXL = GoogleFonts.fraunces(
    fontSize: 42,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.5,
    color: SeeUColors.textPrimary,
  );

  static TextStyle displayL = GoogleFonts.fraunces(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -1,
    color: SeeUColors.textPrimary,
  );

  static TextStyle title = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: SeeUColors.textPrimary,
  );

  static TextStyle subtitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    color: SeeUColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: SeeUColors.textPrimary,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: SeeUColors.textSecondary,
  );

  static TextStyle micro = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: SeeUColors.textTertiary,
  );

  static TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: SeeUColors.textTertiary,
  );
}

// ─── Spacing ──────────────────────────────────────────────────────────────

class SeeUSpacing {
  SeeUSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

// ─── Radii ────────────────────────────────────────────────────────────────

class SeeURadii {
  SeeURadii._();
  static const double small = 12;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 999;
}

// ─── Shadows ──────────────────────────────────────────────────────────────

class SeeUShadows {
  SeeUShadows._();

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
          offset: const Offset(0, 4),
          blurRadius: 16,
        ),
        BoxShadow(
          color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: const Color(0xFF1A1A1A).withValues(alpha: 0.08),
          offset: const Offset(0, 12),
          blurRadius: 32,
        ),
        BoxShadow(
          color: const Color(0xFF1A1A1A).withValues(alpha: 0.04),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];
}
