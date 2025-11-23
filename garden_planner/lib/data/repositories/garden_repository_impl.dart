import '../../domain/models/garden_bed.dart';
import '../../domain/repositories/garden_repository.dart';
import '../sources/local_storage.dart';

/// Concrete implementation of GardenRepository using local storage
class GardenRepositoryImpl implements GardenRepository {
  final LocalStorage _storage;

  GardenRepositoryImpl(this._storage);

  @override
  Future<List<GardenBed>> loadBeds() => _storage.loadBeds();

  @override
  Future<void> saveBeds(List<GardenBed> beds) => _storage.saveBeds(beds);

  @override
  Future<String> loadZone() => _storage.loadZone();

  @override
  Future<void> saveZone(String zone) => _storage.saveZone(zone);

  @override
  Future<Map<String, String>> loadPlantNotes() => _storage.loadPlantNotes();

  @override
  Future<void> savePlantNotes(Map<String, String> notes) => _storage.savePlantNotes(notes);

  @override
  Future<Set<String>> loadDismissedTips() => _storage.loadDismissedTips();

  @override
  Future<void> saveDismissedTips(Set<String> tips) => _storage.saveDismissedTips(tips);

  @override
  Future<bool> loadShowPlantNames() => _storage.loadShowPlantNames();

  @override
  Future<void> saveShowPlantNames(bool show) => _storage.saveShowPlantNames(show);

  @override
  Future<void> clearAll() => _storage.clearAll();
}
