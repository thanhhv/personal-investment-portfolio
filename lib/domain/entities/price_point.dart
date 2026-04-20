import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_point.freezed.dart';

@freezed
class PricePoint with _$PricePoint {
  const factory PricePoint({
    required DateTime date,
    required double value,
  }) = _PricePoint;
}
