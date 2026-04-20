import 'package:equatable/equatable.dart';

enum AssetFormStatus { initial, saving, saved, failure }

class AssetFormState extends Equatable {
  const AssetFormState({
    this.status = AssetFormStatus.initial,
    this.errorMessage,
  });

  final AssetFormStatus status;
  final String? errorMessage;

  bool get isSaving => status == AssetFormStatus.saving;
  bool get isSaved => status == AssetFormStatus.saved;

  @override
  List<Object?> get props => [status, errorMessage];
}
