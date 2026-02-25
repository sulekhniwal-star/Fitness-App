// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodLogModelAdapter extends TypeAdapter<FoodLogModel> {
  @override
  final int typeId = 1;

  @override
  FoodLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodLogModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      mealType: fields[3] as String,
      foodItemId: fields[4] as String,
      foodName: fields[5] as String,
      quantityGrams: fields[6] as double,
      calories: fields[7] as double,
      proteinGrams: fields[8] as double,
      carbsGrams: fields[9] as double,
      fatGrams: fields[10] as double,
      loggedVia: fields[11] as String,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      isSynced: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FoodLogModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.mealType)
      ..writeByte(4)
      ..write(obj.foodItemId)
      ..writeByte(5)
      ..write(obj.foodName)
      ..writeByte(6)
      ..write(obj.quantityGrams)
      ..writeByte(7)
      ..write(obj.calories)
      ..writeByte(8)
      ..write(obj.proteinGrams)
      ..writeByte(9)
      ..write(obj.carbsGrams)
      ..writeByte(10)
      ..write(obj.fatGrams)
      ..writeByte(11)
      ..write(obj.loggedVia)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
