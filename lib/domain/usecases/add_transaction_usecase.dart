import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:wealth_lens/core/errors/failures.dart';
import 'package:wealth_lens/domain/entities/transaction.dart';
import 'package:wealth_lens/domain/repositories/asset_repository.dart';

@injectable
class AddTransactionUseCase {
  AddTransactionUseCase(this._repository);

  final AssetRepository _repository;

  Future<Either<Failure, Unit>> call(String assetId, Transaction tx) {
    final withId = tx.id.isEmpty ? tx.copyWith(id: const Uuid().v4()) : tx;
    return _repository.addTransaction(assetId, withId);
  }
}
