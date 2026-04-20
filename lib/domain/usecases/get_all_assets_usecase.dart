import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/core/errors/failures.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/repositories/asset_repository.dart';

@injectable
class GetAllAssetsUseCase {
  GetAllAssetsUseCase(this._repository);

  final AssetRepository _repository;

  Future<Either<Failure, List<Asset>>> call() => _repository.getAllAssets();
}
