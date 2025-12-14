import '../domain/models/exercise.dart';
import '../domain/models/exercise_log.dart';
import '../domain/repositories/workout_repository.dart';
import '../core/constants/enums.dart';
import '../core/constants/app_constants.dart';

/// Service for smart pre-filling workout data with progressive overload
class PrefillService {
  final WorkoutRepository _repository;

  PrefillService(this._repository);

  /// Get pre-filled exercise log based on last performance
  Future<ExerciseLog?> getPrefillData({
    required String sessionId,
    required String exerciseId,
  }) async {
    // Get the last workout log for this session
    final lastLog = await _repository.getLastLogForSession(sessionId);
    
    if (lastLog == null) {
      // No previous data, return null to use defaults
      return null;
    }

    // Find the exercise log for this exercise
    ExerciseLog? lastExerciseLog;
    try {
      lastExerciseLog = lastLog.exerciseLogs.firstWhere(
        (log) => log.exerciseId == exerciseId,
      );
    } catch (_) {
      // Exercise not found in last workout
      return null;
    }

    // Apply progressive overload based on difficulty and measurement type
    return _applyProgressiveOverload(lastExerciseLog);
  }

  /// Apply progressive overload suggestions based on last performance
  ExerciseLog _applyProgressiveOverload(ExerciseLog lastLog) {
    // If last workout was easy, suggest increase
    // If medium, keep same or slight increase
    // If hard, keep same
    
    if (lastLog is RepsOnlyLog) {
      return _progressRepsOnly(lastLog);
    } else if (lastLog is RepsWeightLog) {
      return _progressRepsWeight(lastLog);
    } else if (lastLog is TimeDistanceLog) {
      return _progressTimeDistance(lastLog);
    } else if (lastLog is IntervalsLog) {
      return _progressIntervals(lastLog);
    }

    return lastLog;
  }

  /// Progressive overload for bodyweight exercises (reps only)
  RepsOnlyLog _progressRepsOnly(RepsOnlyLog lastLog) {
    if (lastLog.difficulty == Difficulty.hard) {
      // Keep same if it was hard
      return lastLog.copyWith(
        difficulty: Difficulty.medium, // Reset to medium for new attempt
        notes: 'Last time: ${lastLog.getSummary()} (Hard)',
      );
    }

    // Suggest adding 1-2 reps per set if easy/medium
    final newReps = lastLog.repsPerSet.map((reps) {
      if (lastLog.difficulty == Difficulty.easy) {
        return reps + 2; // Add 2 reps if easy
      } else {
        return reps + 1; // Add 1 rep if medium
      }
    }).toList();

    return lastLog.copyWith(
      repsPerSet: newReps,
      difficulty: Difficulty.medium,
      notes: 'Last time: ${lastLog.getSummary()} (${lastLog.difficulty.displayName}). Try ${newReps.join("/")} reps.',
    );
  }

  /// Progressive overload for weighted exercises
  RepsWeightLog _progressRepsWeight(RepsWeightLog lastLog) {
    if (lastLog.difficulty == Difficulty.hard) {
      // Keep same weight if hard
      return lastLog.copyWith(
        difficulty: Difficulty.medium,
        notes: 'Last time: ${lastLog.getSummary()} (Hard)',
      );
    }

    if (lastLog.difficulty == Difficulty.easy) {
      // Increase weight by 2.5-5kg if easy
      final newWeights = lastLog.weightsPerSet.map((weight) {
        // Increase by 2.5kg for smaller weights, 5kg for larger
        final increment = weight < 40 ? 2.5 : 5.0;
        return weight + increment;
      }).toList();

      return lastLog.copyWith(
        weightsPerSet: newWeights,
        difficulty: Difficulty.medium,
        notes: 'Last time: ${lastLog.getSummary()} (Easy). Increased weight.',
      );
    }

    // Medium difficulty - try adding 1 rep to last set or small weight increase
    if (lastLog.sets >= 3) {
      // Add 1 rep to last set
      final newReps = List<int>.from(lastLog.repsPerSet);
      newReps[newReps.length - 1] += 1;
      
      return lastLog.copyWith(
        repsPerSet: newReps,
        difficulty: Difficulty.medium,
        notes: 'Last time: ${lastLog.getSummary()} (Medium). Added 1 rep to last set.',
      );
    }

    // Default: keep same
    return lastLog.copyWith(
      difficulty: Difficulty.medium,
      notes: 'Last time: ${lastLog.getSummary()} (Medium)',
    );
  }

  /// Progressive overload for cardio (time/distance)
  TimeDistanceLog _progressTimeDistance(TimeDistanceLog lastLog) {
    if (lastLog.difficulty == Difficulty.hard) {
      // Keep same if hard
      return lastLog.copyWith(
        difficulty: Difficulty.medium,
        notes: 'Last time: ${lastLog.getSummary()} (Hard)',
      );
    }

    if (lastLog.difficulty == Difficulty.easy) {
      // Increase distance by 10% or decrease pace by 5%
      final newDistance = lastLog.distance * 1.1;
      
      return lastLog.copyWith(
        distance: double.parse(newDistance.toStringAsFixed(1)),
        difficulty: Difficulty.medium,
        notes: 'Last time: ${lastLog.getSummary()} (Easy). Increased distance 10%.',
      );
    }

    // Medium: slight increase or keep same
    final newDistance = lastLog.distance * 1.05;
    
    return lastLog.copyWith(
      distance: double.parse(newDistance.toStringAsFixed(1)),
      difficulty: Difficulty.medium,
      notes: 'Last time: ${lastLog.getSummary()} (Medium). Slight increase.',
    );
  }

  /// Progressive overload for intervals
  IntervalsLog _progressIntervals(IntervalsLog lastLog) {
    if (lastLog.difficulty == Difficulty.hard) {
      // Keep same if hard
      return lastLog.copyWith(
        difficulty: Difficulty.medium,
        notes: 'Last time: ${lastLog.getSummary()} (Hard)',
      );
    }

    if (lastLog.difficulty == Difficulty.easy) {
      // Add 1 interval or increase run duration
      return lastLog.copyWith(
        intervalCount: lastLog.intervalCount + 1,
        runDurations: [...lastLog.runDurations, lastLog.runDurations.first],
        walkDurations: [...lastLog.walkDurations, lastLog.walkDurations.first],
        speeds: [...lastLog.speeds, lastLog.speeds.first],
        difficulty: Difficulty.medium,
        notes: 'Last time: ${lastLog.getSummary()} (Easy). Added 1 interval.',
      );
    }

    // Medium: increase run duration slightly
    final newRunDurations = lastLog.runDurations.map((dur) {
      return Duration(seconds: dur.inSeconds + 15); // Add 15 seconds
    }).toList();

    return lastLog.copyWith(
      runDurations: newRunDurations,
      difficulty: Difficulty.medium,
      notes: 'Last time: ${lastLog.getSummary()} (Medium). Increased run time.',
    );
  }

  /// Get default exercise log for first-time exercises
  ExerciseLog getDefaultLog(Exercise exercise) {
    final now = DateTime.now();
    
    switch (exercise.measurementType) {
      case MeasurementType.repsOnly:
        return RepsOnlyLog(
          id: '', // Will be set when saving
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          difficulty: Difficulty.medium,
          notes: null,
          timestamp: now,
          sets: AppConstants.defaultSets,
          repsPerSet: List.filled(AppConstants.defaultSets, 10), // Default 10 reps
        );

      case MeasurementType.repsWeight:
        return RepsWeightLog(
          id: '',
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          difficulty: Difficulty.medium,
          notes: null,
          timestamp: now,
          sets: AppConstants.defaultSets,
          repsPerSet: List.filled(AppConstants.defaultSets, 10),
          weightsPerSet: List.filled(AppConstants.defaultSets, 20.0), // Default 20kg
        );

      case MeasurementType.timeDistance:
        return TimeDistanceLog(
          id: '',
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          difficulty: Difficulty.medium,
          notes: null,
          timestamp: now,
          duration: const Duration(minutes: 30), // Default 30 minutes
          distance: 5.0, // Default 5km
          speed: null,
        );

      case MeasurementType.intervals:
        return IntervalsLog(
          id: '',
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          difficulty: Difficulty.medium,
          notes: null,
          timestamp: now,
          intervalCount: 4, // Default 4 intervals
          runDurations: List.filled(4, const Duration(minutes: 2)),
          walkDurations: List.filled(4, const Duration(minutes: 1)),
          speeds: List.filled(4, 10.0), // Default 10 km/h
        );
    }
  }

  /// Get smart suggestions for next workout
  Future<String> getWorkoutSuggestion(String sessionId) async {
    final lastLog = await _repository.getLastLogForSession(sessionId);
    
    if (lastLog == null) {
      return 'First time doing this workout! Take it steady and find your baseline.';
    }

    final daysSince = DateTime.now().difference(lastLog.timestamp).inDays;
    final overallDifficulty = lastLog.overallDifficulty;

    if (daysSince <= 2) {
      return 'You just did this workout ${daysSince == 0 ? "today" : "$daysSince days ago"}. Make sure you\'re recovered!';
    }

    if (daysSince >= 14) {
      return 'It\'s been $daysSince days since your last workout. Consider reducing intensity slightly.';
    }

    switch (overallDifficulty) {
      case Difficulty.easy:
        return 'Last workout was easy! Time to increase the challenge.';
      case Difficulty.medium:
        return 'Good balance last time. Slight progression suggested.';
      case Difficulty.hard:
        return 'Last workout was tough. Keep the same intensity or reduce slightly.';
    }
  }
}
