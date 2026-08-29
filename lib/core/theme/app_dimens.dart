/// Spacing, radius, and layout tokens for the 8pt grid system used
/// throughout the app ("Guardian Standard" design system).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double base = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Side margins on mobile screens.
  static const double marginMobile = 16;

  /// Gutter between grid items on mobile.
  static const double gutterMobile = 12;
}

class AppRadius {
  AppRadius._();

  static const double sm = 4; // 0.25rem
  static const double defaultRadius = 8; // 0.5rem — buttons
  static const double md = 12; // 0.75rem
  static const double lg = 16; // 1rem — cards
  static const double xl = 24; // 1.5rem
  static const double full = 9999; // pill / circular
}

/// Minimum touch target size mandated by the design system so the app
/// stays usable under stress, in motion, or with limited dexterity.
class AppA11y {
  AppA11y._();

  static const double minTouchTarget = 48;
}
