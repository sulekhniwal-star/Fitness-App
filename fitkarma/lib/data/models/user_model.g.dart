// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      email: fields[1] as String,
      phone: fields[2] as String?,
      name: fields[3] as String,
      dob: fields[4] as DateTime?,
      gender: fields[5] as String?,
      heightCm: fields[6] as double?,
      weightKg: fields[7] as double?,
      dosha: fields[8] as String?,
      preferredLanguage: fields[9] as String?,
      subscriptionTier: fields[10] as String? ?? 'free',
      karmaPoints: fields[11] as int? ?? 0,
      streakDays: fields[12] as int? ?? 0,
      lastLoginDate: fields[13] as DateTime?,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
      profileImageUrl: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.dob)
      ..writeByte(5)
      ..write(obj.gender)
      ..writeByte(6)
      ..write(obj.heightCm)
      ..writeByte(7)
      ..write(obj.weightKg)
      ..writeByte(8)
      ..write(obj.dosha)
      ..writeByte(9)
      ..write(obj.preferredLanguage)
      ..writeByte(10)
      ..write(obj.subscriptionTier)
      ..writeByte(11)
      ..write(obj.karmaPoints)
      ..writeByte(12)
      ..write(obj.streakDays)
      ..writeByte(13)
      ..write(obj.lastLoginDate)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.profileImageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
