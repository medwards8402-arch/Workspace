import 'package:flutter/material.dart';
import '../../domain/models/exercise.dart';
import '../constants/enums.dart';

/// Hardcoded exercise library with 35+ exercises
class ExerciseLibrary {
  static final List<Exercise> _exercises = [
    // ========== BODYWEIGHT EXERCISES ==========
    Exercise(
      id: 'bw_pushups',
      name: 'Push-ups',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.accessibility_new,
      muscleGroups: ['Chest', 'Triceps', 'Shoulders'],
      equipment: [],
    ),
    Exercise(
      id: 'bw_pushups_wide',
      name: 'Wide Push-ups',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.accessibility_new,
      muscleGroups: ['Chest', 'Shoulders'],
      equipment: [],
    ),
    Exercise(
      id: 'bw_pushups_diamond',
      name: 'Diamond Push-ups',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.accessibility_new,
      muscleGroups: ['Triceps', 'Chest'],
      equipment: [],
    ),
    Exercise(
      id: 'bw_pullups',
      name: 'Pull-ups',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.fitness_center,
      muscleGroups: ['Back', 'Biceps'],
      equipment: ['Pull-up bar'],
    ),
    Exercise(
      id: 'bw_chinups',
      name: 'Chin-ups',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.fitness_center,
      muscleGroups: ['Back', 'Biceps'],
      equipment: ['Pull-up bar'],
    ),
    Exercise(
      id: 'bw_dips',
      name: 'Dips',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.fitness_center,
      muscleGroups: ['Chest', 'Triceps', 'Shoulders'],
      equipment: ['Dip bar'],
    ),
    Exercise(
      id: 'bw_squats',
      name: 'Bodyweight Squats',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.accessibility,
      muscleGroups: ['Legs', 'Glutes'],
      equipment: [],
    ),
    Exercise(
      id: 'bw_lunges',
      name: 'Lunges',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.directions_walk,
      muscleGroups: ['Legs', 'Glutes'],
      equipment: [],
    ),
    Exercise(
      id: 'bw_plank',
      name: 'Plank',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.timeDistance,
      icon: Icons.timer,
      muscleGroups: ['Core', 'Shoulders'],
      equipment: [],
    ),
    Exercise(
      id: 'bw_dead_hangs',
      name: 'Dead Hangs',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.timeDistance,
      icon: Icons.schedule,
      muscleGroups: ['Forearms', 'Grip', 'Back'],
      equipment: ['Pull-up bar'],
    ),
    Exercise(
      id: 'bw_burpees',
      name: 'Burpees',
      category: ExerciseCategory.bodyweight,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.flash_on,
      muscleGroups: ['Full Body', 'Cardio'],
      equipment: [],
    ),

    // ========== BARBELL EXERCISES ==========
    Exercise(
      id: 'bb_bench_press',
      name: 'Barbell Bench Press',
      category: ExerciseCategory.barbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Chest', 'Triceps', 'Shoulders'],
      equipment: ['Barbell', 'Bench'],
    ),
    Exercise(
      id: 'bb_squat',
      name: 'Barbell Squat',
      category: ExerciseCategory.barbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Legs', 'Glutes', 'Core'],
      equipment: ['Barbell', 'Rack'],
    ),
    Exercise(
      id: 'bb_deadlift',
      name: 'Deadlift',
      category: ExerciseCategory.barbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Back', 'Legs', 'Grip'],
      equipment: ['Barbell'],
    ),
    Exercise(
      id: 'bb_rdl',
      name: 'Romanian Deadlift (RDL)',
      category: ExerciseCategory.barbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Hamstrings', 'Glutes', 'Back'],
      equipment: ['Barbell'],
    ),
    Exercise(
      id: 'bb_overhead_press',
      name: 'Overhead Press',
      category: ExerciseCategory.barbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Shoulders', 'Triceps'],
      equipment: ['Barbell'],
    ),
    Exercise(
      id: 'bb_bent_row',
      name: 'Bent-over Row',
      category: ExerciseCategory.barbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Back', 'Biceps'],
      equipment: ['Barbell'],
    ),

    // ========== DUMBBELL EXERCISES ==========
    Exercise(
      id: 'db_chest_press',
      name: 'Dumbbell Chest Press',
      category: ExerciseCategory.dumbbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Chest', 'Triceps', 'Shoulders'],
      equipment: ['Dumbbells', 'Bench'],
    ),
    Exercise(
      id: 'db_shoulder_press',
      name: 'Dumbbell Shoulder Press',
      category: ExerciseCategory.dumbbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Shoulders', 'Triceps'],
      equipment: ['Dumbbells'],
    ),
    Exercise(
      id: 'db_rows',
      name: 'Dumbbell Rows',
      category: ExerciseCategory.dumbbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Back', 'Biceps'],
      equipment: ['Dumbbells'],
    ),
    Exercise(
      id: 'db_curls',
      name: 'Dumbbell Curls',
      category: ExerciseCategory.dumbbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Biceps'],
      equipment: ['Dumbbells'],
    ),
    Exercise(
      id: 'db_tricep_extension',
      name: 'Tricep Extensions',
      category: ExerciseCategory.dumbbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Triceps'],
      equipment: ['Dumbbells'],
    ),
    Exercise(
      id: 'db_goblet_squat',
      name: 'Goblet Squat',
      category: ExerciseCategory.dumbbell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Legs', 'Glutes', 'Core'],
      equipment: ['Dumbbell'],
    ),

    // ========== KETTLEBELL EXERCISES ==========
    Exercise(
      id: 'kb_swing',
      name: 'Kettlebell Swing',
      category: ExerciseCategory.kettlebell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Glutes', 'Hamstrings', 'Core'],
      equipment: ['Kettlebell'],
    ),
    Exercise(
      id: 'kb_turkish_getup',
      name: 'Turkish Get-up',
      category: ExerciseCategory.kettlebell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Full Body', 'Core', 'Shoulders'],
      equipment: ['Kettlebell'],
    ),
    Exercise(
      id: 'kb_goblet_squat',
      name: 'Kettlebell Goblet Squat',
      category: ExerciseCategory.kettlebell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Legs', 'Glutes'],
      equipment: ['Kettlebell'],
    ),
    Exercise(
      id: 'kb_clean',
      name: 'Kettlebell Clean',
      category: ExerciseCategory.kettlebell,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.fitness_center,
      muscleGroups: ['Full Body', 'Shoulders'],
      equipment: ['Kettlebell'],
    ),

    // ========== MEDICINE BALL EXERCISES ==========
    Exercise(
      id: 'mb_slam',
      name: 'Medicine Ball Slam',
      category: ExerciseCategory.medicineBall,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.sports_basketball,
      muscleGroups: ['Core', 'Shoulders', 'Full Body'],
      equipment: ['Medicine ball'],
    ),
    Exercise(
      id: 'mb_wall_ball',
      name: 'Wall Balls',
      category: ExerciseCategory.medicineBall,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.sports_basketball,
      muscleGroups: ['Legs', 'Shoulders', 'Core'],
      equipment: ['Medicine ball', 'Wall'],
    ),
    Exercise(
      id: 'mb_russian_twist',
      name: 'Russian Twists',
      category: ExerciseCategory.medicineBall,
      measurementType: MeasurementType.repsWeight,
      icon: Icons.sports_basketball,
      muscleGroups: ['Core', 'Obliques'],
      equipment: ['Medicine ball'],
    ),

    // ========== RESISTANCE BAND EXERCISES ==========
    Exercise(
      id: 'rb_chest_fly',
      name: 'Band Chest Fly',
      category: ExerciseCategory.band,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.sports,
      muscleGroups: ['Chest'],
      equipment: ['Resistance band'],
    ),
    Exercise(
      id: 'rb_row',
      name: 'Band Row',
      category: ExerciseCategory.band,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.sports,
      muscleGroups: ['Back'],
      equipment: ['Resistance band'],
    ),
    Exercise(
      id: 'rb_bicep_curl',
      name: 'Band Bicep Curl',
      category: ExerciseCategory.band,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.sports,
      muscleGroups: ['Biceps'],
      equipment: ['Resistance band'],
    ),
    Exercise(
      id: 'rb_lateral_raise',
      name: 'Band Lateral Raise',
      category: ExerciseCategory.band,
      measurementType: MeasurementType.repsOnly,
      icon: Icons.sports,
      muscleGroups: ['Shoulders'],
      equipment: ['Resistance band'],
    ),

    // ========== CARDIO EXERCISES ==========
    Exercise(
      id: 'cardio_run_distance',
      name: 'Long Distance Run',
      category: ExerciseCategory.cardio,
      measurementType: MeasurementType.timeDistance,
      icon: Icons.directions_run,
      muscleGroups: ['Legs', 'Cardio'],
      equipment: [],
    ),
    Exercise(
      id: 'cardio_run_interval',
      name: 'Tempo Run',
      category: ExerciseCategory.cardio,
      measurementType: MeasurementType.intervals,
      icon: Icons.speed,
      muscleGroups: ['Legs', 'Cardio'],
      equipment: [],
    ),
    Exercise(
      id: 'cardio_walk_run',
      name: 'Walk/Run Intervals',
      category: ExerciseCategory.cardio,
      measurementType: MeasurementType.intervals,
      icon: Icons.directions_walk,
      muscleGroups: ['Legs', 'Cardio'],
      equipment: [],
    ),
    Exercise(
      id: 'cardio_swim',
      name: 'Swimming',
      category: ExerciseCategory.cardio,
      measurementType: MeasurementType.timeDistance,
      icon: Icons.pool,
      muscleGroups: ['Full Body', 'Cardio'],
      equipment: ['Pool'],
    ),
    Exercise(
      id: 'cardio_bike',
      name: 'Biking',
      category: ExerciseCategory.cardio,
      measurementType: MeasurementType.timeDistance,
      icon: Icons.directions_bike,
      muscleGroups: ['Legs', 'Cardio'],
      equipment: ['Bike'],
    ),
  ];

  /// Get all exercises
  static List<Exercise> getAllExercises() => List.unmodifiable(_exercises);

  /// Get exercise by ID
  static Exercise? getExercise(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get exercises by category
  static List<Exercise> getExercisesByCategory(ExerciseCategory category) {
    return _exercises.where((e) => e.category == category).toList();
  }

  /// Get exercises by measurement type
  static List<Exercise> getExercisesByMeasurementType(MeasurementType type) {
    return _exercises.where((e) => e.measurementType == type).toList();
  }

  /// Search exercises by name (case-insensitive)
  static List<Exercise> searchExercises(String query) {
    final lowerQuery = query.toLowerCase();
    return _exercises
        .where((e) =>
            e.name.toLowerCase().contains(lowerQuery) ||
            e.muscleGroups.any((mg) => mg.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  /// Get exercises count
  static int get count => _exercises.length;
}
