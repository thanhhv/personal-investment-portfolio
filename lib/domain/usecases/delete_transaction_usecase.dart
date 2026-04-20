import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/core/errors/failures.dart';
import 'package:wealth_lens/domain/repositories/asset_repository.dart';

@injectable
class DeleteTransactionUseCase {
  DeleteTransactionUseCase(this._repository);

  final AssetRepository _repository;

  Future<Either<Failure, Unit>> call(String assetId, String txId) =>
      _repository.deleteTransaction(assetId, txId);
}
