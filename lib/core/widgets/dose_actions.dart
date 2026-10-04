import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../models/enums.dart';
import '../providers.dart';
import 'app_widgets.dart';

/// Ações de uma dose: Tomei / Adiar / Pular / Desfazer.
Future<void> showDoseActions(BuildContext context, WidgetRef ref, DoseItem item) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) =>
        _DoseActionsSheet(item: item, parentRef: ref, parentContext: context),
  );
}

/// Registra "Tomei" com feedback visual.
Future<void> takeDose(BuildContext context, WidgetRef ref, DoseItem item) async {
  await ref
      .read(doseServiceProvider)
      .markTaken(item.occurrence, medicationId: item.medication.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('${item.medication.displayName} registrado como tomado ✓'),
      action: SnackBarAction(
        label: 'Desfazer',
        textColor: AppColors.teal,
        onPressed: () => ref
            .read(doseServiceProvider)
            .undo(item.occurrence, medicationId: item.medication.id),
      ),
    ));
}

class _DoseActionsSheet extends StatelessWidget {
  const _DoseActionsSheet({
    required this.item,
    required this.parentRef,
    required this.parentContext,
  });

  final DoseItem item;
  final WidgetRef parentRef;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final service = parentRef.read(doseServiceProvider);
    final time = TimeOfDay.fromDateTime(item.occurrence.scheduledAt).format(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: CategoryAvatar(category: item.medication.category, size: 64)),
            const SizedBox(height: 12),
            Text(time,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall),
            Text(item.medication.displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(item.quantityLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Center(child: StatusChip(status: item.status, late: item.isLate)),
            const SizedBox(height: 20),
            if (item.status != DoseStatus.taken) ...[
              GradientButton(
                label: 'Tomei',
                icon: Icons.check_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  takeDose(parentContext, parentRef, item);
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: _outlined(AppColors.blue),
                      icon: const Icon(Icons.snooze_rounded),
                      label: const Text('Adiar 10 min'),
                      onPressed: () {
                        service.snooze(item.occurrence, const Duration(minutes: 10));
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: _outlined(AppColors.danger),
                      icon: const Icon(Icons.redo_rounded),
                      label: const Text('Pular'),
                      onPressed: () {
                        service.markSkipped(item.occurrence);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
            if (item.record != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.undo_rounded),
                label: const Text('Desfazer registro'),
                onPressed: () {
                  service.undo(item.occurrence, medicationId: item.medication.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  ButtonStyle _outlined(Color c) => OutlinedButton.styleFrom(
        foregroundColor: c,
        side: BorderSide(color: c.withValues(alpha: 0.5), width: 1.5),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter'),
      );
}
