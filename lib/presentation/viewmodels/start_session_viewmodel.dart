import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/session/session_controller.dart';
import '../../data/models/trusted_contact_model.dart';
import '../../data/repositories/contacts_repository.dart';

/// Drives the "Start Session" screen — mirrors `start_safety_session/code.html`:
/// duration presets (15/30/60/custom), optional trip notes, and a guardian
/// contact picker, then hands off to the shared [SessionController] to
/// actually start the countdown.
class StartSessionViewModel extends ChangeNotifier {
  final ContactsRepository _contactsRepository;
  final SessionController sessionController;
  final String userId;

  StreamSubscription<List<TrustedContactModel>>? _contactsSubscription;

  StartSessionViewModel({
    required ContactsRepository contactsRepository,
    required this.sessionController,
    required this.userId,
  }) : _contactsRepository = contactsRepository {
    _contactsSubscription = _contactsRepository.watchContacts(userId).listen((list) {
      contacts = list;
      selectedGuardian ??= list.isNotEmpty ? list.first : null;
      notifyListeners();
    });
  }

  final notesController = TextEditingController();

  static const List<int> durationPresets = [15, 30, 60];

  int selectedDurationMinutes = 30;
  bool isCustomDuration = false;

  List<TrustedContactModel> contacts = [];
  TrustedContactModel? selectedGuardian;

  bool isSubmitting = false;
  String? errorMessage;

  void selectPresetDuration(int minutes) {
    selectedDurationMinutes = minutes;
    isCustomDuration = false;
    notifyListeners();
  }

  void setCustomDuration(int minutes) {
    if (minutes <= 0) return;
    selectedDurationMinutes = minutes;
    isCustomDuration = true;
    notifyListeners();
  }

  void selectGuardian(TrustedContactModel contact) {
    selectedGuardian = contact;
    notifyListeners();
  }

  /// Returns true once the session has actually started so the View can
  /// navigate to the Active Session screen.
  Future<bool> startSession() async {
    if (contacts.isNotEmpty && selectedGuardian == null) {
      errorMessage = 'Please choose a contact to notify.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await sessionController.startSession(
        userId: userId,
        durationMinutes: selectedDurationMinutes,
        notes: notesController.text,
        guardian: selectedGuardian,
      );
      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Could not start the session. Please try again.';
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _contactsSubscription?.cancel();
    notesController.dispose();
    super.dispose();
  }
}
