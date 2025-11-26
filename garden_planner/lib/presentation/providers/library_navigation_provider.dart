import 'package:flutter/foundation.dart';
import '../../models/plant.dart';

/// Provider for library navigation with plant selection
class LibraryNavigationProvider extends ChangeNotifier {
  Plant? _selectedPlant;
  String? _selectedTerm;

  Plant? get selectedPlant => _selectedPlant;
  String? get selectedTerm => _selectedTerm;

  void navigateToPlant(Plant plant) {
    _selectedPlant = plant;
    _selectedTerm = null;
    notifyListeners();
  }

  void navigateToTerm(String term) {
    _selectedTerm = term;
    _selectedPlant = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPlant = null;
    _selectedTerm = null;
  }
}
