// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutLogHiveAdapter extends TypeAdapter<WorkoutLogHive> {
  @override
  final int typeId = 6;

  @override
  WorkoutLogHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutLogHive(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      sessionName: fields[2] as String,
      timestamp: fields[3] as DateTime,
      exerciseLogsHive: (fields[4] as List).cast<dynamic>(),
      totalDuration: fields[5] as Duration?,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutLogHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.sessionName)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.exerciseLogsHive)
      ..writeByte(5)
      ..write(obj.totalDuration)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutLogHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
