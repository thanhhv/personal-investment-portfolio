import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/domain/usecases/delete_asset_usecase.dart';
import 'package:wealth_lens/domain/usecases/delete_transaction_usecase.dart';
import 'package:wealth_lens/domain/usecases/get_asset_by_id_usecase.dart';
import 'package:wealth_lens/presentation/blocs/asset_detail/asset_detail_state.dart';

@injectable
class AssetDetailCubit extends Cubit<AssetDetailState> {
  AssetDetailCubit(
    this._getById,
    this._deleteAsset,
    this._deleteTx,
  ) : super(const AssetDetailState());

  final GetAssetByIdUseCase _getById;
  final DeleteAssetUseCase _deleteAsset;
  final DeleteTransactionUseCase _deleteTx;

  Future<void> load(String assetId) async {
    emit(const AssetDetailState(status: AssetDetailStatus.loading));
    final result = await _getById(assetId);
    result.fold(
      (failure) => emit(AssetDetailState(
        status: AssetDetailStatus.failure,
        errorMessage: failure.message,
      ),),
      (asset) => emit(AssetDetailState(
        status: AssetDetailStatus.success,
        asset: asset,
      ),),
    );
  }

  Future<void> deleteAsset(String assetId) async {
    final result = await _deleteAsset(assetId);
    result.fold(
      (failure) => emit(AssetDetailState(
        status: AssetDetailStatus.failure,
        errorMessage: failure.message,
      ),),
      (_) => emit(const AssetDetailState(status: AssetDetailStatus.deleted)),
    );
  }

  Future<void> deleteTransaction(String assetId, String txId) async {
    await _deleteTx(assetId, txId);
    await load(assetId);
  }
}
