import 'package:flutter/material.dart';

/// Color tokens for the "Guardian Standard" design system.
///
/// These are ported 1:1 from `guardian_standard/DESIGN.md` so that every
/// screen and reusable widget references the same semantic names the
/// designers used (surface, primary, error-container, etc.) instead of
/// raw hex values scattered around the codebase.
class AppColors {
  AppColors._();

  // Surfaces
  static const Color surface = Color(0xFFF8F9FB);
  static const Color surfaceDim = Color(0xFFD8DADC);
  static const Color surfaceBright = Color(0xFFF8F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  static const Color surfaceVariant = Color(0xFFE1E3E4);

  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF40484C);

  static const Color inverseSurface = Color(0xFF2E3132);
  static const Color inverseOnSurface = Color(0xFFEFF1F3);

  static const Color outline = Color(0xFF70787D);
  static const Color outlineVariant = Color(0xFFBFC8CC);

  // Brand / Primary (deep blue-teal — calm authority)
  static const Color surfaceTint = Color(0xFF1A667D);
  static const Color primary = Color(0xFF004152);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF005A70);
  static const Color onPrimaryContainer = Color(0xFF8DCFE9);
  static const Color inversePrimary = Color(0xFF8ED0E9);

  // Secondary
  static const Color secondary = Color(0xFF506165);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD4E6EB);
  static const Color onSecondaryContainer = Color(0xFF56676C);

  // Tertiary (warm amber — non-critical warnings)
  static const Color tertiary = Color(0xFF5B3100);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF774715);
  static const Color onTertiaryContainer = Color(0xFFFBB87C);

  // Semantic: Error / Emergency (reserved exclusively for danger)
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Semantic: Safe / Success
  static const Color safe = Color(0xFF1E8E3E);
  static const Color onSafe = Color(0xFFFFFFFF);
  static const Color safeContainer = Color(0xFFD9F2E1);
  static const Color onSafeContainer = Color(0xFF0B3D1E);

  // Semantic: Warning (amber)
  static const Color warning = Color(0xFF8A5300);
  static const Color warningContainer = Color(0xFFFFDDB0);
  static const Color onWarningContainer = Color(0xFF2A1800);

  // Background
  static const Color background = Color(0xFFF8F9FB);
  static const Color onBackground = Color(0xFF191C1E);
}
