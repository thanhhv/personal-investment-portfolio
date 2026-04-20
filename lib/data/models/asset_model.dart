import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wealth_lens/core/constants/asset_categories.dart';
import 'package:wealth_lens/data/models/price_point_model.dart';
import 'package:wealth_lens/data/models/transaction_model.dart';
import 'package:wealth_lens/domain/entities/asset.dart';

part 'asset_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable(explicitToJson: true)
class AssetModel extends HiveObject {
  AssetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.tags,
    required this.transactions,
    required this.priceHistory,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) =>
      _$AssetModelFromJson(json);

  factory AssetModel.fromEntity(Asset entity) => AssetModel(
        id: entity.id,
        name: entity.name,
        category: entity.category.key,
        tags: List<String>.from(entity.tags),
        transactions:
            entity.transactions.map(TransactionModel.fromEntity).toList(),
        priceHistory:
            entity.priceHistory.map(PricePointModel.fromEntity).toList(),
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        notes: entity.notes,
      );

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  List<String> tags;

  @HiveField(5)
  List<TransactionModel> transactions;

  @HiveField(6)
  List<PricePointModel> priceHistory;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  Map<String, dynamic> toJson() => _$AssetModelToJson(this);

  Asset toEntity() => Asset(
        id: id,
        name: name,
        category: AssetCategory.fromKey(category),
        notes: notes,
        tags: List<String>.from(tags),
        transactions: transactions.map((m) => m.toEntity()).toList(),
        priceHistory: priceHistory.map((m) => m.toEntity()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
