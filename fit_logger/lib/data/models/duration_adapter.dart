import 'package:hive/hive.dart';

/// Hive TypeAdapter for Duration
/// Stores Duration as milliseconds (int)
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 100; // Use a unique typeId not used by other adapters

  @override
  Duration read(BinaryReader reader) {
    final milliseconds = reader.readInt();
    return Duration(milliseconds: milliseconds);
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMilliseconds);
  }
}
