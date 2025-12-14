import 'package:hive/hive.dart';
import '../../domain/models/workout_session.dart';
import '../../core/constants/enums.dart';

part 'workout_session_hive.g.dart';

@HiveType(typeId: 1)
class WorkoutSessionHive extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> exerciseIds;

  @HiveField(3)
  final int? plannedDayIndex;

  @HiveField(4)
  final bool isActive;

  @HiveField(5)
  final bool completedThisWeek;

  @HiveField(6)
  final DateTime weekStartDate;

  @HiveField(7)
  final DateTime? lastCompletedDate;

  @HiveField(8)
  final DateTime createdAt;

  WorkoutSessionHive({
    required this.id,
    required this.name,
    required this.exerciseIds,
    this.plannedDayIndex,
    required this.isActive,
    required this.completedThisWeek,
    required this.weekStartDate,
    this.lastCompletedDate,
    required this.createdAt,
  });

  /// Convert from domain model
  factory WorkoutSessionHive.fromDomain(WorkoutSession session) {
    return WorkoutSessionHive(
      id: session.id,
      name: session.name,
      exerciseIds: List<String>.from(session.exerciseIds),
      plannedDayIndex: session.plannedDay?.index,
      isActive: session.isActive,
      completedThisWeek: session.completedThisWeek,
      weekStartDate: session.weekStartDate,
      lastCompletedDate: session.lastCompletedDate,
      createdAt: session.createdAt,
    );
  }

  /// Convert to domain model
  WorkoutSession toDomain() {
    return WorkoutSession(
      id: id,
      name: name,
      exerciseIds: List<String>.from(exerciseIds),
      plannedDay: plannedDayIndex != null ? WeekDay.values[plannedDayIndex!] : null,
      isActive: isActive,
      completedThisWeek: completedThisWeek,
      weekStartDate: weekStartDate,
      lastCompletedDate: lastCompletedDate,
      createdAt: createdAt,
    );
  }
}
