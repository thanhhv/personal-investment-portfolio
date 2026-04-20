import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wealth_lens/core/constants/asset_categories.dart';
import 'package:wealth_lens/domain/entities/price_point.dart';
import 'package:wealth_lens/domain/entities/transaction.dart';

part 'asset.freezed.dart';

@freezed
class Asset with _$Asset {
  const factory Asset({
    required String id,
    required String name,
    required AssetCategory category,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? notes,
    @Default([]) List<String> tags,
    @Default([]) List<Transaction> transactions,
    @Default([]) List<PricePoint> priceHistory,
  }) = _Asset;

  // Private generative constructor required for computed getters with freezed
  const Asset._();

  double get totalInvested => transactions
      .where((t) => t.type == TransactionType.buy)
      .fold(0, (sum, t) => sum + t.amount);

  double get currentValue {
    if (priceHistory.isNotEmpty) {
      final sorted = [...priceHistory]
        ..sort((a, b) => a.date.compareTo(b.date));
      return sorted.last.value;
    }
    final updates = transactions
        .where((t) => t.type == TransactionType.update)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (updates.isNotEmpty) return updates.last.amount;
    return totalInvested;
  }

  double get profitLoss => currentValue - totalInvested;

  double get profitLossPercent =>
      totalInvested == 0 ? 0 : (profitLoss / totalInvested) * 100;
}
