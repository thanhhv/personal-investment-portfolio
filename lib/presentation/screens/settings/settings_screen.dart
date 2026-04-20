import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/presentation/blocs/settings/settings_cubit.dart';
import 'package:wealth_lens/presentation/blocs/settings/settings_state.dart';
import 'package:wealth_lens/presentation/blocs/theme/theme_cubit.dart';
import 'package:wealth_lens/presentation/widgets/import_confirm_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>(),
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
        if (state.status == SettingsStatus.success &&
            state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
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
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: ListView(
            children: [
              const _SectionHeader(label: 'Data'),
              ListTile(
                leading: const Icon(Icons.upload_outlined),
                title: const Text('Export Portfolio'),
                subtitle: const Text('Share as .wealthlens.json'),
                trailing: state.isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: state.isBusy
                    ? null
                    : () => context.read<SettingsCubit>().exportPortfolio(),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Import Portfolio'),
                subtitle: const Text('Load from .wealthlens.json file'),
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
              const _SectionHeader(label: 'Appearance'),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.brightness_6_outlined),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Theme',
                                style: context.textTheme.bodyLarge,
                              ),
                              SegmentedButton<ThemeMode>(
                                segments: const [
                                  ButtonSegment(
                                    value: ThemeMode.light,
                                    label: Text('Light'),
                                    icon: Icon(Icons.light_mode_outlined),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.system,
                                    label: Text('System'),
                                    icon: Icon(Icons.brightness_auto_outlined),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.dark,
                                    label: Text('Dark'),
                                    icon: Icon(Icons.dark_mode_outlined),
                                  ),
                                ],
                                selected: {themeMode},
                                onSelectionChanged: (modes) {
                                  context
                                      .read<ThemeCubit>()
                                      .setTheme(modes.first);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),
              const _SectionHeader(label: 'About'),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Version'),
                trailing: Text('1.0.0'),
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
