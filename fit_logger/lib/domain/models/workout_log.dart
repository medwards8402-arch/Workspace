import 'package:flutter/foundation.dart';
import '../../core/constants/enums.dart';
import 'exercise_log.dart';

/// Immutable workout log representing a completed workout
@immutable
class WorkoutLog {
  final String id;
  final String sessionId;
  final String sessionName;
  final DateTime timestamp;
  final List<ExerciseLog> exerciseLogs;
  final Duration? totalDuration;
  final String? notes;

  const WorkoutLog({
    required this.id,
    required this.sessionId,
    required this.sessionName,
    required this.timestamp,
    required this.exerciseLogs,
    this.totalDuration,
    this.notes,
  });

  /// Get difficulty summary (count of easy/medium/hard exercises)
  Map<Difficulty, int> getDifficultySummary() {
    final summary = <Difficulty, int>{
      Difficulty.easy: 0,
      Difficulty.medium: 0,
      Difficulty.hard: 0,
    };

    for (final log in exerciseLogs) {
      summary[log.difficulty] = (summary[log.difficulty] ?? 0) + 1;
    }

    return summary;
  }

  /// Get overall difficulty (most common difficulty rating)
  Difficulty get overallDifficulty {
    final summary = getDifficultySummary();
    final sorted = summary.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  /// Create a copy with modified fields
  WorkoutLog copyWith({
    String? id,
    String? sessionId,
    String? sessionName,
    DateTime? timestamp,
    List<ExerciseLog>? exerciseLogs,
    Duration? totalDuration,
    bool? clearTotalDuration,
    String? notes,
    bool? clearNotes,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      sessionName: sessionName ?? this.sessionName,
      timestamp: timestamp ?? this.timestamp,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      totalDuration: clearTotalDuration == true
          ? null
          : (totalDuration ?? this.totalDuration),
      notes: clearNotes == true ? null : (notes ?? this.notes),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'sessionName': sessionName,
      'timestamp': timestamp.toIso8601String(),
      'exerciseLogs': exerciseLogs.map((log) => log.toJson()).toList(),
      'totalDurationSeconds': totalDuration?.inSeconds,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      sessionName: json['sessionName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      exerciseLogs: (json['exerciseLogs'] as List<dynamic>)
          .map((logJson) =>
              ExerciseLogFactory.fromJson(logJson as Map<String, dynamic>))
          .toList(),
      totalDuration: json['totalDurationSeconds'] != null
          ? Duration(seconds: json['totalDurationSeconds'] as int)
          : null,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WorkoutLog(id: $id, session: $sessionName, timestamp: $timestamp, exercises: ${exerciseLogs.length})';
  }
}
