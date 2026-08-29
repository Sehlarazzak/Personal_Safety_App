import 'package:go_router/go_router.dart';
import '../../presentation/views/auth/login_screen.dart';
import '../../presentation/views/auth/registration_screen.dart';
import '../../presentation/views/shell/main_shell_screen.dart';
import '../../presentation/views/splash/splash_screen.dart';
import 'app_routes.dart';

/// Single source of truth for navigation.
///
/// Module 1 keeps this flat (Splash -> Login/Register -> Shell). Later
/// modules add nested routes for the session flow (start/active/complete)
/// and the emergency hub without touching this file's overall shape.
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
  ],
);
