import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wealth_lens/domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class TransactionModel {
  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.quantity,
    this.pricePerUnit,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  factory TransactionModel.fromEntity(Transaction entity) => TransactionModel(
        id: entity.id,
        type: entity.type.key,
        amount: entity.amount,
        date: entity.date,
        quantity: entity.quantity,
        pricePerUnit: entity.pricePerUnit,
        note: entity.note,
      );

  @HiveField(0)
  String id;

  @HiveField(1)
  String type;

  @HiveField(2)
  double amount;

  @HiveField(3)
  double? quantity;

  @HiveField(4)
  double? pricePerUnit;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? note;

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  Transaction toEntity() => Transaction(
        id: id,
        type: TransactionType.fromKey(type),
        amount: amount,
        quantity: quantity,
        pricePerUnit: pricePerUnit,
        date: date,
        note: note,
      );
}
