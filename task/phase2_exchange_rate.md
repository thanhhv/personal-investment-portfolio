# Phase 2 — Exchange Rate Feature

**Estimated effort:** ~45 min  
**1 new file. No new dependencies. No build_runner needed.**

The user wants: "1 USD = X VND, default 25000". Assets are stored in USD internally. When display currency is VND, all amounts are multiplied by this rate.

---

## Step 1 — AppConstants key

**File:** `lib/core/constants/app_constants.dart`

Add:
```dart
static const String exchangeRateKey = 'exchange_rate';
```

---

## Step 2 — Create ExchangeRateCubit

**New file:** `lib/presentation/blocs/exchange_rate/exchange_rate_cubit.dart`

NOT `@injectable` — same pattern as `CurrencyCubit` (registered directly in `app.dart`).

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_lens/core/constants/app_constants.dart';

class ExchangeRateCubit extends Cubit<double> {
  ExchangeRateCubit() : super(25000);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(AppConstants.exchangeRateKey);
    emit(stored ?? 25000);
  }

  Future<void> setRate(double rate) async {
    if (rate <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.exchangeRateKey, rate);
    emit(rate);
  }
}
```

---

## Step 3 — Update CurrencyFormatter

**File:** `lib/core/utils/currency_formatter.dart`

Add `{double rate = 25000}` to `format` and `formatCompact`. When VND, multiply amount by rate:

```dart
static String format(double amount, AppCurrency currency, {double rate = 25000}) {
  return switch (currency) {
    AppCurrency.vnd => _vndFormat.format(amount * rate),
    AppCurrency.usd => _usdFormat.format(amount),
  };
}

static String formatCompact(double amount, AppCurrency currency, {double rate = 25000}) {
  return switch (currency) {
    AppCurrency.vnd => _compactVnd.format(amount * rate),
    AppCurrency.usd => _compactUsd.format(amount),
  };
}
```

Default `rate: 25000` means old callers that don't pass `rate` still work for now (no compile errors), but will show wrong VND values until each call site is updated in the next steps.

---

## Step 4 — Add ExchangeRateCubit to app.dart

**File:** `lib/app.dart`

Add import and provider:
```dart
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';

// In MultiBlocProvider providers list:
BlocProvider(create: (_) => ExchangeRateCubit()..load()),
```

---

## Step 5 — Add exchange rate input to Settings

**File:** `lib/presentation/screens/settings/settings_screen.dart`

Add import:
```dart
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';
```

After the currency `SegmentedButton` block, insert a new `BlocBuilder<ExchangeRateCubit, double>` that shows a rate input field **only when currency is VND**:

```dart
BlocBuilder<CurrencyCubit, AppCurrency>(
  builder: (context, currency) {
    if (currency != AppCurrency.vnd) return const SizedBox.shrink();
    return BlocBuilder<ExchangeRateCubit, double>(
      builder: (context, rate) {
        return _ExchangeRateRow(initialRate: rate);
      },
    );
  },
),
```

Add private `_ExchangeRateRow` widget (StatefulWidget — needs a local controller):
```dart
class _ExchangeRateRow extends StatefulWidget {
  const _ExchangeRateRow({required this.initialRate});
  final double initialRate;

  @override
  State<_ExchangeRateRow> createState() => _ExchangeRateRowState();
}

class _ExchangeRateRowState extends State<_ExchangeRateRow> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initialRate.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_ctrl.text.replaceAll(',', ''));
    if (v != null && v > 0) {
      context.read<ExchangeRateCubit>().setRate(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz_outlined),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '1 USD =       VND',
                suffixText: 'VND',
              ),
              onSubmitted: (_) => _submit(),
              onEditingComplete: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Step 6 — Pass rate to all CurrencyFormatter call sites

For each file below, read the exchange rate and pass it to `CurrencyFormatter.format`/`formatCompact`:

```dart
final rate = context.read<ExchangeRateCubit>().state;
CurrencyFormatter.format(amount, currency, rate: rate)
```

Use `context.watch` only in widgets where rate change should trigger immediate rebuild (dashboard is already handled via `context.watch<ExchangeRateCubit>` in Phase 1). Elsewhere `context.read` is fine.

**Files to update:**
- `lib/presentation/widgets/portfolio_header.dart`
- `lib/presentation/widgets/asset_card.dart`
- `lib/presentation/screens/analytics/analytics_screen.dart`
- `lib/presentation/screens/asset_detail/asset_detail_screen.dart`
- `lib/presentation/screens/transaction_log/transaction_log_screen.dart`
- `lib/presentation/widgets/add_transaction_bottom_sheet.dart`
- `lib/presentation/screens/dashboard/dashboard_screen.dart` — also add `context.watch<ExchangeRateCubit>().state` in `_AssetListViewState.build()`

Add import to each file:
```dart
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';
```

---

## New l10n keys

**`lib/l10n/app_en.arb`** — add:
```json
"exchangeRate": "Exchange Rate",
"exchangeRateLabel": "1 USD = {rate} VND"
```

**`lib/l10n/app_vi.arb`** — add matching Vietnamese.

Run `flutter gen-l10n` after editing ARB files.

---

## Import/export — no changes needed

Asset values in JSON are raw numbers (as entered by the user). The exchange rate is a display-only preference in SharedPreferences. On import, values come in as-is; the user's current rate applies at display time.

---

## Verification

1. `flutter analyze` — 0 issues
2. Settings → currency VND → exchange rate field appears showing 25000
3. Change rate to 24000 → tap Done/submit → all VND amounts update across dashboard, analytics, asset detail
4. Settings → currency USD → exchange rate field hidden
5. Restart app → rate setting persisted correctly
