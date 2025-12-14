import 'package:hive/hive.dart';
import '../../domain/models/workout_log.dart';
import '../../domain/models/exercise_log.dart';
import 'exercise_log_hive.dart';

part 'workout_log_hive.g.dart';

@HiveType(typeId: 6)
class WorkoutLogHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final String sessionName;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final List<dynamic> exerciseLogsHive; // Mixed list of Hive log types

  @HiveField(5)
  final Duration? totalDuration;

  @HiveField(6)
  final String? notes;

  WorkoutLogHive({
    required this.id,
    required this.sessionId,
    required this.sessionName,
    required this.timestamp,
    required this.exerciseLogsHive,
    this.totalDuration,
    this.notes,
  });

  /// Convert from domain model
  factory WorkoutLogHive.fromDomain(WorkoutLog log) {
    // Convert each ExerciseLog to its Hive counterpart
    final logsHive = log.exerciseLogs.map((exerciseLog) {
      if (exerciseLog is RepsOnlyLog) {
        return RepsOnlyLogHive.fromDomain(exerciseLog);
      } else if (exerciseLog is RepsWeightLog) {
        return RepsWeightLogHive.fromDomain(exerciseLog);
      } else if (exerciseLog is TimeDistanceLog) {
        return TimeDistanceLogHive.fromDomain(exerciseLog);
      } else if (exerciseLog is IntervalsLog) {
        return IntervalsLogHive.fromDomain(exerciseLog);
      }
      throw Exception('Unknown ExerciseLog type: ${exerciseLog.runtimeType}');
    }).toList();

    return WorkoutLogHive(
      id: log.id,
      sessionId: log.sessionId,
      sessionName: log.sessionName,
      timestamp: log.timestamp,
      exerciseLogsHive: logsHive,
      totalDuration: log.totalDuration,
      notes: log.notes,
    );
  }

  /// Convert to domain model
  WorkoutLog toDomain() {
    // Convert each Hive log back to domain ExerciseLog
    final logs = exerciseLogsHive.map((hiveLog) {
      if (hiveLog is RepsOnlyLogHive) {
        return hiveLog.toDomain();
      } else if (hiveLog is RepsWeightLogHive) {
        return hiveLog.toDomain();
      } else if (hiveLog is TimeDistanceLogHive) {
        return hiveLog.toDomain();
      } else if (hiveLog is IntervalsLogHive) {
        return hiveLog.toDomain();
      }
      throw Exception('Unknown Hive log type: ${hiveLog.runtimeType}');
    }).toList();

    return WorkoutLog(
      id: id,
      sessionId: sessionId,
      sessionName: sessionName,
      timestamp: timestamp,
      exerciseLogs: logs,
      totalDuration: totalDuration,
      notes: notes,
    );
  }
}
