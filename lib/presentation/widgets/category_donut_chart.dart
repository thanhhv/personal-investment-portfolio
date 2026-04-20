import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wealth_lens/core/constants/asset_categories.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/core/theme/app_text_styles.dart';
import 'package:wealth_lens/domain/entities/asset.dart';

class CategoryDonutChart extends StatelessWidget {
  const CategoryDonutChart({required this.assets, super.key});

  final List<Asset> assets;

  Map<AssetCategory, double> get _categoryValues {
    final map = <AssetCategory, double>{};
    for (final asset in assets) {
      map.update(
        asset.category,
        (v) => v + asset.currentValue,
        ifAbsent: () => asset.currentValue,
      );
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final values = _categoryValues;
    final total = values.values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final sections = values.entries.map((e) {
      final percent = e.value / total * 100;
      return PieChartSectionData(
        value: e.value,
        color: e.key.accentColor,
        radius: 44,
        title: percent >= 8 ? '${percent.toStringAsFixed(0)}%' : '',
        titleStyle: AppTextStyles.percentageBadge.copyWith(
          color: Colors.white,
          fontSize: 11,
        ),
      );
    }).toList();

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
          Text(context.l10n.breakdown, style: context.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 48,
                    sectionsSpace: 2,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: values.entries
                      .map(
                        (e) => _LegendRow(
                          category: e.key,
                          value: e.value,
                          total: total,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.category,
    required this.value,
    required this.total,
  });

  final AssetCategory category;
  final double value;
  final double total;

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? value / total * 100 : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: category.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              category.label,
              style: context.textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${percent.toStringAsFixed(1)}%',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
