import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/domain/usecases/export_portfolio_usecase.dart';
import 'package:wealth_lens/domain/usecases/import_portfolio_usecase.dart';
import 'package:wealth_lens/presentation/blocs/settings/settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._export, this._import) : super(const SettingsState());

  final ExportPortfolioUseCase _export;
  final ImportPortfolioUseCase _import;

  Future<void> exportPortfolio() async {
    emit(const SettingsState(status: SettingsStatus.busy));
    final result = await _export();
    result.fold(
      (f) => emit(
        SettingsState(
          status: SettingsStatus.failure,
          errorMessage: f.message,
        ),
      ),
      (_) => emit(
        const SettingsState(
          status: SettingsStatus.success,
          successMessage: 'Portfolio exported successfully',
        ),
      ),
    );
  }

  Future<void> pickImportFile() async {
    emit(const SettingsState(status: SettingsStatus.busy));
    final result = await _import.pickAndPreview();
    result.fold(
      (f) => emit(
        SettingsState(
          status: SettingsStatus.failure,
          errorMessage: f.message,
        ),
      ),
      (preview) => emit(
        SettingsState(
          status: SettingsStatus.previewReady,
          importPreview: preview,
        ),
      ),
    );
  }

  Future<void> confirmImport({required bool merge}) async {
    final preview = state.importPreview;
    if (preview == null) return;
    emit(const SettingsState(status: SettingsStatus.busy));
    final result = await _import.confirm(preview, merge: merge);
    result.fold(
      (f) => emit(
        SettingsState(
          status: SettingsStatus.failure,
          errorMessage: f.message,
        ),
      ),
      (_) => emit(
        const SettingsState(
          status: SettingsStatus.success,
          successMessage: 'Portfolio imported successfully',
        ),
      ),
    );
  }

  void dismissPreview() => emit(const SettingsState());

  void resetStatus() => emit(const SettingsState());
}
