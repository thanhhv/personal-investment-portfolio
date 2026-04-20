import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/usecases/save_asset_usecase.dart';
import 'package:wealth_lens/presentation/blocs/asset_form/asset_form_state.dart';

@injectable
class AssetFormCubit extends Cubit<AssetFormState> {
  AssetFormCubit(this._saveAsset) : super(const AssetFormState());

  final SaveAssetUseCase _saveAsset;

  Future<void> save(Asset asset) async {
    emit(const AssetFormState(status: AssetFormStatus.saving));
    final result = await _saveAsset(asset);
    result.fold(
      (failure) => emit(AssetFormState(
        status: AssetFormStatus.failure,
        errorMessage: failure.message,
      ),),
      (_) => emit(const AssetFormState(status: AssetFormStatus.saved)),
    );
  }
}
