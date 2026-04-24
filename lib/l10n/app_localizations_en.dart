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

  @override
  String get myAssets => 'My Assets';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get assetNotFound => 'Asset not found';

  @override
  String get fieldRequired => 'Required';

  @override
  String get dateLabel => 'Date';

  @override
  String get investedVsCurrentValue => 'Invested vs. Current Value';

  @override
  String get invested => 'Invested';

  @override
  String get value => 'Value';

  @override
  String get gain => 'Gain';

  @override
  String get loss => 'Loss';

  @override
  String get pAndL => 'P&L';

  @override
  String get allocation => 'Alloc.';

  @override
  String get portfolioPerformance => 'Portfolio Performance';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get addAssetsToSeeAnalytics =>
      'Add assets and transactions to see analytics';

  @override
  String get breakdown => 'Breakdown';

  @override
  String get priceHistory => 'Price History';

  @override
  String get viewAll => 'View All';

  @override
  String get data => 'Data';

  @override
  String get appearance => 'Appearance';

  @override
  String get exportSubtitle => 'Share as .wealthlens.json';

  @override
  String get importSubtitle => 'Load from .wealthlens.json';

  @override
  String get exportInfoTitle => 'Export Portfolio';

  @override
  String get exportInfoBody =>
      'Your portfolio will be saved as a .wealthlens.json file. You can share it, save it to your files, or send it to another device to restore your data.';

  @override
  String get importInfoTitle => 'Import Portfolio';

  @override
  String get importInfoBody =>
      'Select a .wealthlens.json file to import your portfolio.\n\nWarning: importing will delete all your current data and replace it with the data from the file. Make sure you have a backup before continuing.';

  @override
  String get proceedButton => 'Continue';

  @override
  String importFoundAssets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Found $count assets',
      one: 'Found 1 asset',
    );
    return '$_temp0';
  }

  @override
  String importNewCount(int count) {
    return '$count new';
  }

  @override
  String importUpdateCount(int count) {
    return '$count will be updated';
  }

  @override
  String get importHowToImport => 'How would you like to import?';

  @override
  String get merge => 'Merge';

  @override
  String get replaceAll => 'Replace All';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get initialInvestment => 'Initial Investment';

  @override
  String get additional => 'Additional';

  @override
  String get quantityOptional => 'Quantity (optional)';

  @override
  String get quantityRequired => 'Quantity *';

  @override
  String get pricePerUnitOptional => 'Price per Unit (optional)';

  @override
  String get pricePerUnit => 'Price per Unit *';

  @override
  String get currentValueOptional => 'Current Value (optional)';

  @override
  String get currentPricePerUnit => 'Current Price per Unit (optional)';

  @override
  String get totalInvestedCalculated => 'Total Invested (auto)';

  @override
  String get leaveBlankHint => 'Leave blank if unknown';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get tagsOptional => 'Tags (optional)';

  @override
  String get addTagHint => 'Add tag...';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get amountRequired => 'Amount *';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get sellExceedsValue => 'Sell amount exceeds current asset value';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get cannotBeUndone => 'This cannot be undone.';

  @override
  String get updatePrice => 'Update Price';

  @override
  String get newCurrentValue => 'New Current Value';

  @override
  String get currentPricePerUnitRequired => 'Current Price per Unit *';

  @override
  String get totalQuantityLabel => 'Total Quantity (tracked)';

  @override
  String get exchangeRate => 'Exchange Rate';

  @override
  String get exchangeRateHint => 'e.g. 25000';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get yourInvestmentsAtAGlance => 'Your investments, at a glance';

  @override
  String get onboarding1Title => 'Track Everything';

  @override
  String get onboarding1Subtitle =>
      'Monitor all your investments in one place — crypto, stocks, gold, real estate, and more.';

  @override
  String get onboarding2Title => 'Visualize Growth';

  @override
  String get onboarding2Subtitle =>
      'Beautiful charts show your portfolio performance and asset allocation at a glance.';

  @override
  String get onboarding3Title => 'Stay in Control';

  @override
  String get onboarding3Subtitle =>
      'Your data stays on your device. Export, import, and manage your wealth with full privacy.';
}
