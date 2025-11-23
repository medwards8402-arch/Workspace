import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/plant.dart';
import 'services/schedule_service.dart';

class BedCell {
  String? plantCode;
  String? note;
  BedCell({this.plantCode, this.note});
}

class GardenBed {
  final String name;
  final int rows;
  final int cols;
  final List<BedCell> cells;
  GardenBed({required this.name, required this.rows, required this.cols}) 
    : cells = List.generate(rows * cols, (_) => BedCell());
  
  GardenBed copyWith({String? name, int? rows, int? cols}) {
    final newRows = rows ?? this.rows;
    final newCols = cols ?? this.cols;
    final newBed = GardenBed(name: name ?? this.name, rows: newRows, cols: newCols);
    // Copy existing cells where possible
    for (var r = 0; r < newRows && r < this.rows; r++) {
      for (var c = 0; c < newCols && c < this.cols; c++) {
        final oldIndex = r * this.cols + c;
        final newIndex = r * newCols + c;
        newBed.cells[newIndex] = this.cells[oldIndex];
      }
    }
    return newBed;
  }
}

class AppState extends ChangeNotifier {
  String _zone = '5a';
  String? _selectedPlantCode;
  int _currentNavIndex = 0;
  bool _showPlantNames = true; // Default to true
  String _plantFilterType = 'all';
  String _plantFilterLight = 'all';
  String _plantSearchQuery = '';
  Set<String> _dismissedTips = {};
  List<GardenBed> beds = [];
  final Map<String, String> plantNotes = {};

  AppState() {
    // Initialize with default beds
    beds = [
      GardenBed(name: 'Bed 1', rows: 4, cols: 8),
      GardenBed(name: 'Bed 2', rows: 4, cols: 8),
      GardenBed(name: 'Bed 3', rows: 4, cols: 8),
      GardenBed(name: 'Herb Garden', rows: 2, cols: 4),
    ];
    _loadPrefs();
  }

  String get zone => _zone;
  int get currentNavIndex => _currentNavIndex;
  bool get showPlantNames => _showPlantNames;
  String get plantFilterType => _plantFilterType;
  String get plantFilterLight => _plantFilterLight;
  String get plantSearchQuery => _plantSearchQuery;
  String? get selectedPlantCode => _selectedPlantCode;
  Plant? get selectedPlant {
    if (_selectedPlantCode == null) return null;
    try {
      return plants.firstWhere((p) => p.code == _selectedPlantCode);
    } catch (_) {
      return null;
    }
  }

  List<Plant> get allPlants => plants;

  void setZone(String z) {
    _zone = z;
    _savePrefs();
    notifyListeners();
  }

  void addBed({String? name, int rows = 8, int cols = 4}) {
    final bedName = name ?? 'Bed ${beds.length + 1}';
    beds.add(GardenBed(name: bedName, rows: rows, cols: cols));
    _savePrefs();
    notifyListeners();
  }

  void removeBed(int index) {
    if (index >= 0 && index < beds.length) {
      beds.removeAt(index);
      _savePrefs();
      notifyListeners();
    }
  }

  void updateBed(int index, {String? name, int? rows, int? cols}) {
    if (index >= 0 && index < beds.length) {
      beds[index] = beds[index].copyWith(name: name, rows: rows, cols: cols);
      _savePrefs();
      notifyListeners();
    }
  }

  void selectPlant(String? code) {
    _selectedPlantCode = code;
    notifyListeners();
  }

  void toggleShowPlantNames() {
    _showPlantNames = !_showPlantNames;
    notifyListeners();
  }

  void setPlantFilter({String? type, String? light, String? search}) {
    if (type != null) _plantFilterType = type;
    if (light != null) _plantFilterLight = light;
    if (search != null) _plantSearchQuery = search;
    notifyListeners();
  }

  void dismissTip(String tipId) {
    _dismissedTips.add(tipId);
    _savePrefs();
    notifyListeners();
  }

  bool isTipDismissed(String tipId) => _dismissedTips.contains(tipId);

  void resetAllTips() {
    _dismissedTips.clear();
    _savePrefs();
    notifyListeners();
  }

  void setNavIndex(int i) {
    _currentNavIndex = i;
    notifyListeners();
  }

  void placeSelectedPlant(int bedIndex, int cellIndex) {
    if (_selectedPlantCode == null) return;
    final bed = beds[bedIndex];
    bed.cells[cellIndex].plantCode = _selectedPlantCode;
    _savePrefs();
    notifyListeners();
  }

  void clearCell(int bedIndex, int cellIndex) {
    final bed = beds[bedIndex];
    bed.cells[cellIndex].plantCode = null;
    bed.cells[cellIndex].note = null;
    _savePrefs();
    notifyListeners();
  }

  void updateCellNote(int bedIndex, int cellIndex, String? note) {
    beds[bedIndex].cells[cellIndex].note = note;
    _savePrefs();
    notifyListeners();
  }

  void updatePlantNote(String plantCode, String? note) {
    if (note == null || note.isEmpty) {
      plantNotes.remove(plantCode);
    } else {
      plantNotes[plantCode] = note;
    }
    _savePrefs();
    notifyListeners();
  }

  List<Plant> uniquePlacedPlants() {
    final codes = <String>{};
    for (var bed in beds) {
      for (var cell in bed.cells) {
        if (cell.plantCode != null) codes.add(cell.plantCode!);
      }
    }
    return plants.where((p) => codes.contains(p.code)).toList();
  }

  List<PlantTask> calendarTasks() {
    final list = <PlantTask>[];
    for (final p in uniquePlacedPlants()) {
      list.addAll(ScheduleService.makePlantTasks(p, _zone));
    }
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Future<void> resetToDefaults() async {
    _zone = '5a';
    _selectedPlantCode = null;
    _currentNavIndex = 0;
    _showPlantNames = true;
    _plantFilterType = 'all';
    _plantFilterLight = 'all';
    _plantSearchQuery = '';
    _dismissedTips.clear();
    beds = [
      GardenBed(name: 'Bed 1', rows: 8, cols: 4),
    ];
    plantNotes.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _zone = prefs.getString('zone') ?? _zone;
    _showPlantNames = prefs.getBool('showPlantNames') ?? _showPlantNames;
    final dismissedList = prefs.getStringList('dismissedTips') ?? [];
    _dismissedTips = dismissedList.toSet();
    
    // Load bed configurations
    final bedConfigs = prefs.getStringList('bedConfigs') ?? [];
    if (bedConfigs.isNotEmpty) {
      beds.clear();
      for (final config in bedConfigs) {
        final parts = config.split('|');
        if (parts.length == 3) {
          final name = parts[0];
          final rows = int.tryParse(parts[1]) ?? 8;
          final cols = int.tryParse(parts[2]) ?? 4;
          beds.add(GardenBed(name: name, rows: rows, cols: cols));
        }
      }
    }
    
    final storedPlantNotes = prefs.getStringList('plantNotes') ?? [];
    for (final entry in storedPlantNotes) {
      final parts = entry.split('|');
      if (parts.length == 2) plantNotes[parts[0]] = parts[1];
    }
    final bedData = prefs.getStringList('beds') ?? [];
    for (final entry in bedData) {
      final parts = entry.split('|');
      if (parts.length >= 4) {
        final b = int.tryParse(parts[0]);
        final c = int.tryParse(parts[1]);
        if (b != null && c != null && b < beds.length && c < beds[b].cells.length) {
          final plantCode = parts[2].isEmpty ? null : parts[2];
          final note = parts[3].isEmpty ? null : parts.sublist(3).join('|');
          beds[b].cells[c].plantCode = plantCode;
          beds[b].cells[c].note = note;
        }
      }
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('zone', _zone);
    prefs.setBool('showPlantNames', _showPlantNames);
    prefs.setStringList('dismissedTips', _dismissedTips.toList());
    
    // Save bed configurations
    final bedConfigs = beds.map((bed) => '${bed.name}|${bed.rows}|${bed.cols}').toList();
    prefs.setStringList('bedConfigs', bedConfigs);
    
    final encoded = plantNotes.entries.map((e) => '${e.key}|${e.value}').toList();
    prefs.setStringList('plantNotes', encoded);
    final bedEncoded = <String>[];
    for (var b = 0; b < beds.length; b++) {
      final bed = beds[b];
      for (var c = 0; c < bed.cells.length; c++) {
        final cell = bed.cells[c];
        if (cell.plantCode != null || (cell.note != null && cell.note!.isNotEmpty)) {
          bedEncoded.add('$b|$c|${cell.plantCode ?? ''}|${cell.note ?? ''}');
        }
      }
    }
    prefs.setStringList('beds', bedEncoded);
  }
}
