// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'WealthLens';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get analytics => 'Analytics';

  @override
  String get settings => 'Settings';

  @override
  String get transactions => 'Transactions';

  @override
  String get totalPortfolioValue => 'Total Portfolio Value';

  @override
  String get totalProfitLoss => 'Total Profit / Loss';

  @override
  String get totalInvested => 'Total Invested';

  @override
  String get currentValue => 'Current Value';

  @override
  String get profitLoss => 'Profit / Loss';

  @override
  String get allTime => 'All Time';

  @override
  String get assets => 'Assets';

  @override
  String get addAsset => 'Add Asset';

  @override
  String get editAsset => 'Edit Asset';

  @override
  String get deleteAsset => 'Delete Asset';

  @override
  String get assetName => 'Asset Name';

  @override
  String get assetCategory => 'Category';

  @override
  String get purchaseDate => 'Purchase Date';

  @override
  String get quantity => 'Quantity';

  @override
  String get purchasePricePerUnit => 'Purchase Price per Unit';

  @override
  String get totalInvestedAmount => 'Total Invested Amount';

  @override
  String get currentValueAmount => 'Current Value';

  @override
  String get notes => 'Notes';

  @override
  String get tags => 'Tags';

  @override
  String get categoryCrypto => 'Cryptocurrency';

  @override
  String get categoryStock => 'Stocks';

  @override
  String get categoryFund => 'Mutual Fund / ETF';

  @override
  String get categoryGold => 'Gold';

  @override
  String get categoryRealEstate => 'Real Estate';

  @override
  String get categorySavings => 'Savings / Deposit';

  @override
  String get categoryLending => 'Peer Lending';

  @override
  String get categoryOther => 'Other';

  @override
  String get transactionType => 'Type';

  @override
  String get transactionBuy => 'Buy';

  @override
  String get transactionSell => 'Sell';

  @override
  String get transactionUpdate => 'Update';

  @override
  String get transactionAmount => 'Amount';

  @override
  String get transactionDate => 'Date';

  @override
  String get transactionNote => 'Note';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get exportPortfolio => 'Export Portfolio';

  @override
  String get importPortfolio => 'Import Portfolio';

  @override
  String get exportSuccess => 'Portfolio exported successfully';

  @override
  String get importSuccess => 'Portfolio imported successfully';

  @override
  String get importMerge => 'Merge with existing';

  @override
  String get importReplace => 'Replace all';

  @override
  String get importConfirmTitle => 'Import Portfolio';

  @override
  String importConfirmMessage(int count, String action) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assets',
      one: '1 asset',
    );
    return '$_temp0 will be $action.';
  }

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get currency => 'Currency';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String confirmDelete(String name) {
    return 'Delete $name?';
  }

  @override
  String get confirmDeleteMessage => 'This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get done => 'Done';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationPositiveNumber => 'Must be a positive number';

  @override
  String get noAssetsYet => 'No assets yet';

  @override
  String get noAssetsMessage => 'Tap + to add your first investment';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get bestPerforming => 'Best Performing';

  @override
  String get worstPerforming => 'Worst Performing';

  @override
  String get categoryBreakdown => 'Category Breakdown';

  @override
  String get monthlySnapshot => 'Monthly Snapshot';

  @override
  String get allocationByCategory => 'Allocation by Category';

  @override
  String get profitLossByCategory => 'Profit / Loss by Category';
}
