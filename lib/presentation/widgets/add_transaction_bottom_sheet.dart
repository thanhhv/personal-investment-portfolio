import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/extensions/string_extensions.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';
import 'package:wealth_lens/core/utils/date_formatter.dart';
import 'package:wealth_lens/core/utils/decimal_input_formatter.dart';
import 'package:wealth_lens/core/utils/thousand_separator_formatter.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/entities/price_point.dart';
import 'package:wealth_lens/domain/entities/transaction.dart';
import 'package:wealth_lens/domain/usecases/add_transaction_usecase.dart';
import 'package:wealth_lens/domain/usecases/save_asset_usecase.dart';
import 'package:wealth_lens/presentation/blocs/currency/currency_cubit.dart';
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';

class AddTransactionBottomSheet extends StatefulWidget {
  const AddTransactionBottomSheet({
    required this.asset,
    required this.onAdded,
    required this.currency,
    required this.rate,
    super.key,
  });

  final Asset asset;
  final VoidCallback onAdded;
  final AppCurrency currency;
  final double rate;

  static Future<void> show(
    BuildContext context, {
    required Asset asset,
    required VoidCallback onAdded,
  }) {
    final currency = context.read<CurrencyCubit>().state;
    final rate = context.read<ExchangeRateCubit>().state;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddTransactionBottomSheet(
        asset: asset,
        onAdded: onAdded,
        currency: currency,
        rate: rate,
      ),
    );
  }

  @override
  State<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState
    extends State<AddTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  TransactionType _type = TransactionType.buy;
  final _ppuCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _ppuCtrl.addListener(() => setState(() {}));
    _quantityCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ppuCtrl.dispose();
    _quantityCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double? get _calculatedTotal {
    final ppu = double.tryParse(_ppuCtrl.text.replaceAll(',', ''));
    final qty = double.tryParse(_quantityCtrl.text);
    if (ppu != null && qty != null && ppu > 0 && qty > 0) return ppu * qty;
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final ppuRaw = double.parse(_ppuCtrl.text.replaceAll(',', ''));
    final ppuStored = widget.currency == AppCurrency.vnd
        ? ppuRaw / widget.rate
        : ppuRaw;
    final qty = double.parse(_quantityCtrl.text);
    final total = ppuStored * qty;

    final tx = Transaction(
      id: const Uuid().v4(),
      type: _type,
      amount: total,
      quantity: qty,
      pricePerUnit: ppuStored,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      date: _date,
    );

    if (_type == TransactionType.sell) {
      final newPricePoint = PricePoint(
        date: _date,
        value: (widget.asset.currentValue - total).clamp(0.0, double.infinity),
      );
      final updatedAsset = widget.asset.copyWith(
        transactions: [...widget.asset.transactions, tx],
        priceHistory: [...widget.asset.priceHistory, newPricePoint],
      );
      final result = await getIt<SaveAssetUseCase>()(updatedAsset);
      result.fold(
        (failure) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (_) {
          if (!mounted) return;
          Navigator.of(context).pop();
          widget.onAdded();
        },
      );
    } else if (widget.asset.priceHistory.isNotEmpty) {
      // Asset has tracked price history — append a new price point so currentValue
      // reflects the newly added position.
      final newPricePoint = PricePoint(
        date: _date,
        value: widget.asset.currentValue + total,
      );
      final updatedAsset = widget.asset.copyWith(
        transactions: [...widget.asset.transactions, tx],
        priceHistory: [...widget.asset.priceHistory, newPricePoint],
      );
      final result = await getIt<SaveAssetUseCase>()(updatedAsset);
      result.fold(
        (failure) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (_) {
          if (!mounted) return;
          Navigator.of(context).pop();
          widget.onAdded();
        },
      );
    } else {
      final result = await getIt<AddTransactionUseCase>()(widget.asset.id, tx);
      result.fold(
        (failure) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (_) {
          if (!mounted) return;
          Navigator.of(context).pop();
          widget.onAdded();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(l.addTransaction, style: context.textTheme.headlineSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                  value: TransactionType.buy,
                  label: Text(l.transactionBuy),
                ),
                ButtonSegment(
                  value: TransactionType.sell,
                  label: Text(l.transactionSell),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 12),
            _DatePickerRow(
              label: l.dateLabel,
              date: _date,
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ppuCtrl,
              decoration: InputDecoration(
                labelText: l.pricePerUnit,
                prefixText:
                    '${widget.currency == AppCurrency.vnd ? '₫' : r'$'} ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [ThousandSeparatorFormatter()],
              autofocus: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.fieldRequired;
                if (!v.trim().replaceAll(',', '').isValidPositiveNumber) {
                  return l.validationPositiveNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityCtrl,
              decoration: InputDecoration(labelText: l.quantityRequired),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalInputFormatter()],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.fieldRequired;
                if (!v.trim().isValidPositiveNumber) {
                  return l.validationPositiveNumber;
                }
                if (_type == TransactionType.sell) {
                  final rawTotal = _calculatedTotal;
                  if (rawTotal != null) {
                    final storedTotal = widget.currency == AppCurrency.vnd
                        ? rawTotal / widget.rate
                        : rawTotal;
                    if (storedTotal > widget.asset.currentValue) {
                      return l.sellExceedsValue;
                    }
                  }
                }
                return null;
              },
            ),
            if (_calculatedTotal != null) ...[
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l.totalInvestedCalculated,
                  filled: true,
                ),
                child: Text(
                  _calculatedTotal!.toStringAsFixed(2),
                  style: context.textTheme.bodyLarge,
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteCtrl,
              decoration: InputDecoration(labelText: l.noteOptional),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l.addTransaction),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Expanded(child: Text(DateFormatter.format(date))),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
