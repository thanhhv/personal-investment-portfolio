# WealthLens — Project Context for Claude

Personal investment portfolio tracker Flutter app. Local-only storage, iOS + Android, English + Vietnamese. **Always read this file before starting any work on this project.**

---

## Key Decisions (non-obvious, don't revisit without reason)

| Decision | Choice | Why |
|---|---|---|
| DB | **Hive v2** (not Isar) | `isar_generator` 3.x has an `analyzer` version conflict with `freezed >=2.5.3`. Hive resolves cleanly. Do not switch back to Isar. |
| freezed | Pinned to `^2.5.2` | Newer versions (2.5.3+) require `analyzer ^6.5.0+` which conflicts with `hive_generator`. |
| Error handling | `fpdart` `Either<Failure, R>` | Used in all repository/use case return types. Never throw in domain/data layers — return `Left(Failure)`. |
| Imports | All `package:wealth_lens/...` | `very_good_analysis` enforces `always_use_package_imports`. Never use relative imports inside `lib/`. |
| Fonts | Plus Jakarta Sans (headings/numbers) + DM Sans (body) | Via `google_fonts`. Loaded in `AppTextStyles`. |
| State | `flutter_bloc` Cubit for simple, Bloc for complex async | `ThemeCubit` is the first example. |
| DI | `get_it` + `injectable` | `@injectable` / `@singleton` / `@lazySingleton` annotations. Run `dart run build_runner build` after adding any new `@injectable` class. |
| Flutter SDK | 3.41.7 stable | Path: `~/development/flutter/bin/flutter` — not on system PATH by default, prefix commands with `export PATH="$HOME/development/flutter/bin:$PATH"`. |

---

## Architecture

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart       # SharedPreferences keys, export version
│   │   └── asset_categories.dart    # AssetCategory enum + icon/color/l10n extensions
│   ├── di/
│   │   ├── injection.dart           # GetIt setup + @InjectableInit
│   │   └── injection.config.dart    # GENERATED — do not edit manually
│   ├── errors/
│   │   └── failures.dart            # Failure base class + subtypes (Database, Validation, Import, Export, NotFound)
│   ├── extensions/
│   │   ├── context_extensions.dart  # BuildContext shortcuts: l10n, colorScheme, isDark, screenSize
│   │   └── string_extensions.dart   # capitalize, titleCase, isValidPositiveNumber
│   ├── theme/
│   │   ├── app_colors.dart          # All color constants (primary #00C896, secondary #2E6FF3, category accents)
│   │   ├── app_text_styles.dart     # TextTheme + portfolioTotal/priceLabel/percentageBadge convenience styles
│   │   └── app_theme.dart           # AppTheme.light / AppTheme.dark (Material 3)
│   └── utils/
│       ├── currency_formatter.dart  # CurrencyFormatter.format/formatCompact/formatPercent + AppCurrency enum
│       └── date_formatter.dart      # DateFormatter.format/formatShort/formatRelative/monthYear
├── data/
│   ├── datasources/
│   │   └── hive_datasource.dart     # Plain class (NOT @injectable). Registered manually in main().
│   ├── models/
│   │   ├── asset_model.dart         # @HiveType(typeId:0) + @JsonSerializable. fromEntity/toEntity.
│   │   ├── transaction_model.dart   # @HiveType(typeId:1) + @JsonSerializable.
│   │   └── price_point_model.dart   # @HiveType(typeId:2) + @JsonSerializable.
│   └── repositories/
│       └── asset_repository_impl.dart  # @LazySingleton(as: AssetRepository)
├── domain/
│   ├── entities/
│   │   ├── asset.dart               # @freezed — computed: totalInvested, currentValue, profitLoss, profitLossPercent
│   │   ├── transaction.dart         # @freezed — TransactionType enum (buy/sell/update)
│   │   └── price_point.dart         # @freezed
│   ├── repositories/
│   │   └── asset_repository.dart    # abstract interface (8 methods)
│   └── usecases/
│       ├── get_all_assets_usecase.dart
│       ├── get_asset_by_id_usecase.dart
│       ├── save_asset_usecase.dart      # auto-generates UUID if asset.id is empty
│       ├── delete_asset_usecase.dart
│       ├── add_transaction_usecase.dart # auto-generates UUID if tx.id is empty
│       └── delete_transaction_usecase.dart
├── presentation/
│   ├── blocs/
│   │   ├── theme/
│   │   │   └── theme_cubit.dart     # ThemeCubit — emits ThemeMode, persists to SharedPreferences
│   │   └── dashboard/
│   │       ├── dashboard_cubit.dart # @injectable — calls GetAllAssetsUseCase, emits DashboardState
│   │       └── dashboard_state.dart # DashboardStatus enum + computed totalValue/profitLoss getters
│   ├── routes/
│   │   └── app_router.dart          # GoRouter — all named routes listed below
│   ├── widgets/
│   │   ├── asset_card.dart          # Hero-wrapped card: category icon, name, value, P&L badge
│   │   ├── shimmer_asset_card.dart  # Shimmer placeholder for loading state
│   │   ├── portfolio_header.dart    # Gradient header: total value, invested, P&L chips
│   │   └── category_donut_chart.dart # PieChart (fl_chart) with legend rows
│   └── screens/
│       ├── splash/splash_screen.dart        # Scale+fade animation, auto-navigates after 2.5s
│       ├── onboarding/onboarding_screen.dart # 3-slide PageView, sets hasSeenOnboarding flag
│       ├── dashboard/dashboard_screen.dart  # Full dashboard — header, donut chart, asset list
│       └── settings/settings_screen.dart   # Theme/language/currency toggles, export/import, version
├── l10n/
│   ├── app_en.arb                   # English strings (40+ keys)
│   ├── app_vi.arb                   # Vietnamese strings
│   ├── app_localizations.dart       # GENERATED — import this for l10n
│   ├── app_localizations_en.dart    # GENERATED
│   └── app_localizations_vi.dart    # GENERATED
├── app.dart                         # WealthLensApp — MaterialApp.router, BlocProvider<ThemeCubit>
└── main.dart                        # main() — ensureInitialized → configureDependencies → runApp
```

---

## Named Routes (app_router.dart)

| Name | Path | Screen |
|---|---|---|
| splash | `/` | SplashScreen |
| onboarding | `/onboarding` | OnboardingScreen |
| dashboard | `/dashboard` | DashboardScreen |
| assetDetail | `/asset/:id` | AssetDetailScreen (Phase 3) |
| addAsset | `/asset/add` | AddEditAssetScreen (Phase 3) |
| editAsset | `/asset/:id/edit` | AddEditAssetScreen (Phase 3) |
| transactions | `/asset/:id/transactions` | TransactionLogScreen (Phase 3) |
| analytics | `/analytics` | AnalyticsScreen (Phase 4) |
| settings | `/settings` | SettingsScreen (Phase 6) |

Helper methods: `AppRoutes.assetDetailPath(id)`, `AppRoutes.editAssetPath(id)`, `AppRoutes.transactionsPath(id)`.

---

## Data Models (to be built in Phase 1)

```dart
// Domain entities — pure Dart
Asset {
  id: String (UUID v4)
  name: String
  category: AssetCategory
  notes: String?
  tags: List<String>
  transactions: List<Transaction>
  priceHistory: List<PricePoint>
  createdAt: DateTime
  updatedAt: DateTime
}

Transaction {
  id: String
  type: TransactionType (buy | sell | update)
  amount: double          // total value in base currency
  quantity: double?
  pricePerUnit: double?
  date: DateTime
  note: String?
}

PricePoint {
  date: DateTime
  value: double
}
```

Hive stores `AssetModel` (maps to `Asset` entity). Use `@HiveType(typeId: N)` and `@HiveField(N)` for all fields.

---

## Export / Import Format

```json
{
  "version": "1.0",
  "exportedAt": "ISO8601",
  "currency": "VND",
  "assets": [ ...full AssetModel JSON... ]
}
```

File extension: `.wealthlens.json`. Validate `version` on import. Offer "Merge" or "Replace all" options.

---

## Useful Commands

```bash
# Always prefix flutter commands with:
export PATH="$HOME/development/flutter/bin:$PATH"

# Resolve deps
flutter pub get

# Regenerate injectable + freezed + hive code after model changes
dart run build_runner build --delete-conflicting-outputs

# Regenerate l10n only (after editing ARB files)
flutter gen-l10n

# Lint check
flutter analyze

# Run on connected device
flutter run

# Run tests
flutter test
```

---

## Phase Status

### ✅ Phase 0 — Project Setup (DONE)
All infrastructure in place. `flutter analyze` passes with 0 issues.

What was built:
- Flutter project scaffolded (`com.wealthlens.wealth_lens`)
- `pubspec.yaml` with all 21 runtime deps + 7 dev deps
- Full folder structure under `lib/`
- Material 3 theme (light + dark) with brand colors
- `AssetCategory` enum (8 types) with icons + accent colors
- `Failure` hierarchy for fpdart `Either`
- `CurrencyFormatter` (VND/USD) and `DateFormatter`
- `BuildContext` + `String` extensions
- `ThemeCubit` — persists theme mode to SharedPreferences
- GoRouter with all 9 named routes
- Splash screen (scale+fade animation, checks onboarding flag)
- Onboarding screen (3-slide PageView, persists `hasSeenOnboarding`)
- Dashboard + Settings stubs
- `app_en.arb` + `app_vi.arb` with 40+ keys each
- `analysis_options.yaml` using `very_good_analysis`
- Android permissions (READ/WRITE_EXTERNAL_STORAGE), iOS plist (file sharing)
- `injection.config.dart` generated by `build_runner`

---

### ✅ Phase 1 — Data Layer (DONE)

`flutter analyze` passes with 0 issues. All data layer wired end-to-end.

**What was built:**

Domain entities (freezed, pure Dart, no Hive):
- `lib/domain/entities/transaction.dart` — `TransactionType` enum (buy/sell/update) + `Transaction` freezed entity
- `lib/domain/entities/price_point.dart` — `PricePoint` freezed entity
- `lib/domain/entities/asset.dart` — `Asset` freezed entity with computed getters: `totalInvested`, `currentValue`, `profitLoss`, `profitLossPercent`

Domain interface:
- `lib/domain/repositories/asset_repository.dart` — abstract `AssetRepository` with 8 methods

Hive data models (`@HiveType` + `@JsonSerializable`, NOT freezed — they conflict):
- `lib/data/models/transaction_model.dart` — `typeId: 1`, stores `TransactionType` as String
- `lib/data/models/price_point_model.dart` — `typeId: 2`
- `lib/data/models/asset_model.dart` — `typeId: 0`, stores `AssetCategory` as String via `.key`

Data layer:
- `lib/data/datasources/hive_datasource.dart` — plain class, NOT `@injectable` (see below)
- `lib/data/repositories/asset_repository_impl.dart` — `@LazySingleton(as: AssetRepository)`, catches with `on Object`

Use cases (each `@injectable`, single `call()` method):
- `lib/domain/usecases/get_all_assets_usecase.dart`
- `lib/domain/usecases/get_asset_by_id_usecase.dart`
- `lib/domain/usecases/save_asset_usecase.dart` — generates UUID if `asset.id.isEmpty`
- `lib/domain/usecases/delete_asset_usecase.dart`
- `lib/domain/usecases/add_transaction_usecase.dart` — generates UUID if `tx.id.isEmpty`
- `lib/domain/usecases/delete_transaction_usecase.dart`

(Export/Import use cases deferred to Phase 5)

**Critical DI note — `HiveDatasource` is NOT `@injectable`:**
Hive box requires async init. `HiveDatasource` is registered manually in `main()` AFTER `Hive.openBox()` and AFTER `configureDependencies()`. The generated `injection.config.dart` calls `gh<HiveDatasource>()` lazily, so it resolves correctly at runtime.

`main.dart` init order:
1. `Hive.initFlutter()` → register adapters → `openBox<AssetModel>('assets')`
2. `configureDependencies()` — registers lazy DI graph
3. `getIt.registerSingleton<HiveDatasource>(HiveDatasource(assetBox))` — manual registration

**Generated files** (do not edit, regenerate with `dart run build_runner build`):
- `lib/domain/entities/transaction.freezed.dart`
- `lib/domain/entities/price_point.freezed.dart`
- `lib/domain/entities/asset.freezed.dart`
- `lib/data/models/transaction_model.g.dart`
- `lib/data/models/price_point_model.g.dart`
- `lib/data/models/asset_model.g.dart`
- `lib/core/di/injection.config.dart`

---

### ✅ Phase 2 — Core Screens

**Completed files:**
- `lib/presentation/blocs/dashboard/dashboard_state.dart` — `DashboardStatus` enum + state with computed `totalValue`, `totalInvested`, `totalProfitLoss`, `totalProfitLossPercent`
- `lib/presentation/blocs/dashboard/dashboard_cubit.dart` — `@injectable`, calls `GetAllAssetsUseCase`, emits loading/success/failure
- `lib/presentation/widgets/asset_card.dart` — Hero tag `asset_${id}`, category icon badge, P&L badge, `onTap` callback
- `lib/presentation/widgets/shimmer_asset_card.dart` — Shimmer placeholder (dark/light adaptive)
- `lib/presentation/widgets/portfolio_header.dart` — Gradient card: total value, invested chip, P&L chip
- `lib/presentation/widgets/category_donut_chart.dart` — `fl_chart` PieChart donut with legend, only shown when `assets.length > 1`
- `lib/presentation/screens/dashboard/dashboard_screen.dart` — Full `CustomScrollView` with sliver header, donut, asset list; loading/empty/error states

**Key decisions:**
- Currency from `CurrencyCubit` in all screens — `context.read<CurrencyCubit>().state`
- Donut chart hidden when 0 or 1 asset (not meaningful with single slice)
- `DashboardCubit` is `@injectable` (factory) — provided via `BlocProvider(create: (_) => getIt<DashboardCubit>()..load())`
- `AssetCategory.label` getter added to `asset_categories.dart` for display names (e.g. `realEstate` → `'Real Estate'`)

---

### ✅ Phase 3 — Asset CRUD

**Completed files:**
- `lib/presentation/blocs/asset_form/asset_form_state.dart` + `asset_form_cubit.dart` — `@injectable`, wraps `SaveAssetUseCase`, emits saving/saved/failure
- `lib/presentation/blocs/asset_detail/asset_detail_state.dart` + `asset_detail_cubit.dart` — `@injectable`, loads by ID, handles delete asset + delete transaction, emits loading/success/failure/deleted
- `lib/presentation/screens/add_edit_asset/add_edit_asset_screen.dart` — StatefulWidget form: name, category, purchase date, invested amount, qty, price/unit, current value, notes, tags chips. Add mode creates initial buy Transaction. Edit mode preserves transactions, only updates metadata. Navigates back on save via `BlocListener`.
- `lib/presentation/screens/asset_detail/asset_detail_screen.dart` — Hero header card, `fl_chart` `LineChart` (shown when ≥2 price history points), last 5 transactions with delete, FAB → `AddTransactionBottomSheet`, edit/delete in AppBar
- `lib/presentation/screens/transaction_log/transaction_log_screen.dart` — Full chronological transaction list with delete, FAB → `AddTransactionBottomSheet`
- `lib/presentation/widgets/add_transaction_bottom_sheet.dart` — `SegmentedButton` for type, date picker, amount, qty (optional), note. Calls `AddTransactionUseCase` directly via `getIt`, fires `onAdded` callback on success.
- `lib/presentation/routes/app_router.dart` — Added `addAsset`, `assetDetail`, `editAsset`, `transactions` routes. `addAsset` listed BEFORE `assetDetail` to avoid path conflict. Edit route passes `Asset` via `state.extra`.

**Key decisions:**
- `AssetFormCubit` uses `BlocListener` for navigation-on-save (safer than `context` after `await`)
- `DropdownButtonFormField` uses `initialValue:` + `ValueKey(_category)` to force rebuild on selection change (avoids deprecated `value:` parameter)
- `unawaited()` from `dart:async` used for fire-and-forget refresh calls after dialog pops
- Dashboard FAB and asset card taps `await context.push(...)` then reload cubit on return
- Add mode: creates `Asset(id: '', ...)` with one initial buy `Transaction`; `SaveAssetUseCase` assigns UUID
- Edit mode: passes existing `Asset` via `GoRouter.extra`, `copyWith` preserves transactions + priceHistory

---

### ✅ Phase 4 — Charts & Analytics (DONE)

**Completed files:**
- `lib/presentation/blocs/analytics/analytics_state.dart` — `TimelinePoint`, `CategoryBreakdown`, `AnalyticsData` (with `totalProfitLoss`, `totalProfitLossPercent`), `AnalyticsStatus`, `AnalyticsState`
- `lib/presentation/blocs/analytics/analytics_cubit.dart` — `@injectable`, top-level `_computeAnalytics()`, timeline built from date-normalized tx + price-history dates, category breakdown maps
- `lib/presentation/screens/analytics/analytics_screen.dart` — `_SummaryCard` (gradient header), `_PerformanceChart` (LineChart: solid primary fill + dashed neutral invested), `_RankingSection` (top/bottom 3), `_CategoryBreakdownCard` (table with icon/value/allocation/P&L%)

**Key decisions:**
- `_computeAnalytics` is a top-level function (isolate-ready via `compute()` in future)
- Dates normalized to midnight (year/month/day only) for accurate timeline comparison
- Chart falls back to `assetInvested` when no price history exists at a given date
- `_LegendDot` is a `const`-constructible private widget
- Analytics icon button added to DashboardScreen AppBar

---

### ✅ Phase 5 — Export / Import (DONE)

**Completed files:**
- `lib/domain/usecases/export_portfolio_usecase.dart` — `@injectable`, fetches all assets, serializes to JSON (`version`, `exportedAt`, `currency`, `assets`), writes to `path_provider` temp dir, shares via `Share.shareXFiles`
- `lib/domain/usecases/import_portfolio_usecase.dart` — `@injectable`, `ImportPreview` class (assets, newCount, updateCount); `pickAndPreview()` uses `file_picker` + `compute(_parseAssets)` for JSON parsing with version validation; `confirm(preview, merge:)` calls repository
- `lib/presentation/blocs/settings/settings_state.dart` — `SettingsStatus` enum + state with `importPreview`, `successMessage`, `errorMessage`
- `lib/presentation/blocs/settings/settings_cubit.dart` — `@injectable`, `exportPortfolio()`, `pickImportFile()`, `confirmImport(merge:)`, `dismissPreview()`, `resetStatus()`
- `lib/presentation/widgets/import_confirm_dialog.dart` — `ImportAction` enum (merge/replaceAll), static `show()`, counts new vs updated assets
- `lib/presentation/screens/settings/settings_screen.dart` — Export/Import tiles, Theme `SegmentedButton` (Light/System/Dark), About section; `BlocConsumer` shows confirm dialog on `previewReady`, snackbars on success/failure

**Key decisions:**
- `_parseAssets` is a top-level function for `compute()` isolate compatibility
- `importAssets(merge: true)` adds/updates without deleting; `merge: false` replaces all
- `SettingsCubit` resets to idle after each snackbar so the listener doesn't re-fire
- share_plus v10 API: `Share.shareXFiles([XFile(path)])` (not `SharePlus.instance`)

---

### ✅ Phase 6 — i18n & Polish (DONE)

**What was built:**

- `lib/presentation/blocs/locale/locale_cubit.dart` — `LocaleCubit` emits `Locale`, persists to `AppConstants.localeKey`
- `lib/presentation/blocs/currency/currency_cubit.dart` — `CurrencyCubit` emits `AppCurrency`, persists to `AppConstants.currencyKey`
- `lib/presentation/blocs/settings/settings_state.dart` + `settings_cubit.dart` — `@injectable`, wraps export/import use cases + `PackageInfo.fromPlatform()`; statuses: idle/busy/previewReady/exportSuccess/importSuccess/failure
- `lib/presentation/screens/settings/settings_screen.dart` — Full settings: theme/language/currency toggles via `SegmentedButton`, export/import, version display
- `lib/presentation/widgets/import_confirm_dialog.dart` — Shows import preview (new/update counts), returns `ImportAction.merge` or `ImportAction.replaceAll`
- `lib/app.dart` — `MultiBlocProvider` providing ThemeCubit + LocaleCubit + CurrencyCubit; `MaterialApp.router` uses `locale` from `LocaleCubit`
- `lib/presentation/widgets/portfolio_header.dart` — `TweenAnimationBuilder<double>` counter animation (0→totalValue, 800ms)
- `lib/presentation/screens/dashboard/dashboard_screen.dart` — `AnimationLimiter` + staggered list (`flutter_staggered_animations`), currency from `CurrencyCubit`
- All screens/widgets i18n-swept: `app_en.arb` + `app_vi.arb` with 90+ keys

**Key decisions:**
- `LocaleCubit` and `CurrencyCubit` are NOT `@injectable` (no DI-accessible SharedPreferences at registration time) — provided directly in `app.dart`
- Currency in screens: `context.read<CurrencyCubit>().state` (not watch) — screens rebuild on nav pop
- `SettingsCubit` uses separate `exportSuccess`/`importSuccess` statuses (no `successMessage` in state); UI maps status → l10n string
- `ImportAction` enum is public (not private) to avoid `library_private_types_in_public_api` lint
- `pubspec.yaml` added: `flutter_staggered_animations: ^1.1.1`, `package_info_plus: ^8.0.0`

---

## Asset Category Reference

| Key | EN | VI | Icon | Color |
|---|---|---|---|---|
| crypto | Cryptocurrency | Tiền mã hóa | `currency_bitcoin` | #F7931A |
| stock | Stocks | Cổ phiếu | `show_chart` | #2E6FF3 |
| fund | Mutual Fund / ETF | Chứng chỉ quỹ | `account_balance` | #8B5CF6 |
| gold | Gold | Vàng | `workspace_premium` | #FFD700 |
| real_estate | Real Estate | Bất động sản | `home_work` | #10B981 |
| savings | Savings / Deposit | Tiết kiệm | `savings` | #00C896 |
| lending | Peer Lending | Cho vay | `handshake` | #FF6B6B |
| other | Other | Khác | `category` | #8E9AAE |
