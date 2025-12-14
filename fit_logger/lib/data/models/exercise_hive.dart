import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../../domain/models/exercise.dart';
import '../../core/constants/enums.dart';

part 'exercise_hive.g.dart';

@HiveType(typeId: 0)
class ExerciseHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int categoryIndex;

  @HiveField(3)
  final int measurementTypeIndex;

  @HiveField(4)
  final int iconCodePoint;

  @HiveField(5)
  final List<String> equipment;

  @HiveField(6)
  final List<String> muscleGroups;

  ExerciseHive({
    required this.id,
    required this.name,
    required this.categoryIndex,
    required this.measurementTypeIndex,
    required this.iconCodePoint,
    required this.equipment,
    required this.muscleGroups,
  });

  /// Convert from domain model
  factory ExerciseHive.fromDomain(Exercise exercise) {
    return ExerciseHive(
      id: exercise.id,
      name: exercise.name,
      categoryIndex: exercise.category.index,
      measurementTypeIndex: exercise.measurementType.index,
      iconCodePoint: exercise.icon.codePoint,
      equipment: List<String>.from(exercise.equipment),
      muscleGroups: List<String>.from(exercise.muscleGroups),
    );
  }

  /// Convert to domain model
  Exercise toDomain() {
    return Exercise(
      id: id,
      name: name,
      category: ExerciseCategory.values[categoryIndex],
      measurementType: MeasurementType.values[measurementTypeIndex],
      icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
      equipment: List<String>.from(equipment),
      muscleGroups: List<String>.from(muscleGroups),
    );
  }
}
