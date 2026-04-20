import 'package:flutter/material.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/core/theme/app_text_styles.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';

class PortfolioHeader extends StatelessWidget {
  const PortfolioHeader({
    required this.totalValue,
    required this.totalInvested,
    required this.profitLoss,
    required this.profitLossPercent,
    required this.currency,
    super.key,
  });

  final double totalValue;
  final double totalInvested;
  final double profitLoss;
  final double profitLossPercent;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    final isProfit = profitLoss >= 0;
    final theme = Theme.of(context);

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
            'Total Portfolio Value',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(totalValue, currency),
            style: AppTextStyles.portfolioTotal.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: 'Invested',
                value: CurrencyFormatter.formatCompact(totalInvested, currency),
              ),
              const SizedBox(width: 8),
              _ProfitLossChip(
                profitLoss: profitLoss,
                percent: profitLossPercent,
                currency: currency,
                isProfit: isProfit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProfitLossChip extends StatelessWidget {
  const _ProfitLossChip({
    required this.profitLoss,
    required this.percent,
    required this.currency,
    required this.isProfit,
  });

  final double profitLoss;
  final double percent;
  final AppCurrency currency;
  final bool isProfit;

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
          Icon(
            isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'P&L',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
              ),
              Text(
                '${CurrencyFormatter.formatCompact(profitLoss.abs(), currency)} '
                '(${CurrencyFormatter.formatPercent(percent)})',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
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
