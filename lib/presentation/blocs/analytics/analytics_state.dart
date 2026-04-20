import 'package:equatable/equatable.dart';
import 'package:wealth_lens/core/constants/asset_categories.dart';
import 'package:wealth_lens/domain/entities/asset.dart';

class TimelinePoint extends Equatable {
  const TimelinePoint({
    required this.date,
    required this.totalInvested,
    required this.currentValue,
  });

  final DateTime date;
  final double totalInvested;
  final double currentValue;

  @override
  List<Object?> get props => [date, totalInvested, currentValue];
}

class CategoryBreakdown extends Equatable {
  const CategoryBreakdown({
    required this.category,
    required this.totalValue,
    required this.totalInvested,
    required this.allocation,
  });

  final AssetCategory category;
  final double totalValue;
  final double totalInvested;
  final double allocation;

  double get profitLoss => totalValue - totalInvested;
  double get profitLossPercent =>
      totalInvested == 0 ? 0 : (profitLoss / totalInvested) * 100;

  @override
  List<Object?> get props => [category, totalValue, totalInvested, allocation];
}

class AnalyticsData extends Equatable {
  const AnalyticsData({
    required this.timeline,
    required this.rankedByPerformance,
    required this.categoryBreakdown,
    required this.totalValue,
    required this.totalInvested,
  });

  const AnalyticsData.empty()
      : timeline = const [],
        rankedByPerformance = const [],
        categoryBreakdown = const [],
        totalValue = 0,
        totalInvested = 0;

  final List<TimelinePoint> timeline;
  final List<Asset> rankedByPerformance;
  final List<CategoryBreakdown> categoryBreakdown;
  final double totalValue;
  final double totalInvested;

  double get totalProfitLoss => totalValue - totalInvested;
  double get totalProfitLossPercent =>
      totalInvested == 0 ? 0 : (totalProfitLoss / totalInvested) * 100;

  @override
  List<Object?> get props => [
        timeline,
        rankedByPerformance,
        categoryBreakdown,
        totalValue,
        totalInvested,
      ];
}

enum AnalyticsStatus { initial, loading, success, failure }

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.data,
    this.errorMessage,
  });

  final AnalyticsStatus status;
  final AnalyticsData? data;
  final String? errorMessage;

  bool get isLoading => status == AnalyticsStatus.loading;

  @override
  List<Object?> get props => [status, data, errorMessage];
}
