// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityLogModelAdapter extends TypeAdapter<ActivityLogModel> {
  @override
  final int typeId = 15;

  @override
  ActivityLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityLogModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      activityType: fields[2] as String,
      description: fields[3] as String,
      timestamp: fields[4] as DateTime,
      metadata: (fields[5] as Map).cast<String, dynamic>(),
      karmaPoints: fields[6] as int?,
      relatedRecordId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityLogModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.activityType)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.metadata)
      ..writeByte(6)
      ..write(obj.karmaPoints)
      ..writeByte(7)
      ..write(obj.relatedRecordId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
