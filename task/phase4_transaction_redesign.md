# Phase 4 — Add Transaction Form Redesign

**Estimated effort:** ~60 min  
**Files changed:** `add_transaction_bottom_sheet.dart`, `asset_detail_screen.dart`, `transaction_log_screen.dart`  
**No new files. No build_runner needed.**

---

## Context

Current problems:
1. Transaction form has a single "Amount" field — inconsistent with add-asset form where total = ppu × qty
2. "Update" type is shown in the UI — user wants only Buy and Sell
3. When a sell is recorded, the portfolio's current value doesn't decrease
4. No sell validation (could sell for more than you own)

---

## Changes overview

| Area | Before | After |
|---|---|---|
| Type selector | Buy / Sell / Update | Buy / Sell only |
| Amount input | single `amount` field | Price per Unit ✱ + Quantity ✱, Total auto-calculated |
| Sell validation | none | total ≤ asset.currentValue, error if exceeded |
| Sell effect | transaction stored, value unchanged | transaction stored + new priceHistory point = max(0, currentValue − sellTotal) |
| Bottom sheet params | `assetId, onAdded` | `asset, onAdded` (full Asset object) |

---

## Step 1 — Update `AddTransactionBottomSheet` signature

**File:** `lib/presentation/widgets/add_transaction_bottom_sheet.dart`

Change constructor and `show()` to accept `Asset` instead of `String assetId`:

```dart
class AddTransactionBottomSheet extends StatefulWidget {
  const AddTransactionBottomSheet({
    required this.asset,       // was: assetId
    required this.onAdded,
    required this.currency,    // NEW — passed from caller, modal context can't read BLoC
    required this.rate,        // NEW
    super.key,
  });

  final Asset asset;
  final VoidCallback onAdded;
  final AppCurrency currency;
  final double rate;

  static Future<void> show(
    BuildContext context, {
    required Asset asset,
    required VoidCallback onAdded,
  }) {
    // Read here — this context IS in the widget tree
    final currency = context.read<CurrencyCubit>().state;
    final rate = context.read<ExchangeRateCubit>().state;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddTransactionBottomSheet(
        asset: asset,
        onAdded: onAdded,
        currency: currency,
        rate: rate,
      ),
    );
  }
}
```

---

## Step 2 — Redesign state and form fields

Replace:
- `_amountCtrl` → `_ppuCtrl` + `_quantityCtrl` (same pattern as add-asset form)
- Remove `_type == TransactionType.update` segment

**State fields:**
```dart
TransactionType _type = TransactionType.buy;  // only buy/sell allowed
final _ppuCtrl = TextEditingController();
final _quantityCtrl = TextEditingController();
final _noteCtrl = TextEditingController();
DateTime _date = DateTime.now();
bool _isSubmitting = false;
```

**Add listeners for reactive total:**
```dart
@override
void initState() {
  super.initState();
  _ppuCtrl.addListener(() => setState(() {}));
  _quantityCtrl.addListener(() => setState(() {}));
}
```

**Computed total getter:**
```dart
double? get _calculatedTotal {
  final ppu = double.tryParse(_ppuCtrl.text.replaceAll(',', ''));
  final qty = double.tryParse(_quantityCtrl.text.replaceAll(',', ''));
  if (ppu != null && qty != null && ppu > 0 && qty > 0) return ppu * qty;
  return null;
}
```

---

## Step 3 — Type segmented button: remove Update

```dart
SegmentedButton<TransactionType>(
  segments: [
    ButtonSegment(value: TransactionType.buy,  label: Text(l.transactionBuy)),
    ButtonSegment(value: TransactionType.sell, label: Text(l.transactionSell)),
  ],
  selected: {_type},
  onSelectionChanged: (s) => setState(() => _type = s.first),
  showSelectedIcon: false,
),
```

---

## Step 4 — Form fields in build()

Replace the old `_amountCtrl` field + `_quantityCtrl` with:

```dart
// Price per unit *
TextFormField(
  controller: _ppuCtrl,
  decoration: InputDecoration(labelText: l.pricePerUnit),
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [_ThousandSeparatorFormatter()],
  autofocus: true,
  validator: (v) {
    if (v == null || v.trim().isEmpty) return l.fieldRequired;
    if (!v.trim().replaceAll(',', '').isValidPositiveNumber) return l.validationPositiveNumber;
    return null;
  },
),
const SizedBox(height: 12),
// Quantity *
TextFormField(
  controller: _quantityCtrl,
  decoration: InputDecoration(labelText: l.quantityRequired),
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [_ThousandSeparatorFormatter()],
  validator: (v) {
    if (v == null || v.trim().isEmpty) return l.fieldRequired;
    if (!v.trim().replaceAll(',', '').isValidPositiveNumber) return l.validationPositiveNumber;
    if (_type == TransactionType.sell) {
      final qty = double.tryParse(v.trim().replaceAll(',', ''));
      final total = qty != null && _ppuCtrl.text.isNotEmpty
          ? qty * (double.tryParse(_ppuCtrl.text.replaceAll(',', '')) ?? 0)
          : null;
      if (total != null && total > widget.asset.currentValue) {
        return l.sellExceedsValue;
      }
    }
    return null;
  },
),
const SizedBox(height: 12),
// Calculated total (read-only, shown when both fields have values)
if (_calculatedTotal != null)
  InputDecorator(
    decoration: InputDecoration(
      labelText: l.totalInvestedCalculated,
      filled: true,
    ),
    child: Text(
      _calculatedTotal!.toStringAsFixed(2),
      style: Theme.of(context).textTheme.bodyLarge,
    ),
  ),
if (_calculatedTotal != null) const SizedBox(height: 12),
// Note (optional)
TextFormField(
  controller: _noteCtrl,
  decoration: InputDecoration(labelText: l.noteOptional),
),
```

---

## Step 5 — Update `_submit()` logic

```dart
Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isSubmitting = true);

  final ppu = double.parse(_ppuCtrl.text.replaceAll(',', ''));
  final qty = double.parse(_quantityCtrl.text.replaceAll(',', ''));
  final total = ppu * qty;

  final tx = Transaction(
    id: '',
    type: _type,
    amount: total,
    quantity: qty,
    pricePerUnit: ppu,
    note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    date: _date,
  );

  Either<Failure, Unit> result;

  if (_type == TransactionType.sell) {
    // Add transaction + update currentValue by subtracting sell proceeds
    final newPricePoint = PricePoint(
      date: _date,
      value: (widget.asset.currentValue - total).clamp(0, double.infinity),
    );
    final updatedAsset = widget.asset.copyWith(
      transactions: [...widget.asset.transactions, tx.copyWith(id: const Uuid().v4())],
      priceHistory: [...widget.asset.priceHistory, newPricePoint],
    );
    result = await getIt<SaveAssetUseCase>()(updatedAsset);
  } else {
    result = await getIt<AddTransactionUseCase>()(widget.asset.id, tx);
  }

  result.fold(
    (failure) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    },
    (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onAdded();
    },
  );
}
```

**New imports needed:**
```dart
import 'package:uuid/uuid.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';
import 'package:wealth_lens/domain/entities/price_point.dart';
import 'package:wealth_lens/domain/usecases/save_asset_usecase.dart';
import 'package:wealth_lens/presentation/screens/add_edit_asset/add_edit_asset_screen.dart'; // for _ThousandSeparatorFormatter
```

**Wait** — `_ThousandSeparatorFormatter` is a private class in `add_edit_asset_screen.dart`. Move it to a shared location or duplicate it.

**Resolution:** Extract `_ThousandSeparatorFormatter` into a new shared file:

**New file:** `lib/core/utils/thousand_separator_formatter.dart`
```dart
import 'package:flutter/services.dart';

class ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text;
    if (raw.isEmpty) return newValue.copyWith(text: '');
    final cleaned = raw.replaceAll(RegExp(r'[^\d.]'), '');
    final parts = cleaned.split('.');
    final intPart = _addCommas(parts[0]);
    final result = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  String _addCommas(String s) {
    if (s.isEmpty) return s;
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
```

Update `add_edit_asset_screen.dart` to import and use `ThousandSeparatorFormatter` (remove the private `_ThousandSeparatorFormatter` class).

---

## Step 6 — Update call sites

**`lib/presentation/screens/asset_detail/asset_detail_screen.dart`**

Change:
```dart
AddTransactionBottomSheet.show(
  context,
  assetId: assetId,         // REMOVE
  asset: asset,             // ADD — pass from _AssetDetailContent.asset
  onAdded: () => context.read<AssetDetailCubit>().load(assetId),
),
```

**`lib/presentation/screens/transaction_log/transaction_log_screen.dart`**

The screen has access to `state.asset!`. Change:
```dart
AddTransactionBottomSheet.show(
  context,
  asset: state.asset!,      // was assetId: assetId
  onAdded: () => context.read<AssetDetailCubit>().load(assetId),
),
```

---

## Step 7 — New l10n keys

**`lib/l10n/app_en.arb`:**
```json
"sellExceedsValue": "Sell amount exceeds current asset value"
```

**`lib/l10n/app_vi.arb`:**
```json
"sellExceedsValue": "Giá trị bán vượt quá giá trị tài sản hiện tại"
```

Run `flutter gen-l10n` after editing.

---

## Verification

1. `flutter analyze` — 0 issues
2. Add Buy: enter ppu=1000, qty=5 → total shows 5000 → save → transaction stored with amount=5000, qty=5, ppu=1000
3. Add Sell: enter ppu=1200, qty=5 → total shows 6000 → if currentValue < 6000 → validation error shown
4. Valid sell: ppu=1000, qty=3, total=3000 ≤ currentValue → save → asset currentValue decreases by 3000
5. "Update" option is gone from the type segmented button
6. Thousand separator: type "10000" → displays "10,000"
