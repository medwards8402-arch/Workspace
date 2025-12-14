import 'package:hive/hive.dart';
import '../../domain/models/exercise_log.dart';
import '../../core/constants/enums.dart';

part 'exercise_log_hive.g.dart';

@HiveType(typeId: 2)
class RepsOnlyLogHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final String exerciseName;

  @HiveField(3)
  final int difficultyIndex;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final int sets;

  @HiveField(7)
  final List<int> repsPerSet;

  RepsOnlyLogHive({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.difficultyIndex,
    this.notes,
    required this.timestamp,
    required this.sets,
    required this.repsPerSet,
  });

  factory RepsOnlyLogHive.fromDomain(RepsOnlyLog log) {
    return RepsOnlyLogHive(
      id: log.id,
      exerciseId: log.exerciseId,
      exerciseName: log.exerciseName,
      difficultyIndex: log.difficulty.index,
      notes: log.notes,
      timestamp: log.timestamp,
      sets: log.sets,
      repsPerSet: List<int>.from(log.repsPerSet),
    );
  }

  RepsOnlyLog toDomain() {
    return RepsOnlyLog(
      id: id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      difficulty: Difficulty.values[difficultyIndex],
      notes: notes,
      timestamp: timestamp,
      sets: sets,
      repsPerSet: List<int>.from(repsPerSet),
    );
  }
}

@HiveType(typeId: 3)
class RepsWeightLogHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final String exerciseName;

  @HiveField(3)
  final int difficultyIndex;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final int sets;

  @HiveField(7)
  final List<int> repsPerSet;

  @HiveField(8)
  final List<double> weightsPerSet;

  RepsWeightLogHive({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.difficultyIndex,
    this.notes,
    required this.timestamp,
    required this.sets,
    required this.repsPerSet,
    required this.weightsPerSet,
  });

  factory RepsWeightLogHive.fromDomain(RepsWeightLog log) {
    return RepsWeightLogHive(
      id: log.id,
      exerciseId: log.exerciseId,
      exerciseName: log.exerciseName,
      difficultyIndex: log.difficulty.index,
      notes: log.notes,
      timestamp: log.timestamp,
      sets: log.sets,
      repsPerSet: List<int>.from(log.repsPerSet),
      weightsPerSet: List<double>.from(log.weightsPerSet),
    );
  }

  RepsWeightLog toDomain() {
    return RepsWeightLog(
      id: id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      difficulty: Difficulty.values[difficultyIndex],
      notes: notes,
      timestamp: timestamp,
      sets: sets,
      repsPerSet: List<int>.from(repsPerSet),
      weightsPerSet: List<double>.from(weightsPerSet),
    );
  }
}

@HiveType(typeId: 4)
class TimeDistanceLogHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final String exerciseName;

  @HiveField(3)
  final int difficultyIndex;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final Duration duration;

  @HiveField(7)
  final double distance;

  @HiveField(8)
  final double? speed;

  TimeDistanceLogHive({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.difficultyIndex,
    this.notes,
    required this.timestamp,
    required this.duration,
    required this.distance,
    this.speed,
  });

  factory TimeDistanceLogHive.fromDomain(TimeDistanceLog log) {
    return TimeDistanceLogHive(
      id: log.id,
      exerciseId: log.exerciseId,
      exerciseName: log.exerciseName,
      difficultyIndex: log.difficulty.index,
      notes: log.notes,
      timestamp: log.timestamp,
      duration: log.duration,
      distance: log.distance,
      speed: log.speed,
    );
  }

  TimeDistanceLog toDomain() {
    return TimeDistanceLog(
      id: id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      difficulty: Difficulty.values[difficultyIndex],
      notes: notes,
      timestamp: timestamp,
      duration: duration,
      distance: distance,
      speed: speed,
    );
  }
}

@HiveType(typeId: 5)
class IntervalsLogHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseId;

  @HiveField(2)
  final String exerciseName;

  @HiveField(3)
  final int difficultyIndex;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final int intervalCount;

  @HiveField(7)
  final List<Duration> runDurations;

  @HiveField(8)
  final List<Duration> walkDurations;

  @HiveField(9)
  final List<double> speeds;

  IntervalsLogHive({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.difficultyIndex,
    this.notes,
    required this.timestamp,
    required this.intervalCount,
    required this.runDurations,
    required this.walkDurations,
    required this.speeds,
  });

  factory IntervalsLogHive.fromDomain(IntervalsLog log) {
    return IntervalsLogHive(
      id: log.id,
      exerciseId: log.exerciseId,
      exerciseName: log.exerciseName,
      difficultyIndex: log.difficulty.index,
      notes: log.notes,
      timestamp: log.timestamp,
      intervalCount: log.intervalCount,
      runDurations: List<Duration>.from(log.runDurations),
      walkDurations: List<Duration>.from(log.walkDurations),
      speeds: List<double>.from(log.speeds),
    );
  }

  IntervalsLog toDomain() {
    return IntervalsLog(
      id: id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      difficulty: Difficulty.values[difficultyIndex],
      notes: notes,
      timestamp: timestamp,
      intervalCount: intervalCount,
      runDurations: List<Duration>.from(runDurations),
      walkDurations: List<Duration>.from(walkDurations),
      speeds: List<double>.from(speeds),
    );
  }
}
