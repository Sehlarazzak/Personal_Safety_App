import 'package:flutter/material.dart';
import 'placeholder_screen.dart';

class ContactsPlaceholderScreen extends StatelessWidget {
  const ContactsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Emergency Contacts',
      icon: Icons.contacts_outlined,
      moduleNote: 'Add, edit, and manage trusted contacts here — built in Module 2.',
    );
  }
}
