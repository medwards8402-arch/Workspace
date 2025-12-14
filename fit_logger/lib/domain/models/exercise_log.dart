import 'package:flutter/foundation.dart';
import '../../core/constants/enums.dart';

/// Base class for exercise logs - polymorphic based on measurement type
@immutable
abstract class ExerciseLog {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final Difficulty difficulty;
  final String? notes;
  final DateTime timestamp;

  const ExerciseLog({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.difficulty,
    this.notes,
    required this.timestamp,
  });

  /// Get human-readable summary of the exercise performance
  String getSummary();

  /// Compare this log to another for progress tracking
  /// Returns: negative if this < other, 0 if equal, positive if this > other
  int compareTo(ExerciseLog other);

  /// Convert to JSON
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Exercise log for bodyweight exercises (reps only)
@immutable
class RepsOnlyLog extends ExerciseLog {
  final int sets;
  final List<int> repsPerSet;

  const RepsOnlyLog({
    required super.id,
    required super.exerciseId,
    required super.exerciseName,
    required super.difficulty,
    super.notes,
    required super.timestamp,
    required this.sets,
    required this.repsPerSet,
  });

  @override
  String getSummary() {
    if (repsPerSet.isEmpty) return '$sets sets';
    final total = repsPerSet.reduce((a, b) => a + b);
    return '$sets × ${repsPerSet.join('/')} = $total total reps';
  }

  @override
  int compareTo(ExerciseLog other) {
    if (other is! RepsOnlyLog) return 0;
    final thisTotal = repsPerSet.isEmpty ? 0 : repsPerSet.reduce((a, b) => a + b);
    final otherTotal =
        other.repsPerSet.isEmpty ? 0 : other.repsPerSet.reduce((a, b) => a + b);
    return thisTotal.compareTo(otherTotal);
  }

  RepsOnlyLog copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    Difficulty? difficulty,
    String? notes,
    bool? clearNotes,
    DateTime? timestamp,
    int? sets,
    List<int>? repsPerSet,
  }) {
    return RepsOnlyLog(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      difficulty: difficulty ?? this.difficulty,
      notes: clearNotes == true ? null : (notes ?? this.notes),
      timestamp: timestamp ?? this.timestamp,
      sets: sets ?? this.sets,
      repsPerSet: repsPerSet ?? this.repsPerSet,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'repsOnly',
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'difficulty': difficulty.name,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'sets': sets,
      'repsPerSet': repsPerSet,
    };
  }

  factory RepsOnlyLog.fromJson(Map<String, dynamic> json) {
    return RepsOnlyLog(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      difficulty: Difficulty.values.firstWhere((e) => e.name == json['difficulty']),
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sets: json['sets'] as int,
      repsPerSet:
          (json['repsPerSet'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }
}

/// Exercise log for weighted exercises (reps + weight)
@immutable
class RepsWeightLog extends ExerciseLog {
  final int sets;
  final List<int> repsPerSet;
  final List<double> weightsPerSet; // in kg

  const RepsWeightLog({
    required super.id,
    required super.exerciseId,
    required super.exerciseName,
    required super.difficulty,
    super.notes,
    required super.timestamp,
    required this.sets,
    required this.repsPerSet,
    required this.weightsPerSet,
  });

  @override
  String getSummary() {
    if (repsPerSet.isEmpty || weightsPerSet.isEmpty) return '$sets sets';
    final summaries = <String>[];
    for (int i = 0; i < sets && i < repsPerSet.length && i < weightsPerSet.length; i++) {
      summaries.add('${repsPerSet[i]}×${weightsPerSet[i]}kg');
    }
    return summaries.join(', ');
  }

  @override
  int compareTo(ExerciseLog other) {
    if (other is! RepsWeightLog) return 0;
    // Compare total volume (reps × weight)
    double thisVolume = 0;
    for (int i = 0; i < repsPerSet.length && i < weightsPerSet.length; i++) {
      thisVolume += repsPerSet[i] * weightsPerSet[i];
    }
    double otherVolume = 0;
    for (int i = 0; i < other.repsPerSet.length && i < other.weightsPerSet.length; i++) {
      otherVolume += other.repsPerSet[i] * other.weightsPerSet[i];
    }
    return thisVolume.compareTo(otherVolume);
  }

  RepsWeightLog copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    Difficulty? difficulty,
    String? notes,
    bool? clearNotes,
    DateTime? timestamp,
    int? sets,
    List<int>? repsPerSet,
    List<double>? weightsPerSet,
  }) {
    return RepsWeightLog(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      difficulty: difficulty ?? this.difficulty,
      notes: clearNotes == true ? null : (notes ?? this.notes),
      timestamp: timestamp ?? this.timestamp,
      sets: sets ?? this.sets,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      weightsPerSet: weightsPerSet ?? this.weightsPerSet,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'repsWeight',
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'difficulty': difficulty.name,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'sets': sets,
      'repsPerSet': repsPerSet,
      'weightsPerSet': weightsPerSet,
    };
  }

  factory RepsWeightLog.fromJson(Map<String, dynamic> json) {
    return RepsWeightLog(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      difficulty: Difficulty.values.firstWhere((e) => e.name == json['difficulty']),
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sets: json['sets'] as int,
      repsPerSet:
          (json['repsPerSet'] as List<dynamic>).map((e) => e as int).toList(),
      weightsPerSet:
          (json['weightsPerSet'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
    );
  }
}

/// Exercise log for cardio (time + distance)
@immutable
class TimeDistanceLog extends ExerciseLog {
  final Duration duration;
  final double distance; // in km
  final double? speed; // in km/h (optional, for running primarily)

  const TimeDistanceLog({
    required super.id,
    required super.exerciseId,
    required super.exerciseName,
    required super.difficulty,
    super.notes,
    required super.timestamp,
    required this.duration,
    required this.distance,
    this.speed,
  });

  /// Calculate pace (minutes per km)
  double get pace {
    if (distance == 0) return 0;
    return duration.inSeconds / 60 / distance;
  }

  @override
  String getSummary() {
    final distanceStr = distance.toStringAsFixed(2);
    final durationStr = _formatDuration(duration);
    final paceStr = pace.toStringAsFixed(2);
    if (speed != null) {
      return '$distanceStr km in $durationStr (${speed!.toStringAsFixed(1)} km/h)';
    }
    return '$distanceStr km in $durationStr ($paceStr min/km)';
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  @override
  int compareTo(ExerciseLog other) {
    if (other is! TimeDistanceLog) return 0;
    // Compare based on pace (lower is better)
    return other.pace.compareTo(pace);
  }

  TimeDistanceLog copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    Difficulty? difficulty,
    String? notes,
    bool? clearNotes,
    DateTime? timestamp,
    Duration? duration,
    double? distance,
    double? speed,
    bool? clearSpeed,
  }) {
    return TimeDistanceLog(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      difficulty: difficulty ?? this.difficulty,
      notes: clearNotes == true ? null : (notes ?? this.notes),
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      speed: clearSpeed == true ? null : (speed ?? this.speed),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'timeDistance',
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'difficulty': difficulty.name,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': duration.inSeconds,
      'distance': distance,
      'speed': speed,
    };
  }

  factory TimeDistanceLog.fromJson(Map<String, dynamic> json) {
    return TimeDistanceLog(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      difficulty: Difficulty.values.firstWhere((e) => e.name == json['difficulty']),
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: Duration(seconds: json['durationSeconds'] as int),
      distance: (json['distance'] as num).toDouble(),
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
    );
  }
}

/// Exercise log for interval training
@immutable
class IntervalsLog extends ExerciseLog {
  final int intervalCount;
  final List<Duration> runDurations;
  final List<Duration> walkDurations;
  final List<double> speeds; // in km/h

  const IntervalsLog({
    required super.id,
    required super.exerciseId,
    required super.exerciseName,
    required super.difficulty,
    super.notes,
    required super.timestamp,
    required this.intervalCount,
    required this.runDurations,
    required this.walkDurations,
    required this.speeds,
  });

  Duration get totalDuration {
    final runTotal = runDurations.fold(Duration.zero, (a, b) => a + b);
    final walkTotal = walkDurations.fold(Duration.zero, (a, b) => a + b);
    return runTotal + walkTotal;
  }

  @override
  String getSummary() {
    final totalStr = _formatDuration(totalDuration);
    return '$intervalCount intervals ($totalStr total)';
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  @override
  int compareTo(ExerciseLog other) {
    if (other is! IntervalsLog) return 0;
    // Compare total duration (more is better for intervals)
    return totalDuration.compareTo(other.totalDuration);
  }

  IntervalsLog copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    Difficulty? difficulty,
    String? notes,
    bool? clearNotes,
    DateTime? timestamp,
    int? intervalCount,
    List<Duration>? runDurations,
    List<Duration>? walkDurations,
    List<double>? speeds,
  }) {
    return IntervalsLog(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      difficulty: difficulty ?? this.difficulty,
      notes: clearNotes == true ? null : (notes ?? this.notes),
      timestamp: timestamp ?? this.timestamp,
      intervalCount: intervalCount ?? this.intervalCount,
      runDurations: runDurations ?? this.runDurations,
      walkDurations: walkDurations ?? this.walkDurations,
      speeds: speeds ?? this.speeds,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'intervals',
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'difficulty': difficulty.name,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'intervalCount': intervalCount,
      'runDurationsSeconds': runDurations.map((d) => d.inSeconds).toList(),
      'walkDurationsSeconds': walkDurations.map((d) => d.inSeconds).toList(),
      'speeds': speeds,
    };
  }

  factory IntervalsLog.fromJson(Map<String, dynamic> json) {
    return IntervalsLog(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      difficulty: Difficulty.values.firstWhere((e) => e.name == json['difficulty']),
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      intervalCount: json['intervalCount'] as int,
      runDurations: (json['runDurationsSeconds'] as List<dynamic>)
          .map((s) => Duration(seconds: s as int))
          .toList(),
      walkDurations: (json['walkDurationsSeconds'] as List<dynamic>)
          .map((s) => Duration(seconds: s as int))
          .toList(),
      speeds: (json['speeds'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

/// Factory for creating ExerciseLog from JSON
class ExerciseLogFactory {
  static ExerciseLog fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'repsOnly':
        return RepsOnlyLog.fromJson(json);
      case 'repsWeight':
        return RepsWeightLog.fromJson(json);
      case 'timeDistance':
        return TimeDistanceLog.fromJson(json);
      case 'intervals':
        return IntervalsLog.fromJson(json);
      default:
        throw ArgumentError('Unknown ExerciseLog type: $type');
    }
  }
}
