import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/core/theme/app_text_styles.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';
import 'package:wealth_lens/core/utils/date_formatter.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/entities/price_point.dart';
import 'package:wealth_lens/domain/entities/transaction.dart';
import 'package:wealth_lens/presentation/blocs/asset_detail/asset_detail_cubit.dart';
import 'package:wealth_lens/presentation/blocs/asset_detail/asset_detail_state.dart';
import 'package:wealth_lens/presentation/routes/app_router.dart';
import 'package:wealth_lens/presentation/widgets/add_transaction_bottom_sheet.dart';

const _currency = AppCurrency.usd;

class AssetDetailScreen extends StatelessWidget {
  const AssetDetailScreen({required this.assetId, super.key});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AssetDetailCubit>()..load(assetId),
      child: _AssetDetailView(assetId: assetId),
    );
  }
}

class _AssetDetailView extends StatelessWidget {
  const _AssetDetailView({required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssetDetailCubit, AssetDetailState>(
      listenWhen: (prev, curr) =>
          curr.isDeleted ||
          (curr.status == AssetDetailStatus.failure &&
              prev.status != AssetDetailStatus.failure),
      listener: (context, state) {
        if (state.isDeleted) context.pop();
        if (state.status == AssetDetailStatus.failure &&
            state.asset == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error')),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.asset == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Asset not found')),
          );
        }
        return _AssetDetailContent(
          assetId: assetId,
          asset: state.asset!,
        );
      },
    );
  }
}

class _AssetDetailContent extends StatelessWidget {
  const _AssetDetailContent({
    required this.assetId,
    required this.asset,
  });

  final String assetId;
  final Asset asset;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text('Delete "${asset.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.loss,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      unawaited(context.read<AssetDetailCubit>().deleteAsset(assetId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedHistory = [...asset.priceHistory]
      ..sort((a, b) => a.date.compareTo(b.date));
    final sortedTx = [...asset.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await context.push(
                AppRoutes.editAssetPath(assetId),
                extra: asset,
              );
              if (context.mounted) {
                unawaited(context.read<AssetDetailCubit>().load(assetId));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          _AssetHeader(asset: asset),
          if (sortedHistory.length >= 2) _PriceChart(history: sortedHistory),
          _TransactionsSection(
            assetId: assetId,
            transactions: sortedTx,
          ),
          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddTransactionBottomSheet.show(
          context,
          assetId: assetId,
          onAdded: () =>
              context.read<AssetDetailCubit>().load(assetId),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}

class _AssetHeader extends StatelessWidget {
  const _AssetHeader({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final isProfit = asset.profitLoss >= 0;
    final plColor = isProfit ? AppColors.profit : AppColors.loss;

    return Hero(
      tag: 'asset_${asset.id}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      asset.category.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.category.label,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        Text(
                          asset.name,
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                CurrencyFormatter.format(asset.currentValue, _currency),
                style: AppTextStyles.portfolioTotal.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _InfoChip(
                    label: 'Invested',
                    value: CurrencyFormatter.formatCompact(
                      asset.totalInvested,
                      _currency,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    label: 'P&L',
                    value:
                        '${CurrencyFormatter.formatCompact(asset.profitLoss.abs(), _currency)} '
                        '(${CurrencyFormatter.formatPercent(asset.profitLossPercent)})',
                    color: plColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
          ),
          Text(
            value,
            style: context.textTheme.labelMedium?.copyWith(
              color: color ?? Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceChart extends StatelessWidget {
  const _PriceChart({required this.history});

  final List<PricePoint> history;

  @override
  Widget build(BuildContext context) {
    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Price History', style: context.textTheme.headlineSmall),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: minY - padding,
                maxY: maxY + padding,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  const _TransactionsSection({
    required this.assetId,
    required this.transactions,
  });

  final String assetId;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              Text(
                'Transactions',
                style: context.textTheme.headlineSmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    context.push(AppRoutes.transactionsPath(assetId)),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No transactions yet',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          ...transactions.take(5).map(
                (tx) => _TransactionTile(
                  assetId: assetId,
                  transaction: tx,
                ),
              ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.assetId,
    required this.transaction,
  });

  final String assetId;
  final Transaction transaction;

  Color _typeColor() => switch (transaction.type) {
        TransactionType.buy => AppColors.secondary,
        TransactionType.sell => AppColors.loss,
        TransactionType.update => AppColors.neutral,
      };

  String _typeLabel() => switch (transaction.type) {
        TransactionType.buy => 'Buy',
        TransactionType.sell => 'Sell',
        TransactionType.update => 'Update',
      };

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          transaction.type == TransactionType.buy
              ? Icons.arrow_downward
              : transaction.type == TransactionType.sell
                  ? Icons.arrow_upward
                  : Icons.refresh,
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        CurrencyFormatter.format(transaction.amount, _currency),
        style: context.textTheme.titleSmall,
      ),
      subtitle: Text(
        '${_typeLabel()} · ${DateFormatter.format(transaction.date)}',
        style: context.textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        onPressed: () => _confirmDelete(context),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.loss),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      unawaited(context.read<AssetDetailCubit>().deleteTransaction(
            assetId,
            transaction.id,
          ),);
    }
  }
}
