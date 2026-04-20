import 'package:hive_flutter/hive_flutter.dart';
import 'package:wealth_lens/data/models/asset_model.dart';

class HiveDatasource {
  HiveDatasource(this._box);

  final Box<AssetModel> _box;

  List<AssetModel> getAllAssets() => _box.values.toList();

  AssetModel? getAssetById(String id) => _box.get(id);

  Future<void> saveAsset(AssetModel asset) => _box.put(asset.id, asset);

  Future<void> deleteAsset(String id) => _box.delete(id);

  Future<void> saveAll(List<AssetModel> assets) =>
      _box.putAll({for (final a in assets) a.id: a});

  Future<void> deleteAll() => _box.clear();
}
