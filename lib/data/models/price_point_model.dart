import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wealth_lens/domain/entities/price_point.dart';

part 'price_point_model.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class PricePointModel {
  PricePointModel({required this.date, required this.value});

  factory PricePointModel.fromJson(Map<String, dynamic> json) =>
      _$PricePointModelFromJson(json);

  factory PricePointModel.fromEntity(PricePoint entity) =>
      PricePointModel(date: entity.date, value: entity.value);

  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double value;

  Map<String, dynamic> toJson() => _$PricePointModelToJson(this);

  PricePoint toEntity() => PricePoint(date: date, value: value);
}
