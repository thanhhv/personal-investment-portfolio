import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_lens/core/constants/asset_categories.dart';
import 'package:wealth_lens/core/di/injection.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/core/extensions/string_extensions.dart';
import 'package:wealth_lens/core/theme/app_colors.dart';
import 'package:wealth_lens/core/utils/date_formatter.dart';
import 'package:wealth_lens/domain/entities/asset.dart';
import 'package:wealth_lens/domain/entities/price_point.dart';
import 'package:wealth_lens/domain/entities/transaction.dart';
import 'package:wealth_lens/presentation/blocs/asset_form/asset_form_cubit.dart';
import 'package:wealth_lens/presentation/blocs/asset_form/asset_form_state.dart';

class AddEditAssetScreen extends StatelessWidget {
  const AddEditAssetScreen({this.asset, super.key});

  final Asset? asset;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AssetFormCubit>(),
      child: _AddEditAssetView(asset: asset),
    );
  }
}

class _AddEditAssetView extends StatefulWidget {
  const _AddEditAssetView({this.asset});

  final Asset? asset;

  bool get isEdit => asset != null;

  @override
  State<_AddEditAssetView> createState() => _AddEditAssetViewState();
}

class _AddEditAssetViewState extends State<_AddEditAssetView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _investedCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _ppuCtrl;
  late final TextEditingController _currentValueCtrl;
  final TextEditingController _tagCtrl = TextEditingController();

  AssetCategory? _category;
  DateTime _purchaseDate = DateTime.now();
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    final a = widget.asset;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');
    _investedCtrl = TextEditingController();
    _quantityCtrl = TextEditingController();
    _ppuCtrl = TextEditingController();
    _currentValueCtrl = TextEditingController();
    _category = a?.category;
    _tags = List<String>.from(a?.tags ?? []);

    if (a != null) {
      final buyTx = a.transactions
          .where((t) => t.type == TransactionType.buy)
          .lastOrNull;
      if (buyTx != null) {
        _investedCtrl.text = buyTx.amount.toString();
        _purchaseDate = buyTx.date;
        if (buyTx.quantity != null) {
          _quantityCtrl.text = buyTx.quantity!.toString();
        }
        if (buyTx.pricePerUnit != null) {
          _ppuCtrl.text = buyTx.pricePerUnit!.toString();
        }
      }
      if (a.priceHistory.isNotEmpty) {
        final sorted = [...a.priceHistory]
          ..sort((x, y) => x.date.compareTo(y.date));
        _currentValueCtrl.text = sorted.last.value.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _investedCtrl.dispose();
    _quantityCtrl.dispose();
    _ppuCtrl.dispose();
    _currentValueCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Asset _buildAsset() {
    final now = DateTime.now();
    final name = _nameCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    if (widget.isEdit) {
      return widget.asset!.copyWith(
        name: name,
        category: _category!,
        notes: notes.isEmpty ? null : notes,
        tags: _tags,
        updatedAt: now,
      );
    }

    final amount = double.parse(
      _investedCtrl.text.trim().replaceAll(',', '.'),
    );
    final qty = _quantityCtrl.text.trim().isEmpty
        ? null
        : double.tryParse(_quantityCtrl.text.trim().replaceAll(',', '.'));
    final ppu = _ppuCtrl.text.trim().isEmpty
        ? null
        : double.tryParse(_ppuCtrl.text.trim().replaceAll(',', '.'));
    final cv = _currentValueCtrl.text.trim().isEmpty
        ? null
        : double.tryParse(_currentValueCtrl.text.trim().replaceAll(',', '.'));

    return Asset(
      id: '',
      name: name,
      category: _category!,
      notes: notes.isEmpty ? null : notes,
      tags: _tags,
      transactions: [
        Transaction(
          id: '',
          type: TransactionType.buy,
          amount: amount,
          quantity: qty,
          pricePerUnit: ppu,
          date: _purchaseDate,
        ),
      ],
      priceHistory: cv != null
          ? [PricePoint(date: now, value: cv)]
          : const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty || _tags.contains(tag)) {
      _tagCtrl.clear();
      return;
    }
    setState(() => _tags.add(tag));
    _tagCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocListener<AssetFormCubit, AssetFormState>(
      listener: (context, state) {
        if (state.isSaved) context.pop();
        if (state.status == AssetFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l.somethingWentWrong),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? l.editAsset : l.addAsset),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _SectionLabel(l.basicInfo),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: '${l.assetName} *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              _CategoryDropdown(
                key: ValueKey(_category),
                initialValue: _category,
                onChanged: (v) => setState(() => _category = v),
              ),
              if (!widget.isEdit) ...[
                const SizedBox(height: 20),
                _SectionLabel(l.initialInvestment),
                const SizedBox(height: 8),
                _DatePickerRow(
                  label: '${l.purchaseDate} *',
                  date: _purchaseDate,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _investedCtrl,
                  decoration: InputDecoration(
                    labelText: '${l.totalInvestedAmount} *',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l.fieldRequired;
                    if (!v.trim().isValidPositiveNumber) {
                      return l.validationPositiveNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantityCtrl,
                  decoration: InputDecoration(labelText: l.quantityOptional),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    if (!v.trim().isValidPositiveNumber) {
                      return l.validationPositiveNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ppuCtrl,
                  decoration: InputDecoration(
                    labelText: l.pricePerUnitOptional,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    if (!v.trim().isValidPositiveNumber) {
                      return l.validationPositiveNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _currentValueCtrl,
                  decoration: InputDecoration(
                    labelText: l.currentValueOptional,
                    helperText: l.leaveBlankHint,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    if (!v.trim().isValidPositiveNumber) {
                      return l.validationPositiveNumber;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              _SectionLabel(l.additional),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(labelText: l.notesOptional),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _TagsInput(
                tags: _tags,
                controller: _tagCtrl,
                onAdd: _addTag,
                onRemove: (tag) => setState(() => _tags.remove(tag)),
              ),
              const SizedBox(height: 32),
              BlocBuilder<AssetFormCubit, AssetFormState>(
                builder: (context, state) {
                  return FilledButton(
                    onPressed: state.isSaving ? null : _onSave,
                    child: state.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l.save),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    final l = context.l10n;
    if (_formKey.currentState!.validate()) {
      if (_category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.pleaseSelectCategory)),
        );
        return;
      }
      context.read<AssetFormCubit>().save(_buildAsset());
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.titleMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final AssetCategory? initialValue;
  final ValueChanged<AssetCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DropdownButtonFormField<AssetCategory>(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: '${l.assetCategory} *'),
      items: AssetCategory.values.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Row(
            children: [
              Icon(c.icon, color: c.accentColor, size: 18),
              const SizedBox(width: 8),
              Text(c.label),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? l.fieldRequired : null,
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
            Expanded(
              child: Text(DateFormatter.format(date)),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TagsInput extends StatelessWidget {
  const _TagsInput({
    required this.tags,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> tags;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.tagsOptional, style: context.textTheme.bodySmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            ...tags.map(
              (tag) => InputChip(
                label: Text(tag),
                onDeleted: () => onRemove(tag),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        if (tags.isNotEmpty) const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: l.addTagHint,
                  isDense: true,
                ),
                onSubmitted: onAdd,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onAdd(controller.text),
            ),
          ],
        ),
      ],
    );
  }
}
