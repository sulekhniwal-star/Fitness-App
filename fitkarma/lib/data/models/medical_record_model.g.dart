// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicalRecordModelAdapter extends TypeAdapter<MedicalRecordModel> {
  @override
  final int typeId = 3;

  @override
  MedicalRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalRecordModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      type: fields[2] as String,
      value: fields[3] as String,
      unit: fields[4] as String,
      date: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalRecordModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
