// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_point.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackingPointAdapter extends TypeAdapter<TrackingPoint> {
  @override
  final int typeId = 7;

  @override
  TrackingPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackingPoint(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      timestamp: fields[2] as DateTime,
      altitude: fields[3] as double?,
      speed: fields[4] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackingPoint obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.altitude)
      ..writeByte(4)
      ..write(obj.speed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
