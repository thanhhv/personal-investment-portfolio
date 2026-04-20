import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wealth_lens/core/constants/app_constants.dart';
import 'package:wealth_lens/core/errors/failures.dart';
import 'package:wealth_lens/data/models/asset_model.dart';
import 'package:wealth_lens/domain/repositories/asset_repository.dart';

@injectable
class ExportPortfolioUseCase {
  ExportPortfolioUseCase(this._repo);

  final AssetRepository _repo;

  Future<Either<Failure, Unit>> call() async {
    try {
      final result = await _repo.getAllAssetsRaw();
      return await result.fold(
        (f) async => Left<Failure, Unit>(f),
        (assets) async {
          final models = assets.map(AssetModel.fromEntity).toList();
          final content = jsonEncode(<String, dynamic>{
            'version': AppConstants.exportVersion,
            'exportedAt': DateTime.now().toIso8601String(),
            'currency': 'USD',
            'assets': models.map((m) => m.toJson()).toList(),
          });
          final dir = await getTemporaryDirectory();
          final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
          final file = File(
            '${dir.path}/portfolio_$dateStr${AppConstants.exportFileExtension}',
          );
          await file.writeAsString(content);
          await Share.shareXFiles([XFile(file.path)]);
          return const Right<Failure, Unit>(unit);
        },
      );
    } on Object catch (e) {
      return Left(ExportFailure(e.toString()));
    }
  }
}
