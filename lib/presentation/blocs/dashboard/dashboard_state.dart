import 'package:equatable/equatable.dart';
import 'package:wealth_lens/domain/entities/asset.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.assets = const [],
    this.errorMessage,
  });

  final DashboardStatus status;
  final List<Asset> assets;
  final String? errorMessage;

  bool get isLoading => status == DashboardStatus.loading;
  bool get isEmpty => status == DashboardStatus.success && assets.isEmpty;

  double get totalValue => assets.fold(0, (sum, a) => sum + a.currentValue);
  double get totalInvested => assets.fold(0, (sum, a) => sum + a.totalInvested);
  double get totalProfitLoss => totalValue - totalInvested;
  double get totalProfitLossPercent =>
      totalInvested == 0 ? 0 : (totalProfitLoss / totalInvested) * 100;

  DashboardState copyWith({
    DashboardStatus? status,
    List<Asset>? assets,
    String? errorMessage,
  }) =>
      DashboardState(
        status: status ?? this.status,
        assets: assets ?? this.assets,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, assets, errorMessage];
}
