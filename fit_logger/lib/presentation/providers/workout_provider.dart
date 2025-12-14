import 'package:flutter/foundation.dart';
import '../../domain/models/workout_session.dart';
import '../../domain/models/workout_log.dart';
import '../../domain/models/exercise_log.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../services/workout_service.dart';
import '../../services/prefill_service.dart';
import '../../services/week_reset_service.dart';
import '../../core/constants/enums.dart';

/// Provider for workout-related state and operations
class WorkoutProvider with ChangeNotifier {
  final WorkoutService _workoutService;
  final PrefillService _prefillService;
  final WeekResetService _resetService;

  WorkoutProvider({
    required WorkoutRepository repository,
  })  : _workoutService = WorkoutService(repository),
        _prefillService = PrefillService(repository),
        _resetService = WeekResetService(repository);

  // State
  List<WorkoutSession> _sessions = [];
  List<WorkoutLog> _recentLogs = [];
  List<WorkoutLog> _filteredLogs = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<WorkoutSession> get sessions => _sessions;
  List<WorkoutSession> get activeSessions => 
      _sessions.where((s) => s.isActive).toList();
  List<WorkoutLog> get recentLogs => _recentLogs;
  List<WorkoutLog> get filteredLogs => _filteredLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ========== INITIALIZATION ==========

  /// Initialize and check for weekly reset
  Future<void> initialize() async {
    await loadSessions();
    await checkWeeklyReset();
    await loadRecentLogs();
  }

  /// Check and perform weekly reset if needed
  Future<bool> checkWeeklyReset() async {
    try {
      final wasReset = await _resetService.checkAndResetWeek();
      if (wasReset) {
        await loadSessions(); // Reload sessions after reset
      }
      return wasReset;
    } catch (e) {
      _error = 'Failed to check weekly reset: $e';
      notifyListeners();
      return false;
    }
  }

  // ========== SESSION OPERATIONS ==========

  /// Load all sessions
  Future<void> loadSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _workoutService._repository.getAllSessions();
    } catch (e) {
      _error = 'Failed to load sessions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new session
  Future<WorkoutSession?> createSession({
    required String name,
    List<String> exerciseIds = const [],
    WeekDay? plannedDay,
  }) async {
    try {
      final session = await _workoutService.createSession(
        name: name,
        exerciseIds: exerciseIds,
        plannedDay: plannedDay,
      );
      await loadSessions();
      return session;
    } catch (e) {
      _error = 'Failed to create session: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update a session
  Future<void> updateSession(WorkoutSession session) async {
    try {
      await _workoutService.updateSession(session);
      await loadSessions();
    } catch (e) {
      _error = 'Failed to update session: $e';
      notifyListeners();
    }
  }

  /// Delete a session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _workoutService.deleteSession(sessionId);
      await loadSessions();
    } catch (e) {
      _error = 'Failed to delete session: $e';
      notifyListeners();
    }
  }

  /// Toggle session active status
  Future<void> toggleSessionActive(String sessionId) async {
    try {
      await _workoutService.toggleSessionActive(sessionId);
      await loadSessions();
    } catch (e) {
      _error = 'Failed to toggle session: $e';
      notifyListeners();
    }
  }

  /// Add exercise to session
  Future<void> addExerciseToSession(String sessionId, String exerciseId) async {
    try {
      await _workoutService.addExerciseToSession(sessionId, exerciseId);
      await loadSessions();
    } catch (e) {
      _error = 'Failed to add exercise: $e';
      notifyListeners();
    }
  }

  /// Remove exercise from session
  Future<void> removeExerciseFromSession(String sessionId, String exerciseId) async {
    try {
      await _workoutService.removeExerciseFromSession(sessionId, exerciseId);
      await loadSessions();
    } catch (e) {
      _error = 'Failed to remove exercise: $e';
      notifyListeners();
    }
  }

  /// Reorder exercises in session
  Future<void> reorderExercises(String sessionId, List<String> newOrder) async {
    try {
      await _workoutService.reorderExercises(sessionId, newOrder);
      await loadSessions();
    } catch (e) {
      _error = 'Failed to reorder exercises: $e';
      notifyListeners();
    }
  }

  // ========== WORKOUT LOGGING ==========

  /// Log a completed workout
  Future<WorkoutLog?> logWorkout({
    required String sessionId,
    required String sessionName,
    required List<ExerciseLog> exerciseLogs,
    Duration? totalDuration,
    String? notes,
  }) async {
    try {
      final log = await _workoutService.logWorkout(
        sessionId: sessionId,
        sessionName: sessionName,
        exerciseLogs: exerciseLogs,
        totalDuration: totalDuration,
        notes: notes,
      );
      await loadSessions(); // Reload to update completion status
      await loadRecentLogs();
      return log;
    } catch (e) {
      _error = 'Failed to log workout: $e';
      notifyListeners();
      return null;
    }
  }

  /// Uncheck session completion (allow redo)
  Future<void> uncheckSessionCompletion(String sessionId) async {
    try {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      final updated = session.copyWith(
        completedThisWeek: false,
        lastCompletedDate: null,
      );
      await _workoutService.updateSession(updated);
      await loadSessions();
    } catch (e) {
      _error = 'Failed to uncheck session: $e';
      notifyListeners();
    }
  }

  /// Load recent workout logs
  Future<void> loadRecentLogs({int days = 30}) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      _recentLogs = await _workoutService.getLogsInRange(
        startDate: startDate,
        endDate: now,
      );
      _filteredLogs = _recentLogs;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load logs: $e';
      notifyListeners();
    }
  }

  /// Load logs within a date range with optional session filter
  Future<void> loadLogsInRange({
    required DateTime startDate,
    required DateTime endDate,
    String? sessionId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      _recentLogs = await _workoutService.getLogsInRange(
        startDate: startDate,
        endDate: endDate,
      );

      if (sessionId != null) {
        _filteredLogs = _recentLogs.where((log) => log.sessionId == sessionId).toList();
      } else {
        _filteredLogs = _recentLogs;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load logs: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a workout log
  Future<void> deleteWorkoutLog(String logId) async {
    try {
      await _workoutService.deleteLog(logId);
      await loadRecentLogs();
    } catch (e) {
      _error = 'Failed to delete log: $e';
      notifyListeners();
    }
  }

  /// Get exercise history for comparison
  Future<List<ExerciseLog>> getExerciseHistory({
    required String sessionId,
    required String exerciseId,
    int limit = 10,
  }) async {
    try {
      return await _workoutService.getExerciseHistory(
        sessionId: sessionId,
        exerciseId: exerciseId,
        limit: limit,
      );
    } catch (e) {
      _error = 'Failed to get exercise history: $e';
      notifyListeners();
      return [];
    }
  }

  // ========== PRE-FILL & SUGGESTIONS ==========

  /// Get pre-filled data for an exercise
  Future<ExerciseLog?> getPrefillData({
    required String sessionId,
    required String exerciseId,
  }) async {
    try {
      return await _prefillService.getPrefillData(
        sessionId: sessionId,
        exerciseId: exerciseId,
      );
    } catch (e) {
      _error = 'Failed to get prefill data: $e';
      notifyListeners();
      return null;
    }
  }

  /// Get workout suggestion
  Future<String> getWorkoutSuggestion(String sessionId) async {
    try {
      return await _prefillService.getWorkoutSuggestion(sessionId);
    } catch (e) {
      return 'Unable to generate suggestion';
    }
  }

  // ========== STATISTICS ==========

  /// Get sessions organized by day
  Future<Map<WeekDay, List<WorkoutSession>>> getSessionsByWeek() async {
    try {
      return await _workoutService.getSessionsByWeek();
    } catch (e) {
      _error = 'Failed to get weekly sessions: $e';
      notifyListeners();
      return {};
    }
  }

  /// Get unscheduled sessions
  Future<List<WorkoutSession>> getUnscheduledSessions() async {
    try {
      return await _workoutService.getUnscheduledSessions();
    } catch (e) {
      _error = 'Failed to get unscheduled sessions: $e';
      notifyListeners();
      return [];
    }
  }

  /// Get week completion summary
  Future<WeekCompletionSummary> getWeekSummary() async {
    return await _resetService.getWeekCompletionSummary();
  }

  /// Get workouts completed this week
  Future<int> getWorkoutsThisWeek() async {
    return await _workoutService.getWorkoutsThisWeek();
  }

  // ========== ERROR HANDLING ==========

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
