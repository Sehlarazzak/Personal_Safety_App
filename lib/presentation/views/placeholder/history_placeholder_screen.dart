import 'package:flutter/material.dart';
import 'placeholder_screen.dart';

class HistoryPlaceholderScreen extends StatelessWidget {
  const HistoryPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Safety History',
      icon: Icons.history,
      moduleNote: 'A chronological log of completed and escalated sessions — built in Module 5.',
    );
  }
}
