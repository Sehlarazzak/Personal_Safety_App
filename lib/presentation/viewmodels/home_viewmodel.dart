import 'package:flutter/foundation.dart';
import '../../data/models/safety_session_status.dart';
import '../../data/models/trusted_contact_model.dart';
import '../../data/models/user_model.dart';

/// Drives the Home Dashboard: current user, session status, and the
/// trusted-contacts summary.
///
/// Module 1 seeds this with local mock data so the dashboard is fully
/// navigable and visually complete. Modules 2-4 replace [_loadDashboard]
/// with real repository calls (Firestore contacts, live session state,
/// GPS/notification wiring) without the View needing to change.
class HomeViewModel extends ChangeNotifier {
  UserModel currentUser = UserModel.guest();
  SafetySessionStatus sessionStatus = SafetySessionStatus.none;
  List<TrustedContactModel> primaryContacts = [];
  bool isLoading = true;

  HomeViewModel() {
    _loadDashboard();
  }

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
    }
  }

  Future<void> _loadDashboard() async {
    isLoading = true;
    notifyListeners();

    // TODO(Module 2/3): fetch the real signed-in user and live session
    // state instead of this mock data.
    await Future.delayed(const Duration(milliseconds: 400));

    currentUser = const UserModel(
      id: 'demo-user',
      fullName: 'Jane Doe',
      email: 'jane.doe@example.com',
    );
    sessionStatus = SafetySessionStatus.none;
    primaryContacts = const [
      TrustedContactModel(
        id: 'c1',
        name: 'John Doe',
        phoneNumber: '+1 555-0100',
        isPrimary: true,
      ),
    ];

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _loadDashboard();
}
