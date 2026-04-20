import 'package:equatable/equatable.dart';
import 'package:wealth_lens/domain/entities/asset.dart';

enum AssetDetailStatus { initial, loading, success, failure, deleted }

class AssetDetailState extends Equatable {
  const AssetDetailState({
    this.status = AssetDetailStatus.initial,
    this.asset,
    this.errorMessage,
  });

  final AssetDetailStatus status;
  final Asset? asset;
  final String? errorMessage;

  bool get isLoading => status == AssetDetailStatus.loading;
  bool get isDeleted => status == AssetDetailStatus.deleted;

  @override
  List<Object?> get props => [status, asset, errorMessage];
}
