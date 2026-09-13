import 'package:go_router/go_router.dart';
import '../../data/models/trusted_contact_model.dart';
import '../../presentation/views/auth/login_screen.dart';
import '../../presentation/views/auth/registration_screen.dart';
import '../../presentation/views/contacts/add_edit_contact_screen.dart';
import '../../presentation/views/session/active_session_screen.dart';
import '../../presentation/views/session/start_session_screen.dart';
import '../../presentation/views/shell/main_shell_screen.dart';
import '../../presentation/views/splash/splash_screen.dart';
import 'app_routes.dart';

/// Single source of truth for navigation.
///
/// Flat top-level routes for Splash → Login/Register → Shell, plus
/// full-screen pushes for Contacts (Module 2) and the Session flow
/// (Module 3). Module 4 adds the Emergency Hub the same way.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainShellScreen(),
    ),

    // Module 2: Contacts — full-screen, pushed on top of the shell.
    GoRoute(
      path: AppRoutes.addContact,
      builder: (context, state) => const AddEditContactScreen(),
    ),
    GoRoute(
      path: AppRoutes.editContact,
      builder: (context, state) => AddEditContactScreen(
        contact: state.extra as TrustedContactModel?,
      ),
    ),

    // Module 3: Safety Timer & Check-In — also full-screen.
    GoRoute(
      path: AppRoutes.startSession,
      builder: (context, state) => const StartSessionScreen(),
    ),
    GoRoute(
      path: AppRoutes.activeSession,
      builder: (context, state) => const ActiveSessionScreen(),
    ),
  ],
);
