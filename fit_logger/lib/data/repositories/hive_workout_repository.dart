import 'package:hive/hive.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout_session.dart';
import '../../domain/models/workout_log.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/exercise_library.dart';
import '../models/workout_session_hive.dart';
import '../models/workout_log_hive.dart';

/// Concrete implementation of WorkoutRepository using Hive local storage
class HiveWorkoutRepository implements WorkoutRepository {
  Box<WorkoutSessionHive>? _sessionsBox;
  Box<WorkoutLogHive>? _logsBox;

  @override
  Future<void> initialize() async {
    _sessionsBox = await Hive.openBox<WorkoutSessionHive>(AppConstants.sessionsBox);
    _logsBox = await Hive.openBox<WorkoutLogHive>(AppConstants.logsBox);
  }

  @override
  Future<void> close() async {
    await _sessionsBox?.close();
    await _logsBox?.close();
  }

  void _ensureInitialized() {
    if (_sessionsBox == null || _logsBox == null) {
      throw Exception('Repository not initialized. Call initialize() first.');
    }
  }

  // ========== SESSION OPERATIONS ==========

  @override
  Future<List<WorkoutSession>> getAllSessions() async {
    _ensureInitialized();
    return _sessionsBox!.values
        .map((hive) => hive.toDomain())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
  }

  @override
  Future<WorkoutSession?> getSession(String id) async {
    _ensureInitialized();
    final hiveSession = _sessionsBox!.values.cast<WorkoutSessionHive?>().firstWhere(
          (s) => s?.id == id,
          orElse: () => null,
        );
    return hiveSession?.toDomain();
  }

  @override
  Future<List<WorkoutSession>> getSessionsByDay(WeekDay day) async {
    _ensureInitialized();
    return _sessionsBox!.values
        .where((s) => s.plannedDayIndex == day.index)
        .map((s) => s.toDomain())
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name)); // Alphabetical
  }

  @override
  Future<List<WorkoutSession>> getActiveSessions() async {
    _ensureInitialized();
    return _sessionsBox!.values
        .where((s) => s.isActive)
        .map((s) => s.toDomain())
        .toList()
      ..sort((a, b) {
        // Sort by plannedDay, then by name
        if (a.plannedDay != null && b.plannedDay != null) {
          final dayCompare = a.plannedDay!.index.compareTo(b.plannedDay!.index);
          if (dayCompare != 0) return dayCompare;
        } else if (a.plannedDay != null) {
          return -1; // Scheduled sessions first
        } else if (b.plannedDay != null) {
          return 1;
        }
        return a.name.compareTo(b.name);
      });
  }

  @override
  Future<void> saveSession(WorkoutSession session) async {
    _ensureInitialized();
    
    // Find existing session or create new key
    final existingIndex = _sessionsBox!.values
        .toList()
        .indexWhere((s) => s.id == session.id);
    
    final hiveSession = WorkoutSessionHive.fromDomain(session);
    
    if (existingIndex >= 0) {
      // Update existing
      await _sessionsBox!.putAt(existingIndex, hiveSession);
    } else {
      // Add new
      await _sessionsBox!.add(hiveSession);
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    _ensureInitialized();
    
    final index = _sessionsBox!.values
        .toList()
        .indexWhere((s) => s.id == id);
    
    if (index >= 0) {
      await _sessionsBox!.deleteAt(index);
    }
  }

  // ========== LOG OPERATIONS ==========

  @override
  Future<List<WorkoutLog>> getAllLogs() async {
    _ensureInitialized();
    return _logsBox!.values
        .map((hive) => hive.toDomain())
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
  }

  @override
  Future<List<WorkoutLog>> getWorkoutLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _ensureInitialized();
    
    var logs = _logsBox!.values.map((h) => h.toDomain());
    
    if (startDate != null) {
      logs = logs.where((log) => log.timestamp.isAfter(startDate) || 
                                   log.timestamp.isAtSameMomentAs(startDate));
    }
    
    if (endDate != null) {
      logs = logs.where((log) => log.timestamp.isBefore(endDate) || 
                                   log.timestamp.isAtSameMomentAs(endDate));
    }
    
    return logs.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<List<WorkoutLog>> getLogsForSession(String sessionId) async {
    _ensureInitialized();
    return _logsBox!.values
        .where((log) => log.sessionId == sessionId)
        .map((log) => log.toDomain())
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<WorkoutLog?> getLastLogForSession(String sessionId) async {
    _ensureInitialized();
    
    final logs = _logsBox!.values
        .where((log) => log.sessionId == sessionId)
        .map((log) => log.toDomain())
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return logs.isEmpty ? null : logs.first;
  }

  @override
  Future<WorkoutLog?> getLog(String id) async {
    _ensureInitialized();
    final hiveLog = _logsBox!.values.cast<WorkoutLogHive?>().firstWhere(
          (log) => log?.id == id,
          orElse: () => null,
        );
    return hiveLog?.toDomain();
  }

  @override
  Future<void> saveWorkoutLog(WorkoutLog log) async {
    _ensureInitialized();
    
    final hiveLog = WorkoutLogHive.fromDomain(log);
    await _logsBox!.add(hiveLog);
  }

  @override
  Future<void> updateWorkoutLog(WorkoutLog log) async {
    _ensureInitialized();
    
    final index = _logsBox!.values
        .toList()
        .indexWhere((l) => l.id == log.id);
    
    if (index >= 0) {
      final hiveLog = WorkoutLogHive.fromDomain(log);
      await _logsBox!.putAt(index, hiveLog);
    }
  }

  @override
  Future<void> deleteWorkoutLog(String id) async {
    _ensureInitialized();
    
    final index = _logsBox!.values
        .toList()
        .indexWhere((log) => log.id == id);
    
    if (index >= 0) {
      await _logsBox!.deleteAt(index);
    }
  }

  @override
  Future<void> deleteLog(String logId) async {
    await deleteWorkoutLog(logId);
  }

  @override
  Future<List<WorkoutLog>> getLogsBySession(String sessionId) async {
    _ensureInitialized();
    
    final logs = _logsBox!.values
        .where((log) => log.sessionId == sessionId)
        .map((log) => log.toDomain())
        .toList();
    
    return logs;
  }

  // ========== EXERCISE OPERATIONS (Read-Only from Library) ==========

  @override
  List<Exercise> getAllExercises() {
    return ExerciseLibrary.getAllExercises();
  }

  @override
  Exercise? getExercise(String id) {
    return ExerciseLibrary.getExercise(id);
  }

  @override
  List<Exercise> getExercisesByCategory(ExerciseCategory category) {
    return ExerciseLibrary.getExercisesByCategory(category);
  }

  @override
  List<Exercise> getExercisesByMeasurementType(MeasurementType type) {
    return ExerciseLibrary.getExercisesByMeasurementType(type);
  }

  @override
  List<Exercise> searchExercises(String query) {
    return ExerciseLibrary.searchExercises(query);
  }
}
