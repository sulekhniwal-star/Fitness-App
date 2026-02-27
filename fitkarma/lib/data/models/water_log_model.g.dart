// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterLogModelAdapter extends TypeAdapter<WaterLogModel> {
  @override
  final int typeId = 18;

  @override
  WaterLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterLogModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      amountMl: fields[3] as int,
      goalMl: fields[4] as int?,
      time: fields[5] as DateTime?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WaterLogModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.amountMl)
      ..writeByte(4)
      ..write(obj.goalMl)
      ..writeByte(5)
      ..write(obj.time)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
