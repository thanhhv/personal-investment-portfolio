import 'package:flutter/material.dart';
import 'package:wealth_lens/core/extensions/context_extensions.dart';
import 'package:wealth_lens/domain/usecases/import_portfolio_usecase.dart';

enum ImportAction { merge, replaceAll }

class ImportConfirmDialog extends StatelessWidget {
  const ImportConfirmDialog({
    required this.preview,
    super.key,
  });

  final ImportPreview preview;

  static Future<ImportAction?> show(
    BuildContext context,
    ImportPreview preview,
  ) =>
      showDialog<ImportAction>(
        context: context,
        builder: (_) => ImportConfirmDialog(preview: preview),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Portfolio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Found ${preview.assets.length} '
            'asset${preview.assets.length == 1 ? '' : 's'}:',
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          if (preview.newCount > 0)
            _StatRow(
              icon: Icons.add_circle_outline,
              color: Colors.green,
              label: '${preview.newCount} new',
            ),
          if (preview.updateCount > 0)
            _StatRow(
              icon: Icons.update,
              color: Colors.orange,
              label: '${preview.updateCount} will be updated',
            ),
          const SizedBox(height: 16),
          Text(
            'How would you like to import?',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ImportAction.merge),
          child: const Text('Merge'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(ImportAction.replaceAll),
          child: const Text('Replace All'),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}
