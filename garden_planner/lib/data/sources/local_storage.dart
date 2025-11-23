import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/garden_bed.dart';

/// Local storage implementation using SharedPreferences
class LocalStorage {
  static const String _keyBedConfigs = 'bedConfigs';
  static const String _keyBedCells = 'beds';
  static const String _keyZone = 'zone';
  static const String _keyPlantNotes = 'plantNotes';
  static const String _keyDismissedTips = 'dismissedTips';
  static const String _keyShowPlantNames = 'showPlantNames';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  /// Factory to create instance
  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  /// Save beds
  Future<void> saveBeds(List<GardenBed> beds) async {
    // Save bed configurations
    final bedConfigs = beds.map((bed) => '${bed.id}|${bed.name}|${bed.rows}|${bed.cols}').toList();
    await _prefs.setStringList(_keyBedConfigs, bedConfigs);

    // Save cell data
    final bedEncoded = <String>[];
    for (var b = 0; b < beds.length; b++) {
      final bed = beds[b];
      for (var c = 0; c < bed.cells.length; c++) {
        final cell = bed.cells[c];
        if (cell.plantCode != null || cell.hasNote) {
          bedEncoded.add('$b|$c|${cell.plantCode ?? ''}|${cell.note ?? ''}');
        }
      }
    }
    await _prefs.setStringList(_keyBedCells, bedEncoded);
  }

  /// Load beds
  Future<List<GardenBed>> loadBeds() async {
    final bedConfigs = _prefs.getStringList(_keyBedConfigs) ?? [];
    
    if (bedConfigs.isEmpty) {
      // Return default bed
      return [
        GardenBed.create(id: '1', name: 'Bed 1', rows: 8, cols: 4),
      ];
    }

    // Parse bed configurations
    final beds = <GardenBed>[];
    for (final config in bedConfigs) {
      final parts = config.split('|');
      if (parts.length >= 4) {
        final id = parts[0];
        final name = parts[1];
        final rows = int.tryParse(parts[2]) ?? 8;
        final cols = int.tryParse(parts[3]) ?? 4;
        beds.add(GardenBed.create(id: id, name: name, rows: rows, cols: cols));
      }
    }

    // Load cell data
    final bedData = _prefs.getStringList(_keyBedCells) ?? [];
    for (final entry in bedData) {
      final parts = entry.split('|');
      if (parts.length >= 4) {
        final b = int.tryParse(parts[0]);
        final c = int.tryParse(parts[1]);
        if (b != null && c != null && b < beds.length && c < beds[b].cells.length) {
          final plantCode = parts[2].isEmpty ? null : parts[2];
          final note = parts.length > 3 && parts[3].isNotEmpty ? parts.sublist(3).join('|') : null;
          
          final updatedCell = BedCell(plantCode: plantCode, note: note);
          beds[b] = beds[b].updateCell(c, updatedCell);
        }
      }
    }

    return beds;
  }

  /// Save zone
  Future<void> saveZone(String zone) async {
    await _prefs.setString(_keyZone, zone);
  }

  /// Load zone
  Future<String> loadZone() async {
    return _prefs.getString(_keyZone) ?? '5a';
  }

  /// Save plant notes
  Future<void> savePlantNotes(Map<String, String> notes) async {
    final encoded = notes.entries.map((e) => '${e.key}|${e.value}').toList();
    await _prefs.setStringList(_keyPlantNotes, encoded);
  }

  /// Load plant notes
  Future<Map<String, String>> loadPlantNotes() async {
    final storedNotes = _prefs.getStringList(_keyPlantNotes) ?? [];
    final notes = <String, String>{};
    for (final entry in storedNotes) {
      final parts = entry.split('|');
      if (parts.length >= 2) {
        notes[parts[0]] = parts.sublist(1).join('|');
      }
    }
    return notes;
  }

  /// Save dismissed tips
  Future<void> saveDismissedTips(Set<String> tips) async {
    await _prefs.setStringList(_keyDismissedTips, tips.toList());
  }

  /// Load dismissed tips
  Future<Set<String>> loadDismissedTips() async {
    final dismissedList = _prefs.getStringList(_keyDismissedTips) ?? [];
    return dismissedList.toSet();
  }

  /// Save show plant names
  Future<void> saveShowPlantNames(bool show) async {
    await _prefs.setBool(_keyShowPlantNames, show);
  }

  /// Load show plant names
  Future<bool> loadShowPlantNames() async {
    return _prefs.getBool(_keyShowPlantNames) ?? true;
  }

  /// Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
