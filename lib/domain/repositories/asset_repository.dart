import 'package:fpdart/fpdart.dart';
import 'package:wealth_lens/core/errors/failures.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/entities/transaction.dart';

abstract class AssetRepository {
  Future<Either<Failure, List<Asset>>> getAllAssets();
  Future<Either<Failure, Asset>> getAssetById(String id);
  Future<Either<Failure, Unit>> saveAsset(Asset asset);
  Future<Either<Failure, Unit>> deleteAsset(String id);
  Future<Either<Failure, Unit>> addTransaction(String assetId, Transaction tx);
  Future<Either<Failure, Unit>> deleteTransaction(String assetId, String txId);
  Future<Either<Failure, Unit>> importAssets(
    List<Asset> assets, {
    required bool merge,
  });
  Future<Either<Failure, List<Asset>>> getAllAssetsRaw();
}
