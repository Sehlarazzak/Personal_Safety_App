import 'dart:async';
import 'package:flutter/foundation.dart';

/// Drives the Splash screen: cycles the reassuring status messages and
/// decides where to navigate once "boot" is done.
///
/// Module 1 has no real session/auth check yet, so [checkSession] just
/// simulates a short delay. Module 2 will replace the body of this method
/// with an actual Firebase Auth state check without touching the View.
class SplashViewModel extends ChangeNotifier {
  static const List<String> _messages = [
    'Checking your session...',
    'Authenticating credentials...',
    'Syncing safety contacts...',
    'Securing connection...',
  ];

  int _messageIndex = 0;
  Timer? _messageTimer;
  bool _isReady = false;

  String get statusMessage => _messages[_messageIndex];
  bool get isReady => _isReady;

  /// Whether the splash flow concluded that a user is already signed in.
  /// Placeholder for Module 2's real auth check.
  bool isAuthenticated = false;

  void startBootSequence() {
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      _messageIndex = (_messageIndex + 1) % _messages.length;
      notifyListeners();
    });

    // Simulated minimum splash duration so the brand moment isn't a flash.
    Future.delayed(const Duration(milliseconds: 2200), () {
      _isReady = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }
}
