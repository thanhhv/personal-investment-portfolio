import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/core/errors/failures.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/repositories/asset_repository.dart';

@injectable
class GetAssetByIdUseCase {
  GetAssetByIdUseCase(this._repository);

  final AssetRepository _repository;

  Future<Either<Failure, Asset>> call(String id) =>
      _repository.getAssetById(id);
}
