import 'package:flutter/material.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/core/theme/app_text_styles.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';
import 'package:wealth_lens/domain/entities/asset.dart';

class AssetCard extends StatelessWidget {
  const AssetCard({
    required this.asset,
    required this.currency,
    required this.rate,
    this.onTap,
    super.key,
  });

  final Asset asset;
  final AppCurrency currency;
  final double rate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final profitLoss = asset.profitLoss;
    final isProfit = profitLoss >= 0;
    final cardColor =
        context.isDark ? AppColors.cardDark : AppColors.cardLight;

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'asset_${asset.id}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: context.isDark ? 0.3 : 0.06,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _CategoryIcon(asset: asset),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: context.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        asset.category.label,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(asset.currentValue, currency, rate: rate),
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    _ProfitLossBadge(
                      percent: asset.profitLossPercent,
                      isProfit: isProfit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: asset.category.accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        asset.category.icon,
        color: asset.category.accentColor,
        size: 22,
      ),
    );
  }
}

class _ProfitLossBadge extends StatelessWidget {
  const _ProfitLossBadge({
    required this.percent,
    required this.isProfit,
  });

  final double percent;
  final bool isProfit;

  @override
  Widget build(BuildContext context) {
    final color = isProfit ? AppColors.profit : AppColors.loss;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        CurrencyFormatter.formatPercent(percent),
        style: AppTextStyles.percentageBadge.copyWith(color: color),
      ),
    );
  }
}
