import 'package:flutter/foundation.dart';
import '../../domain/repositories/garden_repository.dart';

/// Provider for plant notes management
class PlantNotesProvider extends ChangeNotifier {
  final GardenRepository _repository;
  Map<String, String> _plantNotes = {};

  PlantNotesProvider(this._repository) {
    _loadNotes();
  }

  Map<String, String> get plantNotes => Map.unmodifiable(_plantNotes);

  Future<void> _loadNotes() async {
    try {
      _plantNotes = await _repository.loadPlantNotes();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading plant notes: $e');
    }
  }

  /// Get note for a plant
  String? getNote(String plantCode) => _plantNotes[plantCode];

  /// Update note for a plant
  Future<void> updateNote(String plantCode, String? note) async {
    if (note == null || note.isEmpty) {
      _plantNotes.remove(plantCode);
    } else {
      _plantNotes[plantCode] = note;
    }
    await _repository.savePlantNotes(_plantNotes);
    notifyListeners();
  }

  /// Clear all notes
  Future<void> clearAllNotes() async {
    _plantNotes.clear();
    await _repository.savePlantNotes(_plantNotes);
    notifyListeners();
  }
}
