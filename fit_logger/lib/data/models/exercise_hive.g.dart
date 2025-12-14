// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseHiveAdapter extends TypeAdapter<ExerciseHive> {
  @override
  final int typeId = 0;

  @override
  ExerciseHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseHive(
      id: fields[0] as String,
      name: fields[1] as String,
      categoryIndex: fields[2] as int,
      measurementTypeIndex: fields[3] as int,
      iconCodePoint: fields[4] as int,
      equipment: (fields[5] as List).cast<String>(),
      muscleGroups: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.categoryIndex)
      ..writeByte(3)
      ..write(obj.measurementTypeIndex)
      ..writeByte(4)
      ..write(obj.iconCodePoint)
      ..writeByte(5)
      ..write(obj.equipment)
      ..writeByte(6)
      ..write(obj.muscleGroups);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
