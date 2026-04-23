import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';
import 'package:wealth_lens/presentation/blocs/currency/currency_cubit.dart';
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';
import 'package:wealth_lens/presentation/blocs/locale/locale_cubit.dart';
import 'package:wealth_lens/presentation/blocs/settings/settings_cubit.dart';
import 'package:wealth_lens/presentation/blocs/settings/settings_state.dart';
import 'package:wealth_lens/presentation/blocs/theme/theme_cubit.dart';
import 'package:wealth_lens/presentation/widgets/import_confirm_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>()..loadVersion(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) async {
        if (state.status == SettingsStatus.previewReady &&
            state.importPreview != null) {
          final action = await ImportConfirmDialog.show(
            context,
            state.importPreview!,
          );
          if (!context.mounted) return;
          if (action == null) {
            context.read<SettingsCubit>().dismissPreview();
            return;
          }
          await context.read<SettingsCubit>().confirmImport(
                merge: action == ImportAction.merge,
              );
        }
        if (!context.mounted) return;
        if (state.status == SettingsStatus.exportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.exportSuccess),
              backgroundColor: AppColors.profit,
            ),
          );
          context.read<SettingsCubit>().resetStatus();
        }
        if (state.status == SettingsStatus.importSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.importSuccess),
              backgroundColor: AppColors.profit,
            ),
          );
          context.read<SettingsCubit>().resetStatus();
        }
        if (state.status == SettingsStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.loss,
            ),
          );
          context.read<SettingsCubit>().resetStatus();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.settings)),
          body: ListView(
            children: [
              _SectionHeader(label: context.l10n.data),
              Builder(
                builder: (tileContext) => ListTile(
                  leading: const Icon(Icons.upload_outlined),
                  title: Text(context.l10n.exportPortfolio),
                  subtitle: Text(context.l10n.exportSubtitle),
                  trailing: state.isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: state.isBusy
                      ? null
                      : () {
                          final box =
                              tileContext.findRenderObject()! as RenderBox;
                          final rect =
                              box.localToGlobal(Offset.zero) & box.size;
                          context
                              .read<SettingsCubit>()
                              .exportPortfolio(sharePositionOrigin: rect);
                        },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(context.l10n.importPortfolio),
                subtitle: Text(context.l10n.importSubtitle),
                trailing: state.isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: state.isBusy
                    ? null
                    : () => context.read<SettingsCubit>().pickImportFile(),
              ),
              const Divider(),
              _SectionHeader(label: context.l10n.appearance),
              // ── Theme ──────────────────────────────────────────────────────
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return _ToggleRow(
                    icon: Icons.brightness_6_outlined,
                    label: context.l10n.theme,
                    child: SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(context.l10n.themeLight),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(context.l10n.themeSystem),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(context.l10n.themeDark),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (modes) =>
                          context.read<ThemeCubit>().setTheme(modes.first),
                    ),
                  );
                },
              ),
              // ── Language ───────────────────────────────────────────────────
              BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return _ToggleRow(
                    icon: Icons.language_outlined,
                    label: context.l10n.language,
                    child: SegmentedButton<Locale>(
                      segments: [
                        ButtonSegment(
                          value: const Locale('en'),
                          label: Text(context.l10n.languageEnglish),
                        ),
                        ButtonSegment(
                          value: const Locale('vi'),
                          label: Text(context.l10n.languageVietnamese),
                        ),
                      ],
                      selected: {locale},
                      onSelectionChanged: (locales) =>
                          context.read<LocaleCubit>().setLocale(locales.first),
                    ),
                  );
                },
              ),
              // ── Currency ───────────────────────────────────────────────────
              BlocBuilder<CurrencyCubit, AppCurrency>(
                builder: (context, currency) {
                  return _ToggleRow(
                    icon: Icons.currency_exchange_outlined,
                    label: context.l10n.currency,
                    child: SegmentedButton<AppCurrency>(
                      segments: const [
                        ButtonSegment(
                          value: AppCurrency.usd,
                          label: Text('USD'),
                        ),
                        ButtonSegment(
                          value: AppCurrency.vnd,
                          label: Text('VND'),
                        ),
                      ],
                      selected: {currency},
                      onSelectionChanged: (currencies) => context
                          .read<CurrencyCubit>()
                          .setCurrency(currencies.first),
                    ),
                  );
                },
              ),
              // ── Exchange Rate ──────────────────────────────────────────────
              BlocBuilder<CurrencyCubit, AppCurrency>(
                builder: (context, currency) {
                  if (currency != AppCurrency.vnd) return const SizedBox.shrink();
                  return BlocBuilder<ExchangeRateCubit, double>(
                    builder: (context, rate) => _ExchangeRateRow(initialRate: rate),
                  );
                },
              ),
              const Divider(),
              _SectionHeader(label: context.l10n.about),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(context.l10n.version),
                trailing: Text(
                  state.appVersion ?? '—',
                  style: context.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: context.textTheme.labelLarge?.copyWith(
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textTheme.bodyLarge),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Icon(
            Icons.swap_horiz_outlined,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l.exchangeRate,
                hintText: l.exchangeRateHint,
                prefixText: '1 USD = ',
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
