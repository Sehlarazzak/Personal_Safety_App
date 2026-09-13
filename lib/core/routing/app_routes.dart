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

  // Module 2: Contacts — pushed as full screens (with a back arrow),
  // outside the bottom-nav shell, per the "Add/Edit Contact" mockup.
  static const String addContact = '/contacts/add';
  static const String editContact = '/contacts/edit';

  // Module 3: Safety Timer & Check-In — also pushed as full screens.
  static const String startSession = '/session/start';
  static const String activeSession = '/session/active';
}
