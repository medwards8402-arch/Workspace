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
  final int rows;
  final int cols;
  final List<BedCell> cells;
  GardenBed({required this.rows, required this.cols}) : cells = List.generate(rows * cols, (_) => BedCell());
}

class AppState extends ChangeNotifier {
  String _zone = '5a';
  String? _selectedPlantCode;
  int _currentNavIndex = 0;
  final int bedRows = 8;
  final int bedCols = 4;
  final int bedCount = 3;
  late final List<GardenBed> beds;
  final Map<String, String> plantNotes = {};

  AppState() {
    beds = List.generate(bedCount, (_) => GardenBed(rows: bedRows, cols: bedCols));
    _loadPrefs();
  }

  String get zone => _zone;
  int get currentNavIndex => _currentNavIndex;
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

  void selectPlant(String? code) {
    _selectedPlantCode = code;
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

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _zone = prefs.getString('zone') ?? _zone;
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
