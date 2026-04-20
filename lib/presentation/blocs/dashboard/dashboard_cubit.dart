import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/domain/usecases/get_all_assets_usecase.dart';
import 'package:wealth_lens/presentation/blocs/dashboard/dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getAllAssets) : super(const DashboardState());

  final GetAllAssetsUseCase _getAllAssets;

  Future<void> load() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    final result = await _getAllAssets();
    result.fold(
      (failure) => emit(DashboardState(
        status: DashboardStatus.failure,
        errorMessage: failure.message,
      ),),
      (assets) => emit(DashboardState(
        status: DashboardStatus.success,
        assets: assets,
      ),),
    );
  }
}
