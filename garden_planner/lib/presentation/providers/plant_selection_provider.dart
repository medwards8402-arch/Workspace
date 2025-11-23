import 'package:flutter/foundation.dart';
import '../../models/plant.dart';

/// Provider for plant selection and filtering
class PlantSelectionProvider extends ChangeNotifier {
  String? _selectedPlantCode;
  String _filterType = 'all';
  String _filterLight = 'all';
  String _searchQuery = '';

  String? get selectedPlantCode => _selectedPlantCode;
  String get filterType => _filterType;
  String get filterLight => _filterLight;
  String get searchQuery => _searchQuery;

  Plant? get selectedPlant {
    if (_selectedPlantCode == null) return null;
    try {
      return plants.firstWhere((p) => p.code == _selectedPlantCode);
    } catch (_) {
      return null;
    }
  }

  /// Select a plant
  void selectPlant(String? code) {
    _selectedPlantCode = code;
    notifyListeners();
  }

  /// Set filters
  void setFilter({String? type, String? light, String? search}) {
    if (type != null) _filterType = type;
    if (light != null) _filterLight = light;
    if (search != null) _searchQuery = search;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _filterType = 'all';
    _filterLight = 'all';
    _searchQuery = '';
    notifyListeners();
  }

  /// Get filtered plants
  List<Plant> getFilteredPlants() {
    return plants.where((plant) {
      final typeMatch = _filterType == 'all' || plant.type == _filterType;
      final lightMatch = _filterLight == 'all' || plant.lightLevel == _filterLight;
      final searchMatch = _searchQuery.isEmpty || 
        plant.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return typeMatch && lightMatch && searchMatch;
    }).toList();
  }
}
