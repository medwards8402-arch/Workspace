// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_exercise_details_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlannedExerciseDetailsHiveAdapter
    extends TypeAdapter<PlannedExerciseDetailsHive> {
  @override
  final int typeId = 7;

  @override
  PlannedExerciseDetailsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannedExerciseDetailsHive(
      exerciseId: fields[0] as String,
      measurementTypeIndex: fields[1] as int,
      plannedSets: fields[2] as int?,
      plannedRepsPerSet: (fields[3] as List?)?.cast<int>(),
      plannedWeightsPerSet: (fields[4] as List?)?.cast<double>(),
      plannedDuration: fields[5] as Duration?,
      plannedDistance: fields[6] as double?,
      plannedIntervalCount: fields[7] as int?,
      plannedRunDurations: (fields[8] as List?)?.cast<Duration>(),
      plannedWalkDurations: (fields[9] as List?)?.cast<Duration>(),
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlannedExerciseDetailsHive obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.measurementTypeIndex)
      ..writeByte(2)
      ..write(obj.plannedSets)
      ..writeByte(3)
      ..write(obj.plannedRepsPerSet)
      ..writeByte(4)
      ..write(obj.plannedWeightsPerSet)
      ..writeByte(5)
      ..write(obj.plannedDuration)
      ..writeByte(6)
      ..write(obj.plannedDistance)
      ..writeByte(7)
      ..write(obj.plannedIntervalCount)
      ..writeByte(8)
      ..write(obj.plannedRunDurations)
      ..writeByte(9)
      ..write(obj.plannedWalkDurations)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedExerciseDetailsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
