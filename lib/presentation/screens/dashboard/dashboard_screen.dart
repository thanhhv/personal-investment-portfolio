import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/presentation/blocs/currency/currency_cubit.dart';
import 'package:wealth_lens/presentation/blocs/dashboard/dashboard_cubit.dart';
import 'package:wealth_lens/presentation/blocs/dashboard/dashboard_state.dart';
import 'package:wealth_lens/presentation/routes/app_router.dart';
import 'package:wealth_lens/presentation/widgets/asset_card.dart';
import 'package:wealth_lens/presentation/widgets/category_donut_chart.dart';
import 'package:wealth_lens/presentation/widgets/portfolio_header.dart';
import 'package:wealth_lens/presentation/widgets/shimmer_asset_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.appName),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_outlined),
              onPressed: () => context.push(AppRoutes.analytics),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.isLoading) return const _ShimmerList();
            if (state.status == DashboardStatus.failure) {
              return _ErrorView(message: state.errorMessage ?? context.l10n.somethingWentWrong);
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

class _AssetListView extends StatelessWidget {
  const _AssetListView({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyCubit>().state;
    return AnimationLimiter(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PortfolioHeader(
              totalValue: state.totalValue,
              totalInvested: state.totalInvested,
              profitLoss: state.totalProfitLoss,
              profitLossPercent: state.totalProfitLossPercent,
              currency: currency,
            ),
          ),
          if (state.assets.length > 1)
            SliverToBoxAdapter(
              child: CategoryDonutChart(assets: state.assets),
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
            delegate: SliverChildBuilderDelegate(
              (context, index) => AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 40,
                  child: FadeInAnimation(
                    child: AssetCard(
                      asset: state.assets[index],
                      currency: currency,
                      onTap: () async {
                        await context.push(
                          AppRoutes.assetDetailPath(state.assets[index].id),
                        );
                        if (context.mounted) {
                          unawaited(context.read<DashboardCubit>().load());
                        }
                      },
                    ),
                  ),
                ),
              ),
              childCount: state.assets.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
