import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/session/session_controller.dart';
import '../../data/models/safety_session_status.dart';
import '../../data/models/trusted_contact_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/contacts_repository.dart';

/// Drives the Home Dashboard: current user, live session status, and the
/// trusted-contacts summary.
///
/// Module 1 seeded this with local mock data. Module 2/3 replace that with
/// real data: [ContactsRepository] for the live contacts stream, and the
/// shared [SessionController] for the actual session status — the dashboard
/// simply listens to both rather than owning any of that state itself.
class HomeViewModel extends ChangeNotifier {
  final ContactsRepository _contactsRepository;
  final SessionController sessionController;

  UserModel currentUser;
  List<TrustedContactModel> contacts = [];
  bool isLoading = true;

  StreamSubscription<List<TrustedContactModel>>? _contactsSubscription;

  HomeViewModel({
    required AuthRepository authRepository,
    required ContactsRepository contactsRepository,
    required this.sessionController,
  })  : _contactsRepository = contactsRepository,
        currentUser = authRepository.currentUser ?? UserModel.guest() {
    sessionController.addListener(_onSessionChanged);
    _listenToContacts();
  }

  void _onSessionChanged() => notifyListeners();

  SafetySessionStatus get sessionStatus => sessionController.status;

  List<TrustedContactModel> get primaryContacts =>
      contacts.where((c) => c.isPrimary).toList();

  String get sessionSubtitle {
    switch (sessionStatus) {
      case SafetySessionStatus.none:
        return 'You are currently unmonitored.';
      case SafetySessionStatus.active:
        return 'Your session is being monitored.';
      case SafetySessionStatus.awaitingCheckIn:
        return 'Please confirm you are safe.';
      case SafetySessionStatus.completedSafe:
        return 'Nice work — you checked in safely.';
      case SafetySessionStatus.escalated:
        return 'Your trusted contacts have been notified.';
      case SafetySessionStatus.cancelled:
        return 'Your last session was cancelled.';
    }
  }

  void _listenToContacts() {
    isLoading = true;
    notifyListeners();

    _contactsSubscription = _contactsRepository.watchContacts(currentUser.id).listen(
      (list) {
        contacts = list;
        isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    await _contactsSubscription?.cancel();
    _listenToContacts();
  }

  @override
  void dispose() {
    sessionController.removeListener(_onSessionChanged);
    _contactsSubscription?.cancel();
    super.dispose();
  }
}
