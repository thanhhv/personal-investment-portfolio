import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/core/constants/asset_categories.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/entities/transaction.dart';
import 'package:wealth_lens/domain/usecases/get_all_assets_usecase.dart';
import 'package:wealth_lens/presentation/blocs/analytics/analytics_state.dart';

@injectable
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit(this._getAllAssets) : super(const AnalyticsState());

  final GetAllAssetsUseCase _getAllAssets;

  Future<void> load() async {
    emit(const AnalyticsState(status: AnalyticsStatus.loading));
    final result = await _getAllAssets();
    result.fold(
      (failure) => emit(AnalyticsState(
        status: AnalyticsStatus.failure,
        errorMessage: failure.message,
      ),),
      (assets) => emit(AnalyticsState(
        status: AnalyticsStatus.success,
        data: _computeAnalytics(assets),
      ),),
    );
  }
}

AnalyticsData _computeAnalytics(List<Asset> assets) {
  if (assets.isEmpty) return const AnalyticsData.empty();

  // ── Timeline ──────────────────────────────────────────────────────────────
  final dateSet = <DateTime>{};
  for (final asset in assets) {
    for (final tx in asset.transactions) {
      dateSet.add(
        DateTime(tx.date.year, tx.date.month, tx.date.day),
      );
    }
    for (final pp in asset.priceHistory) {
      dateSet.add(
        DateTime(pp.date.year, pp.date.month, pp.date.day),
      );
    }
  }
  final today = DateTime.now();
  dateSet.add(DateTime(today.year, today.month, today.day));
  final sortedDates = dateSet.toList()..sort();

  final timeline = <TimelinePoint>[];
  for (final date in sortedDates) {
    var invested = 0.0;
    var value = 0.0;
    for (final asset in assets) {
      final assetInvested = asset.transactions
          .where(
            (t) =>
                t.type == TransactionType.buy &&
                !DateTime(t.date.year, t.date.month, t.date.day).isAfter(date),
          )
          .fold<double>(0, (sum, t) => sum + t.amount);
      invested += assetInvested;

      final priceAtOrBefore = asset.priceHistory
          .where(
            (p) =>
                !DateTime(p.date.year, p.date.month, p.date.day).isAfter(date),
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      if (priceAtOrBefore.isNotEmpty) {
        value += priceAtOrBefore.last.value;
      } else {
        value += assetInvested;
      }
    }
    if (invested > 0) {
      timeline.add(
        TimelinePoint(
          date: date,
          totalInvested: invested,
          currentValue: value,
        ),
      );
    }
  }

  // ── Rankings ──────────────────────────────────────────────────────────────
  final ranked = [...assets]
    ..sort((a, b) => b.profitLossPercent.compareTo(a.profitLossPercent));

  // ── Category Breakdown ────────────────────────────────────────────────────
  final catValue = <AssetCategory, double>{};
  final catInvested = <AssetCategory, double>{};
  for (final asset in assets) {
    catValue[asset.category] =
        (catValue[asset.category] ?? 0) + asset.currentValue;
    catInvested[asset.category] =
        (catInvested[asset.category] ?? 0) + asset.totalInvested;
  }

  final totalValue =
      assets.fold<double>(0, (sum, a) => sum + a.currentValue);
  final totalInvested =
      assets.fold<double>(0, (sum, a) => sum + a.totalInvested);

  final breakdown = catValue.entries.map((e) {
    return CategoryBreakdown(
      category: e.key,
      totalValue: e.value,
      totalInvested: catInvested[e.key] ?? 0,
      allocation: totalValue > 0 ? e.value / totalValue * 100 : 0,
    );
  }).toList()
    ..sort((a, b) => b.totalValue.compareTo(a.totalValue));

  return AnalyticsData(
    timeline: timeline,
    rankedByPerformance: ranked,
    categoryBreakdown: breakdown,
    totalValue: totalValue,
    totalInvested: totalInvested,
  );
}
