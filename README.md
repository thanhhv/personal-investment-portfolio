# WealthLens 📊

**Your personal investment portfolio tracker — private, offline, beautiful.**

WealthLens is a mobile app built with Flutter for iOS and Android that helps you track all your investments in one place. No account required, no cloud sync, no data ever leaves your device. Everything is stored locally and can be exported or imported as a single JSON file.

---

## Why WealthLens?

Most investment tracking apps require you to connect bank accounts, create accounts, or sync to the cloud. WealthLens takes the opposite approach: you enter your data manually, it stays on your phone, and you stay in control. Think of it as a private financial journal with beautiful charts.

---

## Features

### Portfolio Dashboard
- **Total portfolio value** displayed prominently with an animated number counter
- **Total profit / loss** in both absolute amount and percentage, color-coded green/red
- **Currency toggle** between VND (₫) and USD ($) at a tap
- **Donut chart** showing asset allocation by category
- **Bar chart** showing profit/loss breakdown per category
- **Mini sparkline** for each top-performing asset
- Asset list grouped by category, each card showing current value, P&L %, and a trend arrow

### Asset Categories
Track 8 built-in investment types — all extensible:

| Category | Examples |
|---|---|
| 💰 Cryptocurrency | Bitcoin, Ethereum, altcoins |
| 📈 Stocks | Individual equities, ETFs on stock exchanges |
| 🏦 Mutual Fund / ETF | Index funds, actively managed funds |
| 🥇 Gold | Physical gold, gold savings accounts |
| 🏠 Real Estate | Property, land, REITs |
| 🏧 Savings / Deposit | Term deposits, savings accounts, CDs |
| 🤝 Peer Lending | P2P lending platforms, private loans |
| 📦 Other | Anything that doesn't fit the above |

### Asset Detail & History
- Full asset profile: name, category, icon, purchase date
- Current value vs. total invested, with profit/loss percentage
- **Price history line chart** drawn from your manual entries
- Complete **transaction log** — every buy, sell, and value update
- Notes field for context (strategy, reminders, sources)
- Free-form **tags** for custom grouping

### Transaction Tracking
Each asset holds a full transaction history:
- **Buy** — record a purchase with date, amount, quantity, price per unit
- **Sell** — record a partial or full sale
- **Update** — update the current valuation without a buy/sell event
- All transactions sorted chronologically with notes

### Add / Edit Assets
- Asset name, category (with icons), purchase date picker
- Quantity field (for crypto / stocks)
- Price per unit (optional, auto-calculates total)
- Total amount invested
- Current market value (manual input)
- Multi-line notes
- Tags (free-form chip input)
- Full input validation — positive numbers only, required fields enforced

### Analytics Screen
- **Area chart**: total invested vs. current value over time
- **Best & worst performing** assets ranked by return percentage
- **Category breakdown table** — value and allocation per type
- **Monthly snapshot** — how your portfolio evolved month by month

### Export & Import
- **Export**: generates a `.wealthlens.json` file and opens the native share sheet — send it to Files, email, iCloud, Google Drive, anywhere
- **Import**: pick a `.wealthlens.json` file, review a diff summary (how many assets will be added or replaced), then choose **Merge** (add new, keep existing) or **Replace All**
- JSON format is human-readable and version-validated

### Settings
- **Language**: English / Tiếng Việt
- **Currency**: VND (₫) / USD ($)
- **Theme**: Light / Dark / System default
- Export & Import portfolio from this screen
- App version info

### Onboarding
First-launch walkthrough with 3 slides:
1. Track Everything
2. Visualize Growth
3. Stay in Control

Shown only once — skippable, remembers completion.

---

## Privacy

- **100% offline** — no network requests, no analytics, no crash reporting
- **No account needed** — open the app and start tracking immediately
- **Your data is yours** — stored in the app's local database (Hive), exportable as a plain JSON file at any time
- **No ads, no subscriptions** — open source, free to use

---

## Tech Stack

| Concern | Library |
|---|---|
| Framework | Flutter 3.x (iOS + Android) |
| Architecture | Clean Architecture (Domain / Data / Presentation) |
| State management | flutter_bloc + Cubit |
| Local database | Hive v2 |
| Navigation | GoRouter |
| Charts | fl_chart |
| Dependency injection | get_it + injectable |
| Serialization | freezed + json_serializable |
| Error handling | fpdart (`Either<Failure, Success>`) |
| Fonts | Plus Jakarta Sans + DM Sans (Google Fonts) |
| Localization | Flutter intl (ARB files) |
| Export / Import | path_provider + share_plus + file_picker |

---

## Localization

Full support for:
- 🇺🇸 **English**
- 🇻🇳 **Tiếng Việt**

All strings are externalized in ARB files. Adding a new language requires only a new `.arb` file — no code changes.

Number formatting respects locale conventions:
- VND: `1.500.000 ₫` (no decimals)
- USD: `$1,500.00` (2 decimals)

---

## Design System

| Token | Value |
|---|---|
| Primary color | `#00C896` (Emerald green) |
| Secondary color | `#2E6FF3` (Royal blue) |
| Accent | Gradient blend of primary → secondary |
| Display font | Plus Jakarta Sans |
| Body font | DM Sans |
| Corner radius | 16px (cards), 12px (inputs), 8px (chips) |
| Theme | Material 3, light + dark |

Animations throughout:
- Splash: scale + fade logo reveal
- Onboarding: page transitions
- Dashboard: animated number counter on total value
- Charts: draw-on animations via fl_chart
- Lists: staggered entrance animations
- Asset cards: Hero transitions into detail screen
- Loading states: shimmer placeholders

---

## Getting Started

### Prerequisites
- Flutter 3.22+ installed
- Android Studio / Xcode for device/emulator targets
- CocoaPods (for iOS)

### Run

```bash
# Clone / open project
cd personal-finance-tracker

# Install dependencies
flutter pub get

# Regenerate code (models, DI, l10n)
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n

# Run on device or emulator
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS (requires Xcode + provisioning profile)
flutter build ios --release
```

---

## Project Structure

```
lib/
├── core/            # Theme, constants, errors, DI, utils, extensions
├── data/            # Hive datasource, models, repository implementations
├── domain/          # Entities, abstract repositories, use cases
├── presentation/    # Screens, widgets, blocs/cubits, router
└── l10n/            # ARB localization files
```

See [CLAUDE.md](CLAUDE.md) for detailed implementation notes and per-phase build plan.

---

## Roadmap

- [x] Phase 0 — Project setup, architecture, theme, routing
- [ ] Phase 1 — Data layer (Hive models, repositories, use cases)
- [ ] Phase 2 — Core screens with static data (Dashboard, charts)
- [ ] Phase 3 — Asset CRUD fully wired to real data
- [ ] Phase 4 — Charts & Analytics screen
- [ ] Phase 5 — Export / Import feature
- [ ] Phase 6 — Full i18n, animations polish, edge cases

---

## License

MIT — do whatever you want with it.
