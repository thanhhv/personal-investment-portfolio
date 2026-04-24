import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/extensions/string_extensions.dart';
import 'package:wealth_lens/core/utils/currency_formatter.dart';
import 'package:wealth_lens/core/utils/date_formatter.dart';
import 'package:wealth_lens/core/utils/thousand_separator_formatter.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/entities/price_point.dart';
import 'package:wealth_lens/domain/usecases/save_asset_usecase.dart';
import 'package:wealth_lens/presentation/blocs/currency/currency_cubit.dart';
import 'package:wealth_lens/presentation/blocs/exchange_rate/exchange_rate_cubit.dart';

class UpdatePriceBottomSheet extends StatefulWidget {
  const UpdatePriceBottomSheet({
    required this.asset,
    required this.onUpdated,
    required this.currency,
    required this.rate,
    super.key,
  });

  final Asset asset;
  final VoidCallback onUpdated;
  final AppCurrency currency;
  final double rate;

  static Future<void> show(
    BuildContext context, {
    required Asset asset,
    required VoidCallback onUpdated,
  }) {
    final currency = context.read<CurrencyCubit>().state;
    final rate = context.read<ExchangeRateCubit>().state;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => UpdatePriceBottomSheet(
        asset: asset,
        onUpdated: onUpdated,
        currency: currency,
        rate: rate,
      ),
    );
  }

  @override
  State<UpdatePriceBottomSheet> createState() =>
      _UpdatePriceBottomSheetState();
}

class _UpdatePriceBottomSheetState extends State<UpdatePriceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ppuCtrl;
  late final TextEditingController _totalValueCtrl;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _ppuCtrl = TextEditingController();
    _totalValueCtrl = TextEditingController();
    _ppuCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ppuCtrl.dispose();
    _totalValueCtrl.dispose();
    super.dispose();
  }

  String get _currencyPrefix =>
      widget.currency == AppCurrency.vnd ? '₫' : r'$';

  double? get _calculatedNewValue {
    if (!widget.asset.hasQuantityTracking) return null;
    final ppu = double.tryParse(_ppuCtrl.text.replaceAll(',', ''));
    if (ppu == null || ppu <= 0) return null;
    final ppuStored =
        widget.currency == AppCurrency.vnd ? ppu / widget.rate : ppu;
    return ppuStored * widget.asset.totalQuantity;
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

    final double newValue;
    if (widget.asset.hasQuantityTracking) {
      final ppuRaw = double.parse(_ppuCtrl.text.replaceAll(',', ''));
      final ppuStored =
          widget.currency == AppCurrency.vnd ? ppuRaw / widget.rate : ppuRaw;
      newValue = ppuStored * widget.asset.totalQuantity;
    } else {
      final valueRaw =
          double.parse(_totalValueCtrl.text.replaceAll(',', ''));
      newValue =
          widget.currency == AppCurrency.vnd ? valueRaw / widget.rate : valueRaw;
    }

    final newPoint = PricePoint(date: _date, value: newValue);
    final updatedAsset = widget.asset.copyWith(
      priceHistory: [...widget.asset.priceHistory, newPoint],
      updatedAt: DateTime.now(),
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
        widget.onUpdated();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final hasQty = widget.asset.hasQuantityTracking;

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
                Text(l.updatePrice, style: context.textTheme.headlineSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DatePickerRow(label: l.dateLabel, date: _date, onTap: _pickDate),
            const SizedBox(height: 12),
            if (hasQty) ...[
              TextFormField(
                controller: _ppuCtrl,
                decoration: InputDecoration(
                  labelText: l.currentPricePerUnitRequired,
                  prefixText: '$_currencyPrefix ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              InputDecorator(
                decoration: InputDecoration(labelText: l.totalQuantityLabel),
                child: Text(
                  widget.asset.totalQuantity.toStringAsFixed(
                    widget.asset.totalQuantity % 1 == 0 ? 0 : 4,
                  ),
                  style: context.textTheme.bodyLarge,
                ),
              ),
              if (_calculatedNewValue != null) ...[
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l.newCurrentValue,
                    filled: true,
                  ),
                  child: Text(
                    CurrencyFormatter.format(
                      _calculatedNewValue!,
                      widget.currency,
                      rate: widget.rate,
                    ),
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              ],
            ] else ...[
              TextFormField(
                controller: _totalValueCtrl,
                decoration: InputDecoration(
                  labelText: l.newCurrentValue,
                  prefixText: '$_currencyPrefix ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
            ],
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
                  : Text(l.updatePrice),
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
