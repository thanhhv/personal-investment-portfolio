import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/core/errors/failures.dart';
import 'package:wealth_lens/domain/repositories/asset_repository.dart';

@injectable
class DeleteAssetUseCase {
  DeleteAssetUseCase(this._repository);

  final AssetRepository _repository;

  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deleteAsset(id);
}
