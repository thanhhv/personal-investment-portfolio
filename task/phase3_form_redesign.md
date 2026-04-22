# Phase 3 — Add-Asset Form Redesign + Thousand-Separator Formatter

**Estimated effort:** ~45 min  
**No new files. No new dependencies.**

Current form is confusing: "Total Invested" is manually entered while "Quantity" and "Price per Unit" are optional. The user wants the reverse: enter Price × Quantity, see auto-calculated total.

---

## Form field changes (add mode only)

| Old | New |
|---|---|
| Total Invested Amount (required) | **Removed** — calculated automatically |
| Quantity (optional) | **Quantity \* (required)** |
| Price per Unit (optional) | **Price per Unit \* (required)** |
| Current Value (optional) | **Current Price per Unit (optional)** — stored as `currentPpu × qty` |

**New field order:**
1. Purchase Date *
2. Price per Unit *
3. Quantity *
4. Total Invested (read-only calculated display: `price × qty`)
5. Current Price per Unit (optional)

---

## Step 1 — Remove `_investedCtrl`

In `_AddEditAssetViewState`:

**Remove declaration:**
```dart
late final TextEditingController _investedCtrl;  // DELETE
```

**Remove from `initState()`:**
```dart
_investedCtrl = TextEditingController();  // DELETE
```

**Remove from `dispose()`:**
```dart
_investedCtrl.dispose();  // DELETE
```

---

## Step 2 — Make `_ppuCtrl` and `_quantityCtrl` required + add reactive total

**In `initState()`, add listeners for reactive total display:**
```dart
_ppuCtrl.addListener(() => setState(() {}));
_quantityCtrl.addListener(() => setState(() {}));
```

**Add computed getter:**
```dart
double? get _calculatedTotal {
  final ppu = double.tryParse(_ppuCtrl.text.replaceAll(',', ''));
  final qty = double.tryParse(_quantityCtrl.text.replaceAll(',', ''));
  if (ppu != null && qty != null) return ppu * qty;
  return null;
}
```

---

## Step 3 — Rename `_currentValueCtrl` → `_currentPpuCtrl`

Rename the controller field, its declaration, init, and dispose:
```dart
late final TextEditingController _currentPpuCtrl;
// initState: _currentPpuCtrl = TextEditingController();
// dispose: _currentPpuCtrl.dispose();
```

In `initState()`, populate `_currentPpuCtrl` from last price history point as before (but now it represents price per unit, not total value). Since priceHistory stores `value = pricePerUnit × quantity`, we can't back-derive ppu exactly in edit mode without qty — leave blank in edit mode for now (edit mode hides this section anyway).

---

## Step 4 — Update `_buildAsset()`

Replace the entire amount/qty/ppu/cv parsing block:

```dart
Asset _buildAsset() {
  final now = DateTime.now();
  final name = _nameCtrl.text.trim();
  final notes = _notesCtrl.text.trim();

  if (widget.isEdit) {
    return widget.asset!.copyWith(
      name: name,
      category: _category!,
      notes: notes.isEmpty ? null : notes,
      tags: _tags,
      updatedAt: now,
    );
  }

  final ppu = double.parse(_ppuCtrl.text.replaceAll(',', ''));
  final qty = double.parse(_quantityCtrl.text.replaceAll(',', ''));
  final amount = ppu * qty;
  final currentPpu = _currentPpuCtrl.text.trim().isEmpty
      ? null
      : double.tryParse(_currentPpuCtrl.text.replaceAll(',', ''));

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
        pricePerUnit: ppu,
        date: _purchaseDate,
      ),
    ],
    priceHistory: currentPpu != null
        ? [PricePoint(date: now, value: currentPpu * qty)]
        : const [],
    createdAt: now,
    updatedAt: now,
  );
}
```

---

## Step 5 — Add `_ThousandSeparatorFormatter`

Add this private class at the bottom of the file (above the closing brace):

```dart
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) return newValue.copyWith(text: '');
    // Allow digits and at most one decimal point
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

---

## Step 6 — Update build() form fields (add mode section)

Replace the investment fields block inside `if (!widget.isEdit) ...[`:

```dart
if (!widget.isEdit) ...[
  const SizedBox(height: 20),
  _SectionLabel(l.initialInvestment),
  const SizedBox(height: 8),
  _DatePickerRow(
    label: '${l.purchaseDate} *',
    date: _purchaseDate,
    onTap: _pickDate,
  ),
  const SizedBox(height: 12),
  // Price per Unit (required)
  TextFormField(
    controller: _ppuCtrl,
    decoration: InputDecoration(labelText: l.pricePerUnit),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [_ThousandSeparatorFormatter()],
    validator: (v) {
      if (v == null || v.trim().isEmpty) return l.fieldRequired;
      if (!v.trim().replaceAll(',', '').isValidPositiveNumber) {
        return l.validationPositiveNumber;
      }
      return null;
    },
  ),
  const SizedBox(height: 12),
  // Quantity (required)
  TextFormField(
    controller: _quantityCtrl,
    decoration: InputDecoration(labelText: l.quantityRequired),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [_ThousandSeparatorFormatter()],
    validator: (v) {
      if (v == null || v.trim().isEmpty) return l.fieldRequired;
      if (!v.trim().replaceAll(',', '').isValidPositiveNumber) {
        return l.validationPositiveNumber;
      }
      return null;
    },
  ),
  const SizedBox(height: 12),
  // Total Invested — calculated, read-only
  if (_calculatedTotal != null)
    InputDecorator(
      decoration: InputDecoration(
        labelText: l.totalInvestedCalculated,
        filled: true,
      ),
      child: Text(
        _calculatedTotal!.toStringAsFixed(2),
        style: context.textTheme.bodyLarge,
      ),
    ),
  const SizedBox(height: 12),
  // Current Price per Unit (optional)
  TextFormField(
    controller: _currentPpuCtrl,
    decoration: InputDecoration(
      labelText: l.currentPricePerUnit,
      helperText: l.leaveBlankHint,
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [_ThousandSeparatorFormatter()],
    validator: (v) {
      if (v == null || v.trim().isEmpty) return null;
      if (!v.trim().replaceAll(',', '').isValidPositiveNumber) {
        return l.validationPositiveNumber;
      }
      return null;
    },
  ),
],
```

---

## Step 7 — New l10n keys

**`lib/l10n/app_en.arb`** — add:
```json
"pricePerUnit": "Price per Unit *",
"quantityRequired": "Quantity *",
"currentPricePerUnit": "Current Price per Unit (optional)",
"totalInvestedCalculated": "Total Invested (auto)"
```

**`lib/l10n/app_vi.arb`** — add:
```json
"pricePerUnit": "Giá mỗi đơn vị *",
"quantityRequired": "Số lượng *",
"currentPricePerUnit": "Giá hiện tại mỗi đơn vị (tùy chọn)",
"totalInvestedCalculated": "Tổng đã đầu tư (tự động)"
```

Run `flutter gen-l10n` after editing.

---

## Verification

1. `flutter analyze` — 0 issues
2. Add new asset → form shows: Price per Unit *, Quantity *, [calculated total appears as you type], Current Price per Unit (optional)
3. Type "1000" in Price, "5" in Quantity → "Total Invested (auto): 5000.00" appears
4. Type "1000000" in Price field (VND) → displays as "1,000,000"
5. Save → asset stored with correct `amount = price × qty`, correct priceHistory
6. Edit existing asset → investment section is hidden (only name/category/notes/tags editable) — unchanged
