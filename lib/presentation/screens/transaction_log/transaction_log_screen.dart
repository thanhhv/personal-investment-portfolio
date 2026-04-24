import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';
import 'package:wealth_lens/core/utils/date_formatter.dart';
import 'package:wealth_lens/domain/entities/transaction.dart';
import 'package:wealth_lens/presentation/blocs/asset_detail/asset_detail_cubit.dart';
import 'package:wealth_lens/presentation/blocs/asset_detail/asset_detail_state.dart';
import 'package:wealth_lens/presentation/blocs/balance_visibility/balance_visibility_cubit.dart';
import 'package:wealth_lens/presentation/blocs/currency/currency_cubit.dart';
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';
import 'package:wealth_lens/presentation/widgets/add_transaction_bottom_sheet.dart';

class TransactionLogScreen extends StatelessWidget {
  const TransactionLogScreen({required this.assetId, super.key});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AssetDetailCubit>()..load(assetId),
      child: _TransactionLogView(assetId: assetId),
    );
  }
}

class _TransactionLogView extends StatelessWidget {
  const _TransactionLogView({required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.transactions)),
      body: BlocBuilder<AssetDetailCubit, AssetDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.asset == null) {
            return Center(child: Text(l.assetNotFound));
          }

          final transactions = [...state.asset!.transactions]
            ..sort((a, b) => b.date.compareTo(a.date));

          if (transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.noTransactionsYet,
                      style: context.textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            );
          }

          final currency = context.read<CurrencyCubit>().state;
          final rate = context.read<ExchangeRateCubit>().state;
          final isHidden = !context.watch<BalanceVisibilityCubit>().state;
          return ListView.separated(
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _TransactionTile(
                assetId: assetId,
                transaction: transactions[index],
                currency: currency,
                rate: rate,
                isHidden: isHidden,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final asset = context.read<AssetDetailCubit>().state.asset;
          if (asset == null) return;
          AddTransactionBottomSheet.show(
            context,
            asset: asset,
            onAdded: () => context.read<AssetDetailCubit>().load(assetId),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

const _kMasked = '•••';

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.assetId,
    required this.transaction,
    required this.currency,
    required this.rate,
    required this.isHidden,
  });

  final String assetId;
  final Transaction transaction;
  final AppCurrency currency;
  final double rate;
  final bool isHidden;

  Color _typeColor() => switch (transaction.type) {
        TransactionType.buy => AppColors.secondary,
        TransactionType.sell => AppColors.loss,
        TransactionType.update => AppColors.neutral,
      };

  IconData _typeIcon() => switch (transaction.type) {
        TransactionType.buy => Icons.arrow_downward,
        TransactionType.sell => Icons.arrow_upward,
        TransactionType.update => Icons.refresh,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = _typeColor();
    final typeLabel = switch (transaction.type) {
      TransactionType.buy => l.transactionBuy,
      TransactionType.sell => l.transactionSell,
      TransactionType.update => l.transactionUpdate,
    };

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_typeIcon(), color: color, size: 18),
      ),
      title: Text(
        isHidden
            ? _kMasked
            : CurrencyFormatter.format(transaction.amount, currency,
                rate: rate,),
        style: context.textTheme.titleSmall,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$typeLabel · ${DateFormatter.format(transaction.date)}',
            style: context.textTheme.bodySmall,
          ),
          if (transaction.quantity != null)
            Text(
              'Qty: ${transaction.quantity}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          if (transaction.note != null && transaction.note!.isNotEmpty)
            Text(
              transaction.note!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      isThreeLine: transaction.quantity != null || transaction.note != null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18),
        onPressed: () => _confirmDelete(context),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteTransaction),
        content: Text(l.cannotBeUndone),
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
    );
    if ((confirmed ?? false) && context.mounted) {
      unawaited(context
          .read<AssetDetailCubit>()
          .deleteTransaction(assetId, transaction.id),);
    }
  }
}
