/// 8-point spacing grid, per the design specification (section 6.2).
class AppSpacing {
  AppSpacing._();

  static const double micro = 4;
  static const double small = 8;
  static const double compact = 12;
  static const double standard = 16;
  static const double large = 24;
  static const double section = 32;
  static const double major = 48;
}

/// Border radius scale (section 6.3).
class AppRadius {
  AppRadius._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xLarge = 24;
}

/// Motion durations (section 8).
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
}

/// Responsive breakpoints (section 13).
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double desktop = 1024;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width <= desktop;
  static bool isDesktop(double width) => width > desktop;
}
