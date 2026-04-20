import 'package:intl/intl.dart';

enum AppCurrency { vnd, usd }

abstract final class CurrencyFormatter {
  static final _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final _usdFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );

  static final _compactVnd = NumberFormat.compactCurrency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 1,
  );

  static final _compactUsd = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );

  static String format(double amount, AppCurrency currency) {
    return switch (currency) {
      AppCurrency.vnd => _vndFormat.format(amount),
      AppCurrency.usd => _usdFormat.format(amount),
    };
  }

  static String formatCompact(double amount, AppCurrency currency) {
    return switch (currency) {
      AppCurrency.vnd => _compactVnd.format(amount),
      AppCurrency.usd => _compactUsd.format(amount),
    };
  }

  static String formatPercent(double percent, {int decimals = 2}) {
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(decimals)}%';
  }

  static String symbol(AppCurrency currency) => switch (currency) {
        AppCurrency.vnd => '₫',
        AppCurrency.usd => r'$',
      };
}
