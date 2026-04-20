// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_point_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PricePointModelAdapter extends TypeAdapter<PricePointModel> {
  @override
  final int typeId = 2;

  @override
  PricePointModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PricePointModel(
      date: fields[0] as DateTime,
      value: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PricePointModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PricePointModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PricePointModel _$PricePointModelFromJson(Map<String, dynamic> json) =>
    PricePointModel(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$PricePointModelToJson(PricePointModel instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
    };
