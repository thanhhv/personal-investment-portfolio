import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:wealth_lens/core/constants/app_constants.dart';
import 'package:wealth_lens/core/errors/failures.dart';
import 'package:wealth_lens/data/models/asset_model.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/repositories/asset_repository.dart';

class ImportPreview extends Equatable {
  const ImportPreview({
    required this.assets,
    required this.newCount,
    required this.updateCount,
  });

  final List<Asset> assets;
  final int newCount;
  final int updateCount;

  @override
  List<Object?> get props => [assets, newCount, updateCount];
}

List<Asset> _parseAssets(String content) {
  final decoded = jsonDecode(content);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Invalid file format');
  }
  final version = decoded['version'];
  if (version != AppConstants.exportVersion) {
    throw FormatException('Unsupported version: $version');
  }
  final list = decoded['assets'];
  if (list is! List<dynamic>) {
    throw const FormatException('Missing assets list');
  }
  return list
      .map(
        (e) => AssetModel.fromJson(e as Map<String, dynamic>).toEntity(),
      )
      .toList();
}

@injectable
class ImportPortfolioUseCase {
  ImportPortfolioUseCase(this._repo);

  final AssetRepository _repo;

  Future<Either<Failure, ImportPreview>> pickAndPreview() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return const Left(ImportFailure('No file selected'));
      }

      final picked = result.files.first;
      final String content;
      final bytes = picked.bytes;
      final path = picked.path;
      if (bytes != null) {
        content = utf8.decode(bytes);
      } else if (path != null) {
        content = await File(path).readAsString();
      } else {
        return const Left(ImportFailure('Cannot read selected file'));
      }

      final imported = await compute(_parseAssets, content);

      final existingResult = await _repo.getAllAssetsRaw();
      final existingIds = existingResult.fold(
        (_) => <String>{},
        (assets) => {for (final a in assets) a.id},
      );

      final newCount =
          imported.where((a) => !existingIds.contains(a.id)).length;
      final updateCount = imported.length - newCount;

      return Right(
        ImportPreview(
          assets: imported,
          newCount: newCount,
          updateCount: updateCount,
        ),
      );
    } on FormatException catch (e) {
      return Left(ImportFailure(e.message));
    } on Object catch (e) {
      return Left(ImportFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> confirm(
    ImportPreview preview, {
    required bool merge,
  }) =>
      _repo.importAssets(preview.assets, merge: merge);
}
