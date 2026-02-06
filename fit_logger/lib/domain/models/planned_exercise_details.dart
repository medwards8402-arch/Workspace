import 'package:flutter/foundation.dart';
import '../../core/constants/enums.dart';

/// Planned details for an exercise within a workout session
/// Different fields are used based on the measurement type
@immutable
class PlannedExerciseDetails {
  final String exerciseId;
  final MeasurementType measurementType;
  
  // For repsOnly and repsWeight
  final int? plannedSets;
  final List<int>? plannedRepsPerSet;
  
  // For repsWeight only
  final List<double>? plannedWeightsPerSet; // in kg
  
  // For timeDistance
  final Duration? plannedDuration;
  final double? plannedDistance; // in km
  
  // For intervals
  final int? plannedIntervalCount;
  final List<Duration>? plannedRunDurations;
  final List<Duration>? plannedWalkDurations;
  
  // Optional notes about the plan
  final String? notes;

  const PlannedExerciseDetails({
    required this.exerciseId,
    required this.measurementType,
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

  /// Create planned details for reps-only exercises
  factory PlannedExerciseDetails.repsOnly({
    required String exerciseId,
    required int sets,
    required List<int> repsPerSet,
    String? notes,
  }) {
    return PlannedExerciseDetails(
      exerciseId: exerciseId,
      measurementType: MeasurementType.repsOnly,
      plannedSets: sets,
      plannedRepsPerSet: repsPerSet,
      notes: notes,
    );
  }

  /// Create planned details for reps & weight exercises
  factory PlannedExerciseDetails.repsWeight({
    required String exerciseId,
    required int sets,
    required List<int> repsPerSet,
    required List<double> weightsPerSet,
    String? notes,
  }) {
    return PlannedExerciseDetails(
      exerciseId: exerciseId,
      measurementType: MeasurementType.repsWeight,
      plannedSets: sets,
      plannedRepsPerSet: repsPerSet,
      plannedWeightsPerSet: weightsPerSet,
      notes: notes,
    );
  }

  /// Create planned details for time & distance exercises
  factory PlannedExerciseDetails.timeDistance({
    required String exerciseId,
    required Duration duration,
    required double distance,
    String? notes,
  }) {
    return PlannedExerciseDetails(
      exerciseId: exerciseId,
      measurementType: MeasurementType.timeDistance,
      plannedDuration: duration,
      plannedDistance: distance,
      notes: notes,
    );
  }

  /// Create planned details for interval exercises
  factory PlannedExerciseDetails.intervals({
    required String exerciseId,
    required int intervalCount,
    required List<Duration> runDurations,
    required List<Duration> walkDurations,
    String? notes,
  }) {
    return PlannedExerciseDetails(
      exerciseId: exerciseId,
      measurementType: MeasurementType.intervals,
      plannedIntervalCount: intervalCount,
      plannedRunDurations: runDurations,
      plannedWalkDurations: walkDurations,
      notes: notes,
    );
  }

  /// Create a copy with modified fields
  PlannedExerciseDetails copyWith({
    String? exerciseId,
    MeasurementType? measurementType,
    int? plannedSets,
    List<int>? plannedRepsPerSet,
    List<double>? plannedWeightsPerSet,
    Duration? plannedDuration,
    double? plannedDistance,
    int? plannedIntervalCount,
    List<Duration>? plannedRunDurations,
    List<Duration>? plannedWalkDurations,
    String? notes,
    bool clearNotes = false,
  }) {
    return PlannedExerciseDetails(
      exerciseId: exerciseId ?? this.exerciseId,
      measurementType: measurementType ?? this.measurementType,
      plannedSets: plannedSets ?? this.plannedSets,
      plannedRepsPerSet: plannedRepsPerSet ?? this.plannedRepsPerSet,
      plannedWeightsPerSet: plannedWeightsPerSet ?? this.plannedWeightsPerSet,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      plannedDistance: plannedDistance ?? this.plannedDistance,
      plannedIntervalCount: plannedIntervalCount ?? this.plannedIntervalCount,
      plannedRunDurations: plannedRunDurations ?? this.plannedRunDurations,
      plannedWalkDurations: plannedWalkDurations ?? this.plannedWalkDurations,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  /// Get a summary string of the planned details
  String getSummary() {
    switch (measurementType) {
      case MeasurementType.repsOnly:
        if (plannedSets != null && plannedRepsPerSet != null && plannedRepsPerSet!.isNotEmpty) {
          final totalReps = plannedRepsPerSet!.fold<int>(0, (sum, reps) => sum + reps);
          return '$plannedSets sets × $totalReps reps';
        }
        return 'No plan set';
        
      case MeasurementType.repsWeight:
        if (plannedSets != null && plannedRepsPerSet != null && plannedWeightsPerSet != null) {
          final avgWeight = plannedWeightsPerSet!.reduce((a, b) => a + b) / plannedWeightsPerSet!.length;
          return '$plannedSets sets @ ${avgWeight.toStringAsFixed(1)} kg';
        }
        return 'No plan set';
        
      case MeasurementType.timeDistance:
        if (plannedDuration != null && plannedDistance != null) {
          final mins = plannedDuration!.inMinutes;
          return '${plannedDistance!.toStringAsFixed(1)} km in ${mins}m';
        }
        return 'No plan set';
        
      case MeasurementType.intervals:
        if (plannedIntervalCount != null) {
          return '$plannedIntervalCount intervals';
        }
        return 'No plan set';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedExerciseDetails &&
          runtimeType == other.runtimeType &&
          exerciseId == other.exerciseId &&
          measurementType == other.measurementType;

  @override
  int get hashCode => exerciseId.hashCode ^ measurementType.hashCode;
}
