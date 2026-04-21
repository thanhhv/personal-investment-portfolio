import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wealth_lens/domain/usecases/export_portfolio_usecase.dart';
import 'package:wealth_lens/domain/usecases/import_portfolio_usecase.dart';
import 'package:wealth_lens/presentation/blocs/settings/settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._export, this._import) : super(const SettingsState());

  final ExportPortfolioUseCase _export;
  final ImportPortfolioUseCase _import;

  Future<void> loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    emit(state.copyWith(appVersion: info.version));
  }

  Future<void> exportPortfolio({Rect sharePositionOrigin = Rect.zero}) async {
    emit(state.copyWith(status: SettingsStatus.busy));
    final result = await _export(sharePositionOrigin: sharePositionOrigin);
    result.fold(
      (f) => emit(
        SettingsState(
          status: SettingsStatus.failure,
          errorMessage: f.message,
          appVersion: state.appVersion,
        ),
      ),
      (_) => emit(state.withStatus(SettingsStatus.exportSuccess)),
    );
  }

  Future<void> pickImportFile() async {
    emit(state.copyWith(status: SettingsStatus.busy));
    final result = await _import.pickAndPreview();
    result.fold(
      (f) => emit(
        SettingsState(
          status: SettingsStatus.failure,
          errorMessage: f.message,
          appVersion: state.appVersion,
        ),
      ),
      (preview) => emit(
        SettingsState(
          status: SettingsStatus.previewReady,
          importPreview: preview,
          appVersion: state.appVersion,
        ),
      ),
    );
  }

  Future<void> confirmImport({required bool merge}) async {
    final preview = state.importPreview;
    if (preview == null) return;
    emit(state.copyWith(status: SettingsStatus.busy));
    final result = await _import.confirm(preview, merge: merge);
    result.fold(
      (f) => emit(
        SettingsState(
          status: SettingsStatus.failure,
          errorMessage: f.message,
          appVersion: state.appVersion,
        ),
      ),
      (_) => emit(state.withStatus(SettingsStatus.importSuccess)),
    );
  }

  void dismissPreview() => emit(state.withStatus(SettingsStatus.idle));

  void resetStatus() => emit(state.withStatus(SettingsStatus.idle));
}
