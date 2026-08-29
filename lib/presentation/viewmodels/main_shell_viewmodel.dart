import 'package:flutter/foundation.dart';

/// Tracks which bottom-navigation tab is selected in [MainShellScreen].
/// Kept as its own tiny ViewModel so navigation state doesn't leak into
/// each individual tab's ViewModel.
class MainShellViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void selectTab(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }
}
