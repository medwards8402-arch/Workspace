import 'package:flutter/foundation.dart';
import '../../domain/repositories/garden_repository.dart';

/// Provider for settings management
class SettingsProvider extends ChangeNotifier {
  final GardenRepository _repository;
  
  String _zone = '5a';
  bool _showPlantNames = true;
  Set<String> _dismissedTips = {};
  bool _isLoading = false;

  SettingsProvider(this._repository) {
    _loadSettings();
  }

  String get zone => _zone;
  bool get showPlantNames => _showPlantNames;
  bool get isLoading => _isLoading;

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _zone = await _repository.loadZone();
      _showPlantNames = await _repository.loadShowPlantNames();
      _dismissedTips = await _repository.loadDismissedTips();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set zone
  Future<void> setZone(String newZone) async {
    _zone = newZone;
    await _repository.saveZone(newZone);
    notifyListeners();
  }

  /// Toggle show plant names
  Future<void> toggleShowPlantNames() async {
    _showPlantNames = !_showPlantNames;
    await _repository.saveShowPlantNames(_showPlantNames);
    notifyListeners();
  }

  /// Dismiss a tip
  Future<void> dismissTip(String tipId) async {
    _dismissedTips.add(tipId);
    await _repository.saveDismissedTips(_dismissedTips);
    notifyListeners();
  }

  /// Check if tip is dismissed
  bool isTipDismissed(String tipId) => _dismissedTips.contains(tipId);

  /// Reset all tips
  Future<void> resetAllTips() async {
    _dismissedTips.clear();
    await _repository.saveDismissedTips(_dismissedTips);
    notifyListeners();
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    _zone = '5a';
    _showPlantNames = true;
    _dismissedTips.clear();
    
    await _repository.saveZone(_zone);
    await _repository.saveShowPlantNames(_showPlantNames);
    await _repository.saveDismissedTips(_dismissedTips);
    
    notifyListeners();
  }
}
