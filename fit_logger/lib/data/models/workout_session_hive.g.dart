// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSessionHiveAdapter extends TypeAdapter<WorkoutSessionHive> {
  @override
  final int typeId = 1;

  @override
  WorkoutSessionHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSessionHive(
      id: fields[0] as String,
      name: fields[1] as String,
      exerciseIds: (fields[2] as List).cast<String>(),
      plannedDayIndex: fields[3] as int?,
      isActive: fields[4] as bool,
      completedThisWeek: fields[5] as bool,
      weekStartDate: fields[6] as DateTime,
      lastCompletedDate: fields[7] as DateTime?,
      createdAt: fields[8] as DateTime,
      plannedDetailsMap:
          (fields[9] as Map?)?.cast<String, PlannedExerciseDetailsHive>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSessionHive obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.exerciseIds)
      ..writeByte(3)
      ..write(obj.plannedDayIndex)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.completedThisWeek)
      ..writeByte(6)
      ..write(obj.weekStartDate)
      ..writeByte(7)
      ..write(obj.lastCompletedDate)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.plannedDetailsMap);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessionHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
