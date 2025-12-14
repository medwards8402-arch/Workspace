import 'package:uuid/uuid.dart';
import '../domain/models/exercise.dart';
import '../domain/models/workout_session.dart';
import '../domain/models/workout_log.dart';
import '../domain/models/exercise_log.dart';
import '../domain/repositories/workout_repository.dart';
import '../core/constants/enums.dart';

/// Service for workout-related business logic
class WorkoutService {
  final WorkoutRepository _repository;
  final Uuid _uuid = const Uuid();

  WorkoutService(this._repository);

  // Public getter for repository access
  WorkoutRepository get repository => _repository;

  // ========== SESSION MANAGEMENT ==========

  /// Create a new workout session
  Future<WorkoutSession> createSession({
    required String name,
    List<String> exerciseIds = const [],
    WeekDay? plannedDay,
    bool isActive = true,
  }) async {
    final now = DateTime.now();
    final weekStart = _getWeekStartDate(now);

    final session = WorkoutSession(
      id: _uuid.v4(),
      name: name,
      exerciseIds: exerciseIds,
      plannedDay: plannedDay,
      isActive: isActive,
      completedThisWeek: false,
      weekStartDate: weekStart,
      lastCompletedDate: null,
      createdAt: now,
    );

    await _repository.saveSession(session);
    return session;
  }

  /// Update an existing session
  Future<void> updateSession(WorkoutSession session) async {
    await _repository.saveSession(session);
  }

  /// Toggle session active status
  Future<void> toggleSessionActive(String sessionId) async {
    final session = await _repository.getSession(sessionId);
    if (session != null) {
      final updated = session.copyWith(isActive: !session.isActive);
      await _repository.saveSession(updated);
    }
  }

  /// Add exercise to session
  Future<void> addExerciseToSession(String sessionId, String exerciseId) async {
    final session = await _repository.getSession(sessionId);
    if (session != null) {
      final updated = session.addExercise(exerciseId);
      await _repository.saveSession(updated);
    }
  }

  /// Remove exercise from session
  Future<void> removeExerciseFromSession(String sessionId, String exerciseId) async {
    final session = await _repository.getSession(sessionId);
    if (session != null) {
      final updated = session.removeExercise(exerciseId);
      await _repository.saveSession(updated);
    }
  }

  /// Reorder exercises in session
  Future<void> reorderExercises(String sessionId, List<String> newOrder) async {
    final session = await _repository.getSession(sessionId);
    if (session != null) {
      final updated = session.copyWith(exerciseIds: newOrder);
      await _repository.saveSession(updated);
    }
  }

  /// Delete session (with confirmation in UI)
  Future<void> deleteSession(String sessionId) async {
    await _repository.deleteSession(sessionId);
  }

  // ========== WORKOUT LOGGING ==========

  /// Create a workout log and mark session as completed
  Future<WorkoutLog> logWorkout({
    required String sessionId,
    required String sessionName,
    required List<ExerciseLog> exerciseLogs,
    Duration? totalDuration,
    String? notes,
  }) async {
    final log = WorkoutLog(
      id: _uuid.v4(),
      sessionId: sessionId,
      sessionName: sessionName,
      timestamp: DateTime.now(),
      exerciseLogs: exerciseLogs,
      totalDuration: totalDuration,
      notes: notes,
    );

    await _repository.saveWorkoutLog(log);

    // Mark session as completed this week
    final session = await _repository.getSession(sessionId);
    if (session != null) {
      final updated = session.markComplete();
      await _repository.saveSession(updated);
    }

    return log;
  }

  /// Update an existing workout log
  Future<void> updateWorkoutLog(WorkoutLog log) async {
    await _repository.updateWorkoutLog(log);
  }

  /// Delete a workout log
  Future<void> deleteWorkoutLog(String logId) async {
    await _repository.deleteWorkoutLog(logId);
  }

  /// Get workout logs for a date range
  Future<List<WorkoutLog>> getLogsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _repository.getWorkoutLogs(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get workout history for a specific session
  Future<List<WorkoutLog>> getSessionHistory(String sessionId) async {
    return await _repository.getLogsForSession(sessionId);
  }

  // ========== STATISTICS & INSIGHTS ==========

  /// Get total workouts completed this week
  Future<int> getWorkoutsThisWeek() async {
    final now = DateTime.now();
    final weekStart = _getWeekStartDate(now);
    final logs = await _repository.getWorkoutLogs(
      startDate: weekStart,
      endDate: now,
    );
    return logs.length;
  }

  /// Get workout frequency for last N weeks
  Future<Map<int, int>> getWeeklyFrequency(int weeks) async {
    final now = DateTime.now();
    final frequency = <int, int>{};

    for (int i = 0; i < weeks; i++) {
      final weekStart = _getWeekStartDate(now.subtract(Duration(days: i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 7));
      
      final logs = await _repository.getWorkoutLogs(
        startDate: weekStart,
        endDate: weekEnd,
      );
      
      frequency[i] = logs.length;
    }

    return frequency;
  }

  /// Get most frequently trained exercises
  Future<Map<String, int>> getMostFrequentExercises({int limit = 10}) async {
    final allLogs = await _repository.getAllLogs();
    final exerciseCounts = <String, int>{};

    for (final log in allLogs) {
      for (final exerciseLog in log.exerciseLogs) {
        exerciseCounts[exerciseLog.exerciseId] = 
            (exerciseCounts[exerciseLog.exerciseId] ?? 0) + 1;
      }
    }

    // Sort by count and limit
    final sortedEntries = exerciseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(
      sortedEntries.take(limit),
    );
  }

  /// Get difficulty distribution for recent workouts
  Future<Map<Difficulty, int>> getRecentDifficultyDistribution({
    int daysBack = 30,
  }) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysBack));
    
    final logs = await _repository.getWorkoutLogs(
      startDate: startDate,
      endDate: now,
    );

    final distribution = <Difficulty, int>{
      Difficulty.easy: 0,
      Difficulty.medium: 0,
      Difficulty.hard: 0,
    };

    for (final log in logs) {
      final summary = log.getDifficultySummary();
      summary.forEach((difficulty, count) {
        distribution[difficulty] = (distribution[difficulty] ?? 0) + count;
      });
    }

    return distribution;
  }

  // ========== UTILITY METHODS ==========

  /// Get the Monday of the current week for a given date
  DateTime _getWeekStartDate(DateTime date) {
    // Monday = 1, Sunday = 7
    final weekday = date.weekday;
    final daysToSubtract = weekday - 1; // 0 for Monday, 1 for Tuesday, etc.
    final monday = date.subtract(Duration(days: daysToSubtract));
    
    // Return Monday at midnight
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Check if a date is in the current week
  bool isInCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStartDate(now);
    final currentWeekEnd = currentWeekStart.add(const Duration(days: 7));
    
    return date.isAfter(currentWeekStart) && date.isBefore(currentWeekEnd) ||
           date.isAtSameMomentAs(currentWeekStart);
  }

  /// Get sessions that should be displayed for a specific day
  Future<List<WorkoutSession>> getSessionsForDay(WeekDay day) async {
    return await _repository.getSessionsByDay(day);
  }

  /// Get all active sessions organized by day
  Future<Map<WeekDay, List<WorkoutSession>>> getSessionsByWeek() async {
    final activeSessions = await _repository.getActiveSessions();
    final sessionsByDay = <WeekDay, List<WorkoutSession>>{};

    // Initialize all days
    for (final day in WeekDay.values) {
      sessionsByDay[day] = [];
    }

    // Organize sessions
    for (final session in activeSessions) {
      if (session.plannedDay != null) {
        sessionsByDay[session.plannedDay]!.add(session);
      }
    }

    return sessionsByDay;
  }

  /// Get unscheduled active sessions
  Future<List<WorkoutSession>> getUnscheduledSessions() async {
    final activeSessions = await _repository.getActiveSessions();
    return activeSessions.where((s) => s.plannedDay == null).toList();
  }

  /// Delete a workout log
  Future<void> deleteLog(String logId) async {
    await _repository.deleteLog(logId);
  }

  /// Get exercise history for a specific session and exercise
  Future<List<ExerciseLog>> getExerciseHistory({
    required String sessionId,
    required String exerciseId,
    int limit = 10,
  }) async {
    // Get all logs for this session
    final allLogs = await _repository.getLogsBySession(sessionId);
    
    // Extract exercise logs for this specific exercise, sorted by date descending
    final exerciseLogs = <ExerciseLog>[];
    for (final log in allLogs) {
      for (final exerciseLog in log.exerciseLogs) {
        if (exerciseLog.exerciseId == exerciseId) {
          exerciseLogs.add(exerciseLog);
        }
      }
    }
    
    // Sort by timestamp descending and take limit
    exerciseLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return exerciseLogs.take(limit).toList();
  }
}
