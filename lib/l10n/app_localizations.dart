import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'WealthLens'**
  String get appName;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @totalPortfolioValue.
  ///
  /// In en, this message translates to:
  /// **'Total Portfolio Value'**
  String get totalPortfolioValue;

  /// No description provided for @totalProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Total Profit / Loss'**
  String get totalProfitLoss;

  /// No description provided for @totalInvested.
  ///
  /// In en, this message translates to:
  /// **'Total Invested'**
  String get totalInvested;

  /// No description provided for @currentValue.
  ///
  /// In en, this message translates to:
  /// **'Current Value'**
  String get currentValue;

  /// No description provided for @profitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit / Loss'**
  String get profitLoss;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @addAsset.
  ///
  /// In en, this message translates to:
  /// **'Add Asset'**
  String get addAsset;

  /// No description provided for @editAsset.
  ///
  /// In en, this message translates to:
  /// **'Edit Asset'**
  String get editAsset;

  /// No description provided for @deleteAsset.
  ///
  /// In en, this message translates to:
  /// **'Delete Asset'**
  String get deleteAsset;

  /// No description provided for @assetName.
  ///
  /// In en, this message translates to:
  /// **'Asset Name'**
  String get assetName;

  /// No description provided for @assetCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get assetCategory;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDate;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @purchasePricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price per Unit'**
  String get purchasePricePerUnit;

  /// No description provided for @totalInvestedAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Invested Amount'**
  String get totalInvestedAmount;

  /// No description provided for @currentValueAmount.
  ///
  /// In en, this message translates to:
  /// **'Current Value'**
  String get currentValueAmount;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @categoryCrypto.
  ///
  /// In en, this message translates to:
  /// **'Cryptocurrency'**
  String get categoryCrypto;

  /// No description provided for @categoryStock.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get categoryStock;

  /// No description provided for @categoryFund.
  ///
  /// In en, this message translates to:
  /// **'Mutual Fund / ETF'**
  String get categoryFund;

  /// No description provided for @categoryGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get categoryGold;

  /// No description provided for @categoryRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get categoryRealEstate;

  /// No description provided for @categorySavings.
  ///
  /// In en, this message translates to:
  /// **'Savings / Deposit'**
  String get categorySavings;

  /// No description provided for @categoryLending.
  ///
  /// In en, this message translates to:
  /// **'Peer Lending'**
  String get categoryLending;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @transactionType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get transactionType;

  /// No description provided for @transactionBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get transactionBuy;

  /// No description provided for @transactionSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get transactionSell;

  /// No description provided for @transactionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get transactionUpdate;

  /// No description provided for @transactionAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transactionAmount;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transactionDate;

  /// No description provided for @transactionNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get transactionNote;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @exportPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Export Portfolio'**
  String get exportPortfolio;

  /// No description provided for @importPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Import Portfolio'**
  String get importPortfolio;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Portfolio exported successfully'**
  String get exportSuccess;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Portfolio imported successfully'**
  String get importSuccess;

  /// No description provided for @importMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge with existing'**
  String get importMerge;

  /// No description provided for @importReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace all'**
  String get importReplace;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Portfolio'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {1 asset} other {{count} assets}} will be {action}.'**
  String importConfirmMessage(int count, String action);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String confirmDelete(String name);

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get confirmDeleteMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be a positive number'**
  String get validationPositiveNumber;

  /// No description provided for @noAssetsYet.
  ///
  /// In en, this message translates to:
  /// **'No assets yet'**
  String get noAssetsYet;

  /// No description provided for @noAssetsMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first investment'**
  String get noAssetsMessage;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @bestPerforming.
  ///
  /// In en, this message translates to:
  /// **'Best Performing'**
  String get bestPerforming;

  /// No description provided for @worstPerforming.
  ///
  /// In en, this message translates to:
  /// **'Worst Performing'**
  String get worstPerforming;

  /// No description provided for @categoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get categoryBreakdown;

  /// No description provided for @monthlySnapshot.
  ///
  /// In en, this message translates to:
  /// **'Monthly Snapshot'**
  String get monthlySnapshot;

  /// No description provided for @allocationByCategory.
  ///
  /// In en, this message translates to:
  /// **'Allocation by Category'**
  String get allocationByCategory;

  /// No description provided for @profitLossByCategory.
  ///
  /// In en, this message translates to:
  /// **'Profit / Loss by Category'**
  String get profitLossByCategory;

  /// No description provided for @myAssets.
  ///
  /// In en, this message translates to:
  /// **'My Assets'**
  String get myAssets;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @assetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Asset not found'**
  String get assetNotFound;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @investedVsCurrentValue.
  ///
  /// In en, this message translates to:
  /// **'Invested vs. Current Value'**
  String get investedVsCurrentValue;

  /// No description provided for @invested.
  ///
  /// In en, this message translates to:
  /// **'Invested'**
  String get invested;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @gain.
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get gain;

  /// No description provided for @loss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get loss;

  /// No description provided for @pAndL.
  ///
  /// In en, this message translates to:
  /// **'P&L'**
  String get pAndL;

  /// No description provided for @allocation.
  ///
  /// In en, this message translates to:
  /// **'Alloc.'**
  String get allocation;

  /// No description provided for @portfolioPerformance.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Performance'**
  String get portfolioPerformance;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @addAssetsToSeeAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Add assets and transactions to see analytics'**
  String get addAssetsToSeeAnalytics;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdown;

  /// No description provided for @priceHistory.
  ///
  /// In en, this message translates to:
  /// **'Price History'**
  String get priceHistory;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @exportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share as .wealthlens.json'**
  String get exportSubtitle;

  /// No description provided for @importSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load from .wealthlens.json'**
  String get importSubtitle;

  /// No description provided for @importFoundAssets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {Found 1 asset} other {Found {count} assets}}'**
  String importFoundAssets(int count);

  /// No description provided for @importNewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String importNewCount(int count);

  /// No description provided for @importUpdateCount.
  ///
  /// In en, this message translates to:
  /// **'{count} will be updated'**
  String importUpdateCount(int count);

  /// No description provided for @importHowToImport.
  ///
  /// In en, this message translates to:
  /// **'How would you like to import?'**
  String get importHowToImport;

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace All'**
  String get replaceAll;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @initialInvestment.
  ///
  /// In en, this message translates to:
  /// **'Initial Investment'**
  String get initialInvestment;

  /// No description provided for @additional.
  ///
  /// In en, this message translates to:
  /// **'Additional'**
  String get additional;

  /// No description provided for @quantityOptional.
  ///
  /// In en, this message translates to:
  /// **'Quantity (optional)'**
  String get quantityOptional;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity *'**
  String get quantityRequired;

  /// No description provided for @pricePerUnitOptional.
  ///
  /// In en, this message translates to:
  /// **'Price per Unit (optional)'**
  String get pricePerUnitOptional;

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per Unit *'**
  String get pricePerUnit;

  /// No description provided for @currentValueOptional.
  ///
  /// In en, this message translates to:
  /// **'Current Value (optional)'**
  String get currentValueOptional;

  /// No description provided for @currentPricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Current Price per Unit (optional)'**
  String get currentPricePerUnit;

  /// No description provided for @totalInvestedCalculated.
  ///
  /// In en, this message translates to:
  /// **'Total Invested (auto)'**
  String get totalInvestedCalculated;

  /// No description provided for @leaveBlankHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank if unknown'**
  String get leaveBlankHint;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @tagsOptional.
  ///
  /// In en, this message translates to:
  /// **'Tags (optional)'**
  String get tagsOptional;

  /// No description provided for @addTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add tag...'**
  String get addTagHint;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount *'**
  String get amountRequired;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @sellExceedsValue.
  ///
  /// In en, this message translates to:
  /// **'Sell amount exceeds current asset value'**
  String get sellExceedsValue;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange Rate'**
  String get exchangeRate;

  /// No description provided for @exchangeRateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 25000'**
  String get exchangeRateHint;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @yourInvestmentsAtAGlance.
  ///
  /// In en, this message translates to:
  /// **'Your investments, at a glance'**
  String get yourInvestmentsAtAGlance;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Track Everything'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor all your investments in one place — crypto, stocks, gold, real estate, and more.'**
  String get onboarding1Subtitle;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Visualize Growth'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Beautiful charts show your portfolio performance and asset allocation at a glance.'**
  String get onboarding2Subtitle;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Stay in Control'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device. Export, import, and manage your wealth with full privacy.'**
  String get onboarding3Subtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
