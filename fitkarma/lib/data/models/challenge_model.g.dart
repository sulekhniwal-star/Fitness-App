// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeModelAdapter extends TypeAdapter<ChallengeModel> {
  @override
  final int typeId = 6;

  @override
  ChallengeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      goalType: fields[3] as String,
      goalValue: fields[4] as double,
      rewardPoints: fields[5] as int,
      startDate: fields[6] as DateTime,
      endDate: fields[7] as DateTime,
      participants: (fields[8] as List).cast<String>(),
      imageUrl: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.goalType)
      ..writeByte(4)
      ..write(obj.goalValue)
      ..writeByte(5)
      ..write(obj.rewardPoints)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.participants)
      ..writeByte(9)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
