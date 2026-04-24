# Phase 5 — Currency-Aware Input (Store in USD)

**Estimated effort:** ~45 min  
**Files changed:** `add_edit_asset_screen.dart`, `add_transaction_bottom_sheet.dart`  
**No new dependencies. No build_runner needed.**

---

## Context

**Problem:** Values are currently stored as whatever number the user typed. If the user is in VND mode and types 50,000, that is stored as `50000`. When switching to USD, it shows $50,000 — which is wrong; it should show $2 (50,000 ÷ 25,000).

**Goal:** Values are always stored in USD. When the user types in VND mode, the app divides by the exchange rate before storing. Switching currencies will always show the correct converted amount.

**Example:**
| User types | Mode | Exchange rate | Stored (USD) | Displayed in VND | Displayed in USD |
|---|---|---|---|---|---|
| 50,000 | VND | 25,000 | 2.0 | ₫50,000 | $2.00 |
| 2 | USD | 25,000 | 2.0 | ₫50,000 | $2.00 |

**Note on existing data:** Assets saved before this change have values stored as raw numbers (USD assumed). If any VND values were entered before this fix, those assets will show incorrect amounts. Users should delete and re-add those assets.

**Import/Export:** No format change needed. The `.wealthlens.json` already stores raw values. After this change those values are consistently USD.

---

## Step 1 — Add currency prefix to input fields

Show the active currency symbol in all amount input fields so the user knows what currency they're entering.

In both `add_edit_asset_screen.dart` and `add_transaction_bottom_sheet.dart`, read currency once at the top of `build()` and add `prefixText` to each amount field's `InputDecoration`:

```dart
// In build() — read currency from widget param (bottom sheet) or context (add asset screen)
final currencySymbol = CurrencyFormatter.symbol(widget.currency); // bottom sheet
// OR for add_edit_asset_screen:
final currency = context.read<CurrencyCubit>().state;
final currencySymbol = CurrencyFormatter.symbol(currency);
```

For each amount-related `InputDecoration`:
```dart
decoration: InputDecoration(
  labelText: l.pricePerUnit,
  prefixText: '$currencySymbol ',
),
```

---

## Step 2 — Convert on save in `add_edit_asset_screen.dart`

**File:** `lib/presentation/screens/add_edit_asset/add_edit_asset_screen.dart`

In `_buildAsset()`, after parsing ppu and qty, convert if VND:

```dart
Asset _buildAsset() {
  final now = DateTime.now();
  final name = _nameCtrl.text.trim();
  final notes = _notesCtrl.text.trim();

  if (widget.isEdit) { ... } // unchanged

  final currency = context.read<CurrencyCubit>().state;
  final rate = context.read<ExchangeRateCubit>().state;

  final ppuRaw = double.parse(_ppuCtrl.text.replaceAll(',', ''));
  final qty = double.parse(_quantityCtrl.text.replaceAll(',', ''));

  // Convert to USD for storage
  final ppuStored = currency == AppCurrency.vnd ? ppuRaw / rate : ppuRaw;
  final amount = ppuStored * qty;

  final currentPpuRaw = _currentPpuCtrl.text.trim().isEmpty
      ? null
      : double.tryParse(_currentPpuCtrl.text.replaceAll(',', ''));
  final currentPpuStored = currentPpuRaw == null
      ? null
      : (currency == AppCurrency.vnd ? currentPpuRaw / rate : currentPpuRaw);

  return Asset(
    id: '',
    name: name,
    category: _category!,
    notes: notes.isEmpty ? null : notes,
    tags: _tags,
    transactions: [
      Transaction(
        id: '',
        type: TransactionType.buy,
        amount: amount,
        quantity: qty,
        pricePerUnit: ppuStored,
        date: _purchaseDate,
      ),
    ],
    priceHistory: currentPpuStored != null
        ? [PricePoint(date: now, value: currentPpuStored * qty)]
        : const [],
    createdAt: now,
    updatedAt: now,
  );
}
```

**New import needed:**
```dart
import 'package:wealth_lens/presentation/blocs/currency/currency_cubit.dart';
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';
```

---

## Step 3 — Convert on save in `add_transaction_bottom_sheet.dart`

Phase 4 already adds `currency` and `rate` as constructor params to `AddTransactionBottomSheet`. In `_submit()`, convert ppu before storing:

```dart
final ppuRaw = double.parse(_ppuCtrl.text.replaceAll(',', ''));
final qty = double.parse(_quantityCtrl.text.replaceAll(',', ''));

// Convert to USD for storage
final ppuStored = widget.currency == AppCurrency.vnd
    ? ppuRaw / widget.rate
    : ppuRaw;
final total = ppuStored * qty;

final tx = Transaction(
  id: '',
  type: _type,
  amount: total,
  quantity: qty,
  pricePerUnit: ppuStored,
  ...
);
```

For sell: the `newPricePoint.value` calculation also uses the stored (USD) value:
```dart
final newPricePoint = PricePoint(
  date: _date,
  value: (widget.asset.currentValue - total).clamp(0, double.infinity),
);
```
`widget.asset.currentValue` is already in USD, `total` is now in USD — so this is correct.

---

## Step 4 — Sell validation uses USD stored value

The sell validation in Phase 4 compares `total <= widget.asset.currentValue`. Since `total` will now be in USD (after the conversion above), and `currentValue` is also in USD, the comparison is correct.

However, the **error message** shown to the user should display in their currency:

```dart
// In validator for quantity field:
if (total > widget.asset.currentValue) {
  final displayMax = CurrencyFormatter.format(
    widget.asset.currentValue,
    widget.currency,
    rate: widget.rate,
  );
  return '${l.sellExceedsValue}: $displayMax';
}
```

---

## Step 5 — Display hint in form

Add a subtitle below the section label showing what currency the user is entering in:

```dart
// In add_edit_asset_screen.dart, below _SectionLabel(l.initialInvestment):
Text(
  currency == AppCurrency.vnd
      ? 'Enter amounts in VND (₫)'
      : 'Enter amounts in USD (\$)',
  style: context.textTheme.bodySmall?.copyWith(
    color: context.colorScheme.onSurface.withValues(alpha: 0.55),
  ),
),
```

This can also use l10n keys if preferred, but a simple string is fine for now.

---

## Verification

1. `flutter analyze` — 0 issues
2. **USD mode:** Add asset, price=2, qty=1 → stored amount=2.0 → switch to VND → shows ₫50,000 (2 × 25,000) ✓
3. **VND mode:** Add asset, price=50000, qty=1 → stored amount=2.0 (50000÷25000) → switch to USD → shows $2.00 ✓
4. **VND sell validation:** currentValue=$100 (₫2,500,000), attempt sell for ₫3,000,000 (price=3,000,000÷1qty) → stored=$120 → $120 > $100 → error shown in ₫2,500,000 ✓
5. Input fields show currency prefix: ₫ when VND, $ when USD
6. Export → Import round-trip: values unchanged ✓
