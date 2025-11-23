import 'package:flutter/foundation.dart';
import '../../domain/models/garden_bed.dart';
import '../../domain/repositories/garden_repository.dart';
import '../../models/plant.dart';
import '../../services/schedule_service.dart';

/// Provider for garden bed management
class GardenProvider extends ChangeNotifier {
  final GardenRepository _repository;
  List<GardenBed> _beds = [];
  bool _isLoading = false;
  
  // Undo history: Map of bedIndex to list of previous states
  final Map<int, List<GardenBed>> _undoHistory = {};
  static const int _maxUndoSteps = 20;

  GardenProvider(this._repository) {
    _loadBeds();
  }

  List<GardenBed> get beds => List.unmodifiable(_beds);
  bool get isLoading => _isLoading;
  int get bedCount => _beds.length;
  
  bool canUndo(int bedIndex) {
    return _undoHistory[bedIndex]?.isNotEmpty ?? false;
  }

  Future<void> _loadBeds() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _beds = await _repository.loadBeds();
    } catch (e) {
      debugPrint('Error loading beds: $e');
      _beds = [GardenBed.create(id: '1', name: 'Bed 1', rows: 8, cols: 4)];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveBeds() async {
    try {
      await _repository.saveBeds(_beds);
    } catch (e) {
      debugPrint('Error saving beds: $e');
    }
  }

  /// Add a new bed
  Future<void> addBed({String? name, int rows = 8, int cols = 4}) async {
    final newId = (beds.length + 1).toString();
    final bedName = name ?? 'Bed ${beds.length + 1}';
    _beds.add(GardenBed.create(id: newId, name: bedName, rows: rows, cols: cols));
    await _saveBeds();
    notifyListeners();
  }

  /// Remove a bed
  Future<void> removeBed(int index) async {
    if (index >= 0 && index < _beds.length) {
      _beds.removeAt(index);
      await _saveBeds();
      notifyListeners();
    }
  }

  /// Reorder beds
  Future<void> reorderBed(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final bed = _beds.removeAt(oldIndex);
    _beds.insert(newIndex, bed);
    await _saveBeds();
    notifyListeners();
  }

  /// Clear all plants from a bed
  Future<void> clearBedCells(int bedIndex) async {
    if (bedIndex >= 0 && bedIndex < _beds.length) {
      final bed = _beds[bedIndex];
      final clearedCells = List.generate(
        bed.rows * bed.cols,
        (i) => BedCell.empty(),
      );
      _beds[bedIndex] = bed.copyWith(cells: clearedCells);
      await _saveBeds();
      notifyListeners();
    }
  }

  /// Update bed properties
  Future<void> updateBed(int index, {String? name, int? rows, int? cols}) async {
    if (index >= 0 && index < _beds.length) {
      _beds[index] = _beds[index].copyWith(name: name, rows: rows, cols: cols);
      await _saveBeds();
      notifyListeners();
    }
  }

  /// Place a plant in a cell
  Future<void> placePlant(int bedIndex, int cellIndex, String plantCode) async {
    if (bedIndex >= 0 && bedIndex < _beds.length) {
      // Save current state for undo
      _saveUndoState(bedIndex);
      
      final bed = _beds[bedIndex];
      final updatedCell = bed.cellAt(cellIndex).copyWith(
        plantCode: () => plantCode,
      );
      _beds[bedIndex] = bed.updateCell(cellIndex, updatedCell);
      await _saveBeds();
      notifyListeners();
    }
  }

  /// Clear a cell
  Future<void> clearCell(int bedIndex, int cellIndex) async {
    if (bedIndex >= 0 && bedIndex < _beds.length) {
      // Save current state for undo
      _saveUndoState(bedIndex);
      
      _beds[bedIndex] = _beds[bedIndex].clearCell(cellIndex);
      await _saveBeds();
      notifyListeners();
    }
  }
  
  /// Save current bed state to undo history
  void _saveUndoState(int bedIndex) {
    if (bedIndex < 0 || bedIndex >= _beds.length) return;
    
    _undoHistory[bedIndex] ??= [];
    _undoHistory[bedIndex]!.add(_beds[bedIndex]);
    
    // Limit undo history size
    if (_undoHistory[bedIndex]!.length > _maxUndoSteps) {
      _undoHistory[bedIndex]!.removeAt(0);
    }
  }
  
  /// Undo the last planting operation for a bed
  Future<void> undoBed(int bedIndex) async {
    if (!canUndo(bedIndex)) return;
    
    final previousState = _undoHistory[bedIndex]!.removeLast();
    _beds[bedIndex] = previousState;
    
    await _saveBeds();
    notifyListeners();
  }

  /// Update cell note
  Future<void> updateCellNote(int bedIndex, int cellIndex, String? note) async {
    if (bedIndex >= 0 && bedIndex < _beds.length) {
      final bed = _beds[bedIndex];
      final updatedCell = bed.cellAt(cellIndex).copyWith(
        note: () => note,
      );
      _beds[bedIndex] = bed.updateCell(cellIndex, updatedCell);
      await _saveBeds();
      notifyListeners();
    }
  }

  /// Get all unique planted plants across all beds
  List<Plant> getUniquePlantedPlants() {
    final codes = <String>{};
    for (var bed in _beds) {
      codes.addAll(bed.plantedCodes);
    }
    return plants.where((p) => codes.contains(p.code)).toList();
  }

  /// Get calendar tasks for all placed plants
  List<PlantTask> calendarTasks(String zone) {
    final list = <PlantTask>[];
    for (final p in getUniquePlantedPlants()) {
      list.addAll(ScheduleService.makePlantTasks(p, zone));
    }
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    _beds = [GardenBed.create(id: '1', name: 'Bed 1', rows: 8, cols: 4)];
    await _saveBeds();
    notifyListeners();
  }
}
