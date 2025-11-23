import '../models/garden_bed.dart';

/// Abstract repository for garden persistence
abstract class GardenRepository {
  /// Load all beds
  Future<List<GardenBed>> loadBeds();
  
  /// Save all beds
  Future<void> saveBeds(List<GardenBed> beds);
  
  /// Load zone setting
  Future<String> loadZone();
  
  /// Save zone setting
  Future<void> saveZone(String zone);
  
  /// Load plant notes
  Future<Map<String, String>> loadPlantNotes();
  
  /// Save plant notes
  Future<void> savePlantNotes(Map<String, String> notes);
  
  /// Load dismissed tips
  Future<Set<String>> loadDismissedTips();
  
  /// Save dismissed tips
  Future<void> saveDismissedTips(Set<String> tips);
  
  /// Load show plant names setting
  Future<bool> loadShowPlantNames();
  
  /// Save show plant names setting
  Future<void> saveShowPlantNames(bool show);
  
  /// Clear all data
  Future<void> clearAll();
}
