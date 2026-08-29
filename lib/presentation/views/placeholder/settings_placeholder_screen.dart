import 'package:flutter/material.dart';
import 'placeholder_screen.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Settings & Profile',
      icon: Icons.settings_outlined,
      moduleNote: 'Profile, permissions, and app preferences — built in Module 5.',
    );
  }
}
