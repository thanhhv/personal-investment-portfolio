import 'package:flutter/material.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';

enum AssetCategory {
  crypto,
  stock,
  fund,
  gold,
  realEstate,
  savings,
  lending,
  other;

  String get key => switch (this) {
        AssetCategory.crypto => 'crypto',
        AssetCategory.stock => 'stock',
        AssetCategory.fund => 'fund',
        AssetCategory.gold => 'gold',
        AssetCategory.realEstate => 'real_estate',
        AssetCategory.savings => 'savings',
        AssetCategory.lending => 'lending',
        AssetCategory.other => 'other',
      };

  static AssetCategory fromKey(String key) => switch (key) {
        'crypto' => AssetCategory.crypto,
        'stock' => AssetCategory.stock,
        'fund' => AssetCategory.fund,
        'gold' => AssetCategory.gold,
        'real_estate' => AssetCategory.realEstate,
        'savings' => AssetCategory.savings,
        'lending' => AssetCategory.lending,
        _ => AssetCategory.other,
      };

  IconData get icon => switch (this) {
        AssetCategory.crypto => Icons.currency_bitcoin,
        AssetCategory.stock => Icons.show_chart,
        AssetCategory.fund => Icons.account_balance,
        AssetCategory.gold => Icons.workspace_premium,
        AssetCategory.realEstate => Icons.home_work,
        AssetCategory.savings => Icons.savings,
        AssetCategory.lending => Icons.handshake,
        AssetCategory.other => Icons.category,
      };

  Color get accentColor => switch (this) {
        AssetCategory.crypto => AppColors.cryptoAccent,
        AssetCategory.stock => AppColors.stockAccent,
        AssetCategory.fund => AppColors.fundAccent,
        AssetCategory.gold => AppColors.goldAccent,
        AssetCategory.realEstate => AppColors.realEstateAccent,
        AssetCategory.savings => AppColors.savingsAccent,
        AssetCategory.lending => AppColors.lendingAccent,
        AssetCategory.other => AppColors.otherAccent,
      };

  String get label => switch (this) {
        AssetCategory.crypto => 'Crypto',
        AssetCategory.stock => 'Stocks',
        AssetCategory.fund => 'Fund / ETF',
        AssetCategory.gold => 'Gold',
        AssetCategory.realEstate => 'Real Estate',
        AssetCategory.savings => 'Savings',
        AssetCategory.lending => 'Lending',
        AssetCategory.other => 'Other',
      };

  String get l10nKey => switch (this) {
        AssetCategory.crypto => 'categoryCrypto',
        AssetCategory.stock => 'categoryStock',
        AssetCategory.fund => 'categoryFund',
        AssetCategory.gold => 'categoryGold',
        AssetCategory.realEstate => 'categoryRealEstate',
        AssetCategory.savings => 'categorySavings',
        AssetCategory.lending => 'categoryLending',
        AssetCategory.other => 'categoryOther',
      };
}
