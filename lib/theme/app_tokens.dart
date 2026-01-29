import 'package:flutter/material.dart';

/// Design tokens: palette, spacing, radii, typography.
/// Calm & Trust · Fast paths · Predictable UI · Accessible by default.
class AppTokens {
  AppTokens._();

  // ---------- Spacing (8dp grid) ----------
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  // ---------- Radii ----------
  static const double radiusCard = 16;
  static const double radiusInput = 14;
  static const double radiusButton = 14;
  static const double radiusChip = 999;
  static const double radiusBottomSheet = 24;

  // ---------- Tappable minimum ----------
  static const double minTapSize = 48;

  // ---------- Light palette ----------
  static const Color primary = Color(0xFF1D4ED8);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color secondary = Color(0xFF14B8A6);
  static const Color secondaryContainer = Color(0xFFCCFBF1);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF1F5F9);
  static const Color outline = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // ---------- Dark palette ----------
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surface2Dark = Color(0xFF111C33);
  static const Color outlineDark = Color(0xFF22304A);
  static const Color textPrimaryDark = Color(0xFFE5E7EB);
}
