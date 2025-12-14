import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';

/// Immutable exercise entity representing a type of workout exercise
@immutable
class Exercise {
  final String id;
  final String name;
  final ExerciseCategory category;
  final MeasurementType measurementType;
  final IconData icon;
  final List<String> equipment;
  final List<String> muscleGroups;

  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.measurementType,
    required this.icon,
    this.equipment = const [],
    this.muscleGroups = const [],
  });

  /// Create a copy with modified fields
  Exercise copyWith({
    String? id,
    String? name,
    ExerciseCategory? category,
    MeasurementType? measurementType,
    IconData? icon,
    List<String>? equipment,
    List<String>? muscleGroups,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      measurementType: measurementType ?? this.measurementType,
      icon: icon ?? this.icon,
      equipment: equipment ?? this.equipment,
      muscleGroups: muscleGroups ?? this.muscleGroups,
    );
  }

  /// Convert to JSON (for serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'measurementType': measurementType.name,
      'iconCodePoint': icon.codePoint,
      'equipment': equipment,
      'muscleGroups': muscleGroups,
    };
  }

  /// Create from JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      measurementType: MeasurementType.values.firstWhere(
        (e) => e.name == json['measurementType'],
      ),
      icon: IconData(
        json['iconCodePoint'] as int,
        fontFamily: 'MaterialIcons',
      ),
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      muscleGroups: (json['muscleGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, category: ${category.displayName})';
  }
}
