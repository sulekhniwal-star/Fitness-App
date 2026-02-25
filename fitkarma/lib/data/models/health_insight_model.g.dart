// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_insight_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthInsightAdapter extends TypeAdapter<HealthInsight> {
  @override
  final int typeId = 12;

  @override
  HealthInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthInsight(
      id: fields[0] as String,
      type: fields[1] as InsightType,
      title: fields[2] as String,
      description: fields[3] as String,
      category: fields[4] as InsightCategory,
      createdAt: fields[5] as DateTime,
      isRead: fields[6] as bool,
      score: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HealthInsight obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isRead)
      ..writeByte(7)
      ..write(obj.score);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightTypeAdapter extends TypeAdapter<InsightType> {
  @override
  final int typeId = 10;

  @override
  InsightType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InsightType.pattern;
      case 1:
        return InsightType.warning;
      case 2:
        return InsightType.recommendation;
      case 3:
        return InsightType.achievement;
      case 4:
        return InsightType.suggestion;
      default:
        return InsightType.pattern;
    }
  }

  @override
  void write(BinaryWriter writer, InsightType obj) {
    switch (obj) {
      case InsightType.pattern:
        writer.writeByte(0);
        break;
      case InsightType.warning:
        writer.writeByte(1);
        break;
      case InsightType.recommendation:
        writer.writeByte(2);
        break;
      case InsightType.achievement:
        writer.writeByte(3);
        break;
      case InsightType.suggestion:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InsightCategoryAdapter extends TypeAdapter<InsightCategory> {
  @override
  final int typeId = 11;

  @override
  InsightCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InsightCategory.diet;
      case 1:
        return InsightCategory.activity;
      case 2:
        return InsightCategory.sleep;
      case 3:
        return InsightCategory.medical;
      default:
        return InsightCategory.diet;
    }
  }

  @override
  void write(BinaryWriter writer, InsightCategory obj) {
    switch (obj) {
      case InsightCategory.diet:
        writer.writeByte(0);
        break;
      case InsightCategory.activity:
        writer.writeByte(1);
        break;
      case InsightCategory.sleep:
        writer.writeByte(2);
        break;
      case InsightCategory.medical:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsightCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
