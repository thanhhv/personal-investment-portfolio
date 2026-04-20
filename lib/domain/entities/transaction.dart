import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

enum TransactionType {
  buy,
  sell,
  update;

  String get key => name;

  static TransactionType fromKey(String key) =>
      TransactionType.values.firstWhere((e) => e.name == key);
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required TransactionType type,
    required double amount,
    required DateTime date,
    double? quantity,
    double? pricePerUnit,
    String? note,
  }) = _Transaction;
}
