import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wealth_lens/app.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/data/datasources/hive_datasource.dart';
import 'package:wealth_lens/data/models/asset_model.dart';
import 'package:wealth_lens/data/models/price_point_model.dart';
import 'package:wealth_lens/data/models/transaction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(AssetModelAdapter())
    ..registerAdapter(TransactionModelAdapter())
    ..registerAdapter(PricePointModelAdapter());
  final assetBox = await Hive.openBox<AssetModel>('assets');

  await configureDependencies();
  getIt.registerSingleton<HiveDatasource>(HiveDatasource(assetBox));

  runApp(const WealthLensApp());
}
