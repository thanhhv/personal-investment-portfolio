import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/core/errors/failures.dart';
import 'package:wealth_lens/data/datasources/hive_datasource.dart';
import 'package:wealth_lens/data/models/asset_model.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/entities/transaction.dart';
import 'package:wealth_lens/domain/repositories/asset_repository.dart';

@LazySingleton(as: AssetRepository)
class AssetRepositoryImpl implements AssetRepository {
  AssetRepositoryImpl(this._datasource);

  final HiveDatasource _datasource;

  @override
  Future<Either<Failure, List<Asset>>> getAllAssets() async {
    try {
      final models = _datasource.getAllAssets();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Object catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Asset>> getAssetById(String id) async {
    try {
      final model = _datasource.getAssetById(id);
      if (model == null) return const Left(NotFoundFailure('Asset not found'));
      return Right(model.toEntity());
    } on Object catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveAsset(Asset asset) async {
    try {
      await _datasource.saveAsset(AssetModel.fromEntity(asset));
      return const Right(unit);
    } on Object catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAsset(String id) async {
    try {
      await _datasource.deleteAsset(id);
      return const Right(unit);
    } on Object catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addTransaction(
    String assetId,
    Transaction tx,
  ) async {
    try {
      final model = _datasource.getAssetById(assetId);
      if (model == null) return const Left(NotFoundFailure('Asset not found'));
      final entity = model.toEntity();
      final updated = entity.copyWith(
        transactions: [...entity.transactions, tx],
        updatedAt: DateTime.now(),
      );
      await _datasource.saveAsset(AssetModel.fromEntity(updated));
      return const Right(unit);
    } on Object catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(
    String assetId,
    String txId,
  ) async {
    try {
      final model = _datasource.getAssetById(assetId);
      if (model == null) return const Left(NotFoundFailure('Asset not found'));
      final entity = model.toEntity();
      final updated = entity.copyWith(
        transactions: entity.transactions.where((t) => t.id != txId).toList(),
        updatedAt: DateTime.now(),
      );
      await _datasource.saveAsset(AssetModel.fromEntity(updated));
      return const Right(unit);
    } on Object catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> importAssets(
    List<Asset> assets, {
    required bool merge,
  }) async {
    try {
      if (!merge) await _datasource.deleteAll();
      await _datasource.saveAll(assets.map(AssetModel.fromEntity).toList());
      return const Right(unit);
    } on Object catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Asset>>> getAllAssetsRaw() => getAllAssets();
}
