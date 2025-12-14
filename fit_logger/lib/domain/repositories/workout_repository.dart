import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../models/workout_log.dart';
import '../../core/constants/enums.dart';

/// Abstract repository interface for workout data
/// 
/// This interface defines all data operations for the workout app.
/// Implementations can use different data sources (Hive, SQLite, Cloud, etc.)
abstract class WorkoutRepository {
  // ===== Workout Sessions =====
  
  /// Get all workout sessions
  Future<List<WorkoutSession>> getAllSessions();
  
  /// Get a single session by ID
  Future<WorkoutSession?> getSession(String id);
  
  /// Get sessions for a specific day
  Future<List<WorkoutSession>> getSessionsByDay(WeekDay day);
  
  /// Get all active sessions
  Future<List<WorkoutSession>> getActiveSessions();
  
  /// Save a new or updated session
  Future<void> saveSession(WorkoutSession session);
  
  /// Delete a session
  Future<void> deleteSession(String id);
  
  // ===== Workout Logs =====
  
  /// Get all workout logs
  Future<List<WorkoutLog>> getAllLogs();
  
  /// Get workout logs within a date range
  Future<List<WorkoutLog>> getWorkoutLogs({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Get logs for a specific session
  Future<List<WorkoutLog>> getLogsForSession(String sessionId);
  
  /// Get the most recent log for a session (for pre-filling)
  Future<WorkoutLog?> getLastLogForSession(String sessionId);
  
  /// Get a single log by ID
  Future<WorkoutLog?> getLog(String id);
  
  /// Save a new workout log
  Future<void> saveWorkoutLog(WorkoutLog log);
  
  /// Update an existing workout log
  Future<void> updateWorkoutLog(WorkoutLog log);
  
  /// Delete a workout log
  Future<void> deleteWorkoutLog(String id);
  
  // ===== Exercises (Read-only) =====
  
  /// Get all exercises from the hardcoded library
  List<Exercise> getAllExercises();
  
  /// Get a single exercise by ID
  Exercise? getExercise(String id);
  
  /// Get exercises by category
  List<Exercise> getExercisesByCategory(ExerciseCategory category);
  
  /// Get exercises by measurement type
  List<Exercise> getExercisesByMeasurementType(MeasurementType type);
  
  /// Search exercises by name
  List<Exercise> searchExercises(String query);
  
  // ===== Utility =====
  
  /// Initialize the repository (open databases, etc.)
  Future<void> initialize();
  
  /// Close/cleanup resources
  Future<void> close();
}
