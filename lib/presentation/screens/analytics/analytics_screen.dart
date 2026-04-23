import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/core/theme/app_text_styles.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';
import 'package:wealth_lens/core/utils/date_formatter.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/presentation/blocs/analytics/analytics_cubit.dart';
import 'package:wealth_lens/presentation/blocs/analytics/analytics_state.dart';
import 'package:wealth_lens/presentation/blocs/currency/currency_cubit.dart';
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AnalyticsCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.analytics),
          centerTitle: false,
        ),
        body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == AnalyticsStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? context.l10n.somethingWentWrong,
                ),
              );
            }
            final data = state.data;
            if (data == null || data.rankedByPerformance.isEmpty) {
              return _EmptyState();
            }
            return _AnalyticsBody(data: data);
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 80,
              color: context.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.noDataYet, style: context.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              context.l10n.addAssetsToSeeAnalytics,
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

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.data});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final isProfit = data.totalProfitLoss >= 0;
    final plColor = isProfit ? AppColors.profit : AppColors.loss;

    return ListView(
      children: [
        _SummaryCard(data: data, plColor: plColor, isProfit: isProfit),
        if (data.timeline.length >= 2)
          _PerformanceChart(data: data),
        if (data.rankedByPerformance.length >= 2) ...[
          _RankingSection(
            title: context.l10n.bestPerforming,
            assets: data.rankedByPerformance.take(3).toList(),
            positive: true,
          ),
          _RankingSection(
            title: context.l10n.worstPerforming,
            assets: data.rankedByPerformance.reversed.take(3).toList(),
            positive: false,
          ),
        ],
        _CategoryBreakdownCard(
          breakdown: data.categoryBreakdown,
          totalValue: data.totalValue,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.data,
    required this.plColor,
    required this.isProfit,
  });

  final AnalyticsData data;
  final Color plColor;
  final bool isProfit;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final currency = context.read<CurrencyCubit>().state;
    final rate = context.read<ExchangeRateCubit>().state;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.portfolioPerformance,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(data.totalValue, currency, rate: rate),
            style: AppTextStyles.portfolioTotal.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryChip(
                label: l.invested,
                value: CurrencyFormatter.formatCompact(
                  data.totalInvested,
                  currency,
                  rate: rate,
                ),
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: isProfit ? l.gain : l.loss,
                value:
                    '${CurrencyFormatter.formatCompact(data.totalProfitLoss.abs(), currency, rate: rate)}'
                    ' (${CurrencyFormatter.formatPercent(data.totalProfitLossPercent)})',
                icon: isProfit
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
          ],
          Column(
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
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance Area Chart
// ─────────────────────────────────────────────────────────────────────────────

class _PerformanceChart extends StatelessWidget {
  const _PerformanceChart({required this.data});

  final AnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final currency = context.read<CurrencyCubit>().state;
    final rate = context.read<ExchangeRateCubit>().state;
    final timeline = data.timeline;
    final investedSpots = timeline.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.totalInvested);
    }).toList();
    final valueSpots = timeline.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.currentValue);
    }).toList();

    final allValues = [
      ...investedSpots.map((s) => s.y),
      ...valueSpots.map((s) => s.y),
    ];
    final minY = allValues.reduce((a, b) => a < b ? a : b);
    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY).abs() * 0.15;

    return _ChartCard(
      title: l.investedVsCurrentValue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LegendDot(color: AppColors.primary, label: l.value),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.neutral, label: l.invested),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY - padding,
                maxY: maxY + padding,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: timeline.length <= 12,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= timeline.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormatter.formatShort(timeline[idx].date),
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) {
                      final idx = s.x.toInt();
                      final point =
                          idx < timeline.length ? timeline[idx] : null;
                      return LineTooltipItem(
                        point != null
                            ? CurrencyFormatter.format(s.y, currency, rate: rate)
                            : '',
                        context.textTheme.labelSmall!
                            .copyWith(color: Colors.white),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: investedSpots,
                    isCurved: true,
                    color: AppColors.neutral,
                    barWidth: 1.5,
                    dashArray: [6, 3],
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: valueSpots,
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: context.textTheme.labelSmall),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ranking Section
// ─────────────────────────────────────────────────────────────────────────────

class _RankingSection extends StatelessWidget {
  const _RankingSection({
    required this.title,
    required this.assets,
    required this.positive,
  });

  final String title;
  final List<Asset> assets;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyCubit>().state;
    final rate = context.read<ExchangeRateCubit>().state;

    return _ChartCard(
      title: title,
      child: Column(
        children: assets.map((asset) {
          final isProfit = asset.profitLoss >= 0;
          final color = isProfit ? AppColors.profit : AppColors.loss;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: asset.category.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    asset.category.icon,
                    color: asset.category.accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: context.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        CurrencyFormatter.format(asset.currentValue, currency, rate: rate),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    CurrencyFormatter.formatPercent(asset.profitLossPercent),
                    style: AppTextStyles.percentageBadge.copyWith(color: color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Breakdown Table
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({
    required this.breakdown,
    required this.totalValue,
  });

  final List<CategoryBreakdown> breakdown;
  final double totalValue;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return _ChartCard(
      title: l.categoryBreakdown,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    l.assetCategory,
                    style: context.textTheme.labelSmall?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    l.value,
                    style: context.textTheme.labelSmall?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l.allocation,
                    style: context.textTheme.labelSmall?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l.pAndL,
                    style: context.textTheme.labelSmall?.copyWith(
                      color:
                          context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...breakdown.map(
            (item) => _CategoryRow(item: item),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.item});

  final CategoryBreakdown item;

  @override
  Widget build(BuildContext context) {
    final currency = context.read<CurrencyCubit>().state;
    final rate = context.read<ExchangeRateCubit>().state;
    final isProfit = item.profitLoss >= 0;
    final plColor = isProfit ? AppColors.profit : AppColors.loss;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: item.category.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.category.icon,
                    color: item.category.accentColor,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.category.label,
                    style: context.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              CurrencyFormatter.formatCompact(item.totalValue, currency, rate: rate),
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.allocation.toStringAsFixed(1)}%',
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              CurrencyFormatter.formatPercent(item.profitLossPercent),
              style: context.textTheme.bodySmall?.copyWith(color: plColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared card wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDark ? 0.3 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.headlineSmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
