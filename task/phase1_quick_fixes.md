# Phase 1 — Quick Fixes (3 small changes)

**Estimated effort:** ~15 min  
**No new files, no new dependencies, no build_runner needed.**

---

## 1a. VND currency reactivity on dashboard

**File:** `lib/presentation/screens/dashboard/dashboard_screen.dart`

In `_AssetListViewState.build()` (around line 301), change:

```dart
// Before:
final currency = context.read<CurrencyCubit>().state;

// After:
final currency = context.watch<CurrencyCubit>().state;
```

**Why:** `context.read` is one-shot (no subscription). `context.watch` subscribes to the cubit and re-renders the widget tree when currency changes.

---

## 1b. Category collapse threshold: > 2 → > 1

**File:** `lib/presentation/screens/dashboard/dashboard_screen.dart`

In `_buildItems()` (around line 209), change:

```dart
// Before:
final isCollapsible = categoryAssets.length > 2;

// After:
final isCollapsible = categoryAssets.length > 1;
```

**Why:** A group of 2 assets should also show the collapse chevron so the user can collapse it.

---

## 1c. Pie chart legend spacing

**File:** `lib/presentation/widgets/category_donut_chart.dart`

Around line 81, change `SizedBox(width: 16)` between the donut and legend to `SizedBox(width: 24)`:

```dart
// Before:
const SizedBox(width: 16),

// After:
const SizedBox(width: 24),
```

---

## Verification

1. `flutter analyze` — 0 issues
2. Settings → switch to VND → dashboard asset amounts immediately update
3. Add 2 assets of same category → collapse chevron appears
4. Dashboard → breakdown chart → legend visibly less cramped against the donut
