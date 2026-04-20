import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:wealth_lens/core/errors/failures.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/repositories/asset_repository.dart';

@injectable
class SaveAssetUseCase {
  SaveAssetUseCase(this._repository);

  final AssetRepository _repository;

  Future<Either<Failure, Unit>> call(Asset asset) {
    final now = DateTime.now();
    final isNew = asset.id.isEmpty;
    final toSave = asset.copyWith(
      id: isNew ? const Uuid().v4() : asset.id,
      createdAt: isNew ? now : asset.createdAt,
      updatedAt: now,
    );
    return _repository.saveAsset(toSave);
  }
}
