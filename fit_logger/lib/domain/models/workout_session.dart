import 'package:flutter/foundation.dart';
import '../../core/constants/enums.dart';

/// Mutable workout session template containing exercises
@immutable
class WorkoutSession {
  final String id;
  final String name;
  final List<String> exerciseIds;
  final WeekDay? plannedDay;
  final bool isActive;
  final bool completedThisWeek;
  final DateTime weekStartDate;
  final DateTime? lastCompletedDate;
  final DateTime createdAt;

  const WorkoutSession({
    required this.id,
    required this.name,
    required this.exerciseIds,
    this.plannedDay,
    this.isActive = true,
    this.completedThisWeek = false,
    required this.weekStartDate,
    this.lastCompletedDate,
    required this.createdAt,
  });

  /// Create a copy with modified fields
  WorkoutSession copyWith({
    String? id,
    String? name,
    List<String>? exerciseIds,
    WeekDay? plannedDay,
    bool? clearPlannedDay,
    bool? isActive,
    bool? completedThisWeek,
    DateTime? weekStartDate,
    DateTime? lastCompletedDate,
    bool? clearLastCompletedDate,
    DateTime? createdAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      name: name ?? this.name,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      plannedDay: clearPlannedDay == true ? null : (plannedDay ?? this.plannedDay),
      isActive: isActive ?? this.isActive,
      completedThisWeek: completedThisWeek ?? this.completedThisWeek,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      lastCompletedDate: clearLastCompletedDate == true
          ? null
          : (lastCompletedDate ?? this.lastCompletedDate),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Add an exercise to the session
  WorkoutSession addExercise(String exerciseId) {
    if (exerciseIds.contains(exerciseId)) {
      return this;
    }
    return copyWith(
      exerciseIds: [...exerciseIds, exerciseId],
    );
  }

  /// Remove an exercise from the session
  WorkoutSession removeExercise(String exerciseId) {
    return copyWith(
      exerciseIds: exerciseIds.where((id) => id != exerciseId).toList(),
    );
  }

  /// Mark the session as complete for this week
  WorkoutSession markComplete() {
    return copyWith(
      completedThisWeek: true,
      lastCompletedDate: DateTime.now(),
    );
  }

  /// Reset the weekly completion status
  WorkoutSession reset(DateTime newWeekStartDate) {
    return copyWith(
      completedThisWeek: false,
      weekStartDate: newWeekStartDate,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exerciseIds': exerciseIds,
      'plannedDay': plannedDay?.name,
      'isActive': isActive,
      'completedThisWeek': completedThisWeek,
      'weekStartDate': weekStartDate.toIso8601String(),
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      name: json['name'] as String,
      exerciseIds: (json['exerciseIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      plannedDay: json['plannedDay'] != null
          ? WeekDay.values.firstWhere((e) => e.name == json['plannedDay'])
          : null,
      isActive: json['isActive'] as bool? ?? true,
      completedThisWeek: json['completedThisWeek'] as bool? ?? false,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WorkoutSession(id: $id, name: $name, plannedDay: ${plannedDay?.displayName ?? "Unscheduled"}, exercises: ${exerciseIds.length})';
  }
}
