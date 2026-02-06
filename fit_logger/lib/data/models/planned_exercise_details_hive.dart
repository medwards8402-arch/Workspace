import 'package:hive/hive.dart';
import '../../domain/models/planned_exercise_details.dart';
import '../../core/constants/enums.dart';

part 'planned_exercise_details_hive.g.dart';

/// Hive model for PlannedExerciseDetails
@HiveType(typeId: 7)
class PlannedExerciseDetailsHive extends HiveObject {
  @HiveField(0)
  final String exerciseId;

  @HiveField(1)
  final int measurementTypeIndex; // Store enum as int

  @HiveField(2)
  final int? plannedSets;

  @HiveField(3)
  final List<int>? plannedRepsPerSet;

  @HiveField(4)
  final List<double>? plannedWeightsPerSet;

  @HiveField(5)
  final Duration? plannedDuration;

  @HiveField(6)
  final double? plannedDistance;

  @HiveField(7)
  final int? plannedIntervalCount;

  @HiveField(8)
  final List<Duration>? plannedRunDurations;

  @HiveField(9)
  final List<Duration>? plannedWalkDurations;

  @HiveField(10)
  final String? notes;

  PlannedExerciseDetailsHive({
    required this.exerciseId,
    required this.measurementTypeIndex,
    this.plannedSets,
    this.plannedRepsPerSet,
    this.plannedWeightsPerSet,
    this.plannedDuration,
    this.plannedDistance,
    this.plannedIntervalCount,
    this.plannedRunDurations,
    this.plannedWalkDurations,
    this.notes,
  });

  /// Convert from domain model to Hive model
  factory PlannedExerciseDetailsHive.fromDomain(PlannedExerciseDetails details) {
    return PlannedExerciseDetailsHive(
      exerciseId: details.exerciseId,
      measurementTypeIndex: details.measurementType.index,
      plannedSets: details.plannedSets,
      plannedRepsPerSet: details.plannedRepsPerSet,
      plannedWeightsPerSet: details.plannedWeightsPerSet,
      plannedDuration: details.plannedDuration,
      plannedDistance: details.plannedDistance,
      plannedIntervalCount: details.plannedIntervalCount,
      plannedRunDurations: details.plannedRunDurations,
      plannedWalkDurations: details.plannedWalkDurations,
      notes: details.notes,
    );
  }

  /// Convert from Hive model to domain model
  PlannedExerciseDetails toDomain() {
    return PlannedExerciseDetails(
      exerciseId: exerciseId,
      measurementType: MeasurementType.values[measurementTypeIndex],
      plannedSets: plannedSets,
      plannedRepsPerSet: plannedRepsPerSet,
      plannedWeightsPerSet: plannedWeightsPerSet,
      plannedDuration: plannedDuration,
      plannedDistance: plannedDistance,
      plannedIntervalCount: plannedIntervalCount,
      plannedRunDurations: plannedRunDurations,
      plannedWalkDurations: plannedWalkDurations,
      notes: notes,
    );
  }
}
