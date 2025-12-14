// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepsOnlyLogHiveAdapter extends TypeAdapter<RepsOnlyLogHive> {
  @override
  final int typeId = 2;

  @override
  RepsOnlyLogHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepsOnlyLogHive(
      id: fields[0] as String,
      exerciseId: fields[1] as String,
      exerciseName: fields[2] as String,
      difficultyIndex: fields[3] as int,
      notes: fields[4] as String?,
      timestamp: fields[5] as DateTime,
      sets: fields[6] as int,
      repsPerSet: (fields[7] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, RepsOnlyLogHive obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.exerciseName)
      ..writeByte(3)
      ..write(obj.difficultyIndex)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.sets)
      ..writeByte(7)
      ..write(obj.repsPerSet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepsOnlyLogHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepsWeightLogHiveAdapter extends TypeAdapter<RepsWeightLogHive> {
  @override
  final int typeId = 3;

  @override
  RepsWeightLogHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepsWeightLogHive(
      id: fields[0] as String,
      exerciseId: fields[1] as String,
      exerciseName: fields[2] as String,
      difficultyIndex: fields[3] as int,
      notes: fields[4] as String?,
      timestamp: fields[5] as DateTime,
      sets: fields[6] as int,
      repsPerSet: (fields[7] as List).cast<int>(),
      weightsPerSet: (fields[8] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, RepsWeightLogHive obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.exerciseName)
      ..writeByte(3)
      ..write(obj.difficultyIndex)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.sets)
      ..writeByte(7)
      ..write(obj.repsPerSet)
      ..writeByte(8)
      ..write(obj.weightsPerSet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepsWeightLogHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimeDistanceLogHiveAdapter extends TypeAdapter<TimeDistanceLogHive> {
  @override
  final int typeId = 4;

  @override
  TimeDistanceLogHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeDistanceLogHive(
      id: fields[0] as String,
      exerciseId: fields[1] as String,
      exerciseName: fields[2] as String,
      difficultyIndex: fields[3] as int,
      notes: fields[4] as String?,
      timestamp: fields[5] as DateTime,
      duration: fields[6] as Duration,
      distance: fields[7] as double,
      speed: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TimeDistanceLogHive obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.exerciseName)
      ..writeByte(3)
      ..write(obj.difficultyIndex)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.distance)
      ..writeByte(8)
      ..write(obj.speed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeDistanceLogHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IntervalsLogHiveAdapter extends TypeAdapter<IntervalsLogHive> {
  @override
  final int typeId = 5;

  @override
  IntervalsLogHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IntervalsLogHive(
      id: fields[0] as String,
      exerciseId: fields[1] as String,
      exerciseName: fields[2] as String,
      difficultyIndex: fields[3] as int,
      notes: fields[4] as String?,
      timestamp: fields[5] as DateTime,
      intervalCount: fields[6] as int,
      runDurations: (fields[7] as List).cast<Duration>(),
      walkDurations: (fields[8] as List).cast<Duration>(),
      speeds: (fields[9] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, IntervalsLogHive obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.exerciseName)
      ..writeByte(3)
      ..write(obj.difficultyIndex)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.intervalCount)
      ..writeByte(7)
      ..write(obj.runDurations)
      ..writeByte(8)
      ..write(obj.walkDurations)
      ..writeByte(9)
      ..write(obj.speeds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntervalsLogHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
