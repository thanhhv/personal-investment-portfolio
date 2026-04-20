import 'package:equatable/equatable.dart';
import 'package:wealth_lens/domain/usecases/import_portfolio_usecase.dart';

enum SettingsStatus { idle, busy, previewReady, success, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.idle,
    this.importPreview,
    this.successMessage,
    this.errorMessage,
  });

  final SettingsStatus status;
  final ImportPreview? importPreview;
  final String? successMessage;
  final String? errorMessage;

  bool get isBusy => status == SettingsStatus.busy;

  SettingsState copyWith({
    SettingsStatus? status,
    ImportPreview? importPreview,
    String? successMessage,
    String? errorMessage,
  }) =>
      SettingsState(
        status: status ?? this.status,
        importPreview: importPreview ?? this.importPreview,
        successMessage: successMessage ?? this.successMessage,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, importPreview, successMessage, errorMessage];
}
