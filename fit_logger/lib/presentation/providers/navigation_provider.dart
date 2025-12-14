import 'package:flutter/foundation.dart';

/// Provider for managing bottom navigation state
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (index != _currentIndex && index >= 0 && index < 3) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
