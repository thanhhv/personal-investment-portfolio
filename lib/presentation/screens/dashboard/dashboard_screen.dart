import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_lens/core/constants/asset_categories.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/presentation/blocs/balance_visibility/balance_visibility_cubit.dart';
import 'package:wealth_lens/presentation/blocs/currency/currency_cubit.dart';
import 'package:wealth_lens/presentation/blocs/dashboard/dashboard_cubit.dart';
import 'package:wealth_lens/presentation/blocs/dashboard/dashboard_state.dart';
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';
import 'package:wealth_lens/presentation/routes/app_router.dart';
import 'package:wealth_lens/presentation/widgets/asset_card.dart';
import 'package:wealth_lens/presentation/widgets/category_donut_chart.dart';
import 'package:wealth_lens/presentation/widgets/portfolio_header.dart';
import 'package:wealth_lens/presentation/widgets/shimmer_asset_card.dart';
import 'package:wealth_lens/presentation/widgets/update_price_bottom_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isVisible = context.watch<BalanceVisibilityCubit>().state;
    return BlocProvider(
      create: (_) => getIt<DashboardCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.appName),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  context.read<BalanceVisibilityCubit>().toggle(),
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart_outlined),
              onPressed: () => context.push(AppRoutes.analytics),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () async {
                await context.push(AppRoutes.settings);
                if (context.mounted) {
                  unawaited(context.read<DashboardCubit>().load());
                }
              },
            ),
          ],
        ),
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.isLoading) return const _ShimmerList();
            if (state.status == DashboardStatus.failure) {
              return _ErrorView(
                message:
                    state.errorMessage ?? context.l10n.somethingWentWrong,
              );
            }
            if (state.isEmpty) return const _EmptyState();
            return _AssetListView(state: state);
          },
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () async {
              await context.push(AppRoutes.addAsset);
              if (context.mounted) {
                unawaited(context.read<DashboardCubit>().load());
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 160),
        ShimmerAssetCard(),
        ShimmerAssetCard(),
        ShimmerAssetCard(),
        ShimmerAssetCard(),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: context.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noAssetsYet,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noAssetsMessage,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.loss.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.somethingWentWrong,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.read<DashboardCubit>().load(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Asset List with category grouping
// ─────────────────────────────────────────────────────────────────────────────

class _AssetListView extends StatefulWidget {
  const _AssetListView({required this.state});

  final DashboardState state;

  @override
  State<_AssetListView> createState() => _AssetListViewState();
}

class _AssetListViewState extends State<_AssetListView> {
  final Set<AssetCategory> _collapsed = {};

  Map<AssetCategory, List<Asset>> _groupByCategory(List<Asset> assets) {
    final map = <AssetCategory, List<Asset>>{};
    for (final asset in assets) {
      map.putIfAbsent(asset.category, () => []).add(asset);
    }
    return map;
  }

  List<Widget> _buildItems(BuildContext context, AppCurrency currency, double rate, bool isHidden) {
    final groups = _groupByCategory(widget.state.assets);
    final items = <Widget>[];
    var animIndex = 0;

    for (final entry in groups.entries) {
      final category = entry.key;
      final categoryAssets = entry.value;
      final isCollapsible = categoryAssets.length > 1;
      final isCollapsed = _collapsed.contains(category);

      items.add(
        AnimationConfiguration.staggeredList(
          position: animIndex++,
          duration: const Duration(milliseconds: 375),
          child: FadeInAnimation(
            child: _CategoryGroupHeader(
              category: category,
              count: categoryAssets.length,
              isCollapsible: isCollapsible,
              isCollapsed: isCollapsed,
              onToggle: isCollapsible
                  ? () => setState(() {
                        if (isCollapsed) {
                          _collapsed.remove(category);
                        } else {
                          _collapsed.add(category);
                        }
                      })
                  : null,
            ),
          ),
        ),
      );

      if (!isCollapsed) {
        for (final asset in categoryAssets) {
          final idx = animIndex++;
          items.add(
            AnimationConfiguration.staggeredList(
              position: idx,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 40,
                child: FadeInAnimation(
                  child: Slidable(
                    key: ValueKey(asset.id),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.22,
                      children: [
                        CustomSlidableAction(
                          onPressed: (_) => UpdatePriceBottomSheet.show(
                            context,
                            asset: asset,
                            onUpdated: () =>
                                context.read<DashboardCubit>().load(),
                          ),
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                          child: const Icon(
                            Icons.price_change_outlined,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.22,
                      children: [
                        CustomSlidableAction(
                          onPressed: (_) async {
                            final confirmed =
                                await _confirmDelete(context, asset.name);
                            if (confirmed && context.mounted) {
                              unawaited(
                                context
                                    .read<DashboardCubit>()
                                    .deleteAsset(asset.id),
                              );
                            }
                          },
                          backgroundColor: AppColors.loss,
                          foregroundColor: Colors.white,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    child: AssetCard(
                      asset: asset,
                      currency: currency,
                      rate: rate,
                      isHidden: isHidden,
                      onTap: () async {
                        await context.push(
                          AppRoutes.assetDetailPath(asset.id),
                        );
                        if (context.mounted) {
                          unawaited(context.read<DashboardCubit>().load());
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyCubit>().state;
    final rate = context.watch<ExchangeRateCubit>().state;
    final isHidden = !context.watch<BalanceVisibilityCubit>().state;
    final items = _buildItems(context, currency, rate, isHidden);

    return AnimationLimiter(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PortfolioHeader(
              totalValue: widget.state.totalValue,
              totalInvested: widget.state.totalInvested,
              profitLoss: widget.state.totalProfitLoss,
              profitLossPercent: widget.state.totalProfitLossPercent,
              currency: currency,
              rate: rate,
              isHidden: isHidden,
            ),
          ),
          if (widget.state.assets.length > 1)
            SliverToBoxAdapter(
              child: CategoryDonutChart(assets: widget.state.assets),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                context.l10n.myAssets,
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(items),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category group header
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryGroupHeader extends StatelessWidget {
  const _CategoryGroupHeader({
    required this.category,
    required this.count,
    required this.isCollapsible,
    required this.isCollapsed,
    required this.onToggle,
  });

  final AssetCategory category;
  final int count;
  final bool isCollapsible;
  final bool isCollapsed;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: category.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category.icon,
                color: category.accentColor,
                size: 15,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              category.label,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: context.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const Spacer(),
            if (isCollapsible)
              Icon(
                isCollapsed
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                size: 20,
                color: context.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _confirmDelete(BuildContext context, String name) async {
  final l = context.l10n;
  return await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.deleteAsset),
          content: Text('${l.confirmDelete(name)} ${l.cannotBeUndone}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.loss),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.delete),
            ),
          ],
        ),
      ) ??
      false;
}
