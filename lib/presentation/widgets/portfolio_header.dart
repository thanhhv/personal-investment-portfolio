import 'package:flutter/material.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
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
    required this.rate,
    super.key,
  });

  final double totalValue;
  final double totalInvested;
  final double profitLoss;
  final double profitLossPercent;
  final AppCurrency currency;
  final double rate;

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
            context.l10n.totalPortfolioValue,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: totalValue),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, _) => Text(
              CurrencyFormatter.format(value, currency, rate: rate),
              style: AppTextStyles.portfolioTotal.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: context.l10n.invested,
                value: CurrencyFormatter.formatCompact(
                  totalInvested,
                  currency,
                  rate: rate,
                ),
              ),
              const SizedBox(width: 8),
              _ProfitLossChip(
                profitLoss: profitLoss,
                percent: profitLossPercent,
                currency: currency,
                rate: rate,
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
    required this.rate,
    required this.isProfit,
  });

  final double profitLoss;
  final double percent;
  final AppCurrency currency;
  final double rate;
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
                context.l10n.pAndL,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
              ),
              Text(
                '${CurrencyFormatter.formatCompact(profitLoss.abs(), currency, rate: rate)} '
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
