import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root widget: wires the design-system theme to the go_router
/// configuration. Nothing else lives here on purpose — this file should
/// stay stable as the app grows through later modules.
class SafetyGuardApp extends StatelessWidget {
  const SafetyGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Safety Guard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
