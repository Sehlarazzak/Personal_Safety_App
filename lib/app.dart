import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routing/app_router.dart';
import 'core/session/session_controller.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/contacts_repository.dart';
import 'data/repositories/session_repository.dart';

/// Root widget and composition root.
///
/// This is the one place repositories get constructed and handed out via
/// `provider`, so every ViewModel below it can request what it needs with
/// `context.read<T>()` instead of constructing its own data-access layer.
/// Swapping Firebase implementations for fakes (Module 6 testing) means
/// changing only the three `Provider<...>` lines below.
class SafetyGuardApp extends StatelessWidget {
  const SafetyGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => FirebaseAuthRepository()),
        Provider<ContactsRepository>(create: (_) => FirestoreContactsRepository()),
        Provider<SessionRepository>(create: (_) => FirestoreSessionRepository()),

        // Shared across Home / Start Session / Active Session screens —
        // see SessionController's doc comment for why this lives here
        // instead of inside a single screen's ViewModel.
        ChangeNotifierProvider<SessionController>(
          create: (context) => SessionController(
            repository: context.read<SessionRepository>(),
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
