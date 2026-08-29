/// Centralized route path constants so no screen has to hardcode a route
/// string. Keeps navigation typo-proof and gives Modules 2-6 one place to
/// register new destinations (e.g. `/session/active`, `/emergency`).
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Main shell (bottom-nav) and its tabs.
  static const String home = '/home';
  static const String contacts = '/home/contacts';
  static const String history = '/home/history';
  static const String settings = '/home/settings';
}
