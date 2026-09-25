import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/services/contact_launcher.dart';
import 'core/services/notification_service.dart';
import 'core/session/session_controller.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/contacts_repository.dart';
import 'data/repositories/location_repository.dart';
import 'data/repositories/session_repository.dart';

/// Root widget and composition root.
///
/// This is the one place repositories/services get constructed and handed
/// out via `provider`, so every ViewModel below it can request what it
/// needs with `context.read<T>()` instead of constructing its own
/// data-access layer. Swapping Firebase implementations for fakes
/// (Module 6 testing) means changing only the `Provider<...>` lines below.
class SafetyGuardApp extends StatelessWidget {
  /// Created and `initialize()`d in `main.dart` before `runApp` — passed
  /// in rather than constructed here so its async setup (permission
  /// requests, plugin registration) has already completed by the time any
  /// screen might try to use it.
  final NotificationService notificationService;

  const SafetyGuardApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => FirebaseAuthRepository()),
        Provider<ContactsRepository>(create: (_) => FirestoreContactsRepository()),
        Provider<SessionRepository>(create: (_) => FirestoreSessionRepository()),

        // Module 4: device location and platform-launcher (call/SMS/Maps).
        Provider<LocationRepository>(create: (_) => GeolocatorLocationRepository()),
        Provider<ContactLauncher>(create: (_) => ContactLauncher()),
        Provider<NotificationService>.value(value: notificationService),

        // Shared across Home / Start Session / Active Session / Emergency
        // Hub / Location Status screens — see SessionController's doc
        // comment for why this lives here instead of inside a single
        // screen's ViewModel.
        ChangeNotifierProvider<SessionController>(
          create: (context) => SessionController(
            sessionRepository: context.read<SessionRepository>(),
            locationRepository: context.read<LocationRepository>(),
            contactLauncher: context.read<ContactLauncher>(),
            notificationService: context.read<NotificationService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Safety Guard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
