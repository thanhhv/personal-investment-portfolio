import 'package:equatable/equatable.dart';
import 'package:wealth_lens/domain/usecases/import_portfolio_usecase.dart';

enum SettingsStatus {
  idle,
  busy,
  previewReady,
  exportSuccess,
  importSuccess,
  failure,
}

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.idle,
    this.importPreview,
    this.errorMessage,
    this.appVersion,
  });

  final SettingsStatus status;
  final ImportPreview? importPreview;
  final String? errorMessage;
  final String? appVersion;

  bool get isBusy => status == SettingsStatus.busy;

  SettingsState copyWith({
    SettingsStatus? status,
    ImportPreview? importPreview,
    String? errorMessage,
    String? appVersion,
  }) =>
      SettingsState(
        status: status ?? this.status,
        importPreview: importPreview ?? this.importPreview,
        errorMessage: errorMessage ?? this.errorMessage,
        appVersion: appVersion ?? this.appVersion,
      );

  SettingsState withStatus(SettingsStatus status) => SettingsState(
        status: status,
        appVersion: appVersion,
      );

  @override
  List<Object?> get props => [status, importPreview, errorMessage, appVersion];
}
