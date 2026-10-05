import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/models.dart';
import '../../services/cloud_sync_service.dart';
import 'add_medication_screen.dart';

/// Lista "Meus Medicamentos" (§18).
class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  String _query = '';

  bool _matches(Medication m, Treatment? t) {
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty &&
        !m.name.toLowerCase().contains(q) &&
        !(m.activeIngredient?.toLowerCase().contains(q) ?? false)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final meds =
        ref.watch(medicationsProvider).valueOrNull ?? const <Medication>[];
    final treatments =
        ref.watch(activeTreatmentsProvider).valueOrNull ?? const <Treatment>[];
    final stocks = ref.watch(stocksProvider).valueOrNull ?? const <Stock>[];

    final tByMed = {for (final t in treatments) t.medicationId: t};
    final sByMed = {for (final s in stocks) s.medicationId: s};

    final isPartner = ref.watch(isPartnerModeProvider);
    final visible = meds.where((m) => _matches(m, tByMed[m.id])).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isPartner ? 'Métodos da Parceira' : 'Meus Métodos'),
      ),
      floatingActionButton:
          isPartner
              ? null
              : _GradientFab(onPressed: () => context.push('/add-medication')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Buscar medicamento, princípio ativo...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 18),
          if (meds.isEmpty)
            EmptyState(
              icon: Icons.medication_rounded,
              title:
                  isPartner
                      ? 'Nenhum medicamento registrado'
                      : 'Nenhum medicamento ainda',
              subtitle:
                  isPartner
                      ? 'Sua parceira ainda não cadastrou anticoncepcionais ou medicamentos.'
                      : 'Cadastre seus anticoncepcionais, vitaminas e remédios para receber lembretes.',
            )
          else if (visible.isEmpty)
            const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Nenhum resultado',
              subtitle: 'Tente outro termo de busca.',
            )
          else
            for (final m in visible) ...[
              _MedicationCard(
                medication: m,
                treatment: tByMed[m.id],
                stock: sByMed[m.id],
                isPartner: isPartner,
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _MedicationCard extends ConsumerWidget {
  const _MedicationCard({
    required this.medication,
    this.treatment,
    this.stock,
    required this.isPartner,
  });

  final Medication medication;
  final Treatment? treatment;
  final Stock? stock;
  final bool isPartner;

  void _showDetailsModal(BuildContext context, WidgetRef ref) {
    final rule = treatment?.rule;
    final times = rule?.times.map((t) => t.format()).join(', ') ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CategoryAvatar(category: medication.category, size: 54),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                medication.form.label,
                                if (medication.activeIngredient != null &&
                                    medication.activeIngredient!.isNotEmpty)
                                  medication.activeIngredient!,
                              ].join(' · '),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _Badge(lowStock: stock?.isLow ?? false),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Detalhes da Posologia
                  _buildDetailRow(
                    icon: Icons.repeat_rounded,
                    label: 'Esquema de Uso',
                    value: rule != null ? rule.summary : 'Conforme prescrição',
                  ),
                  if (times.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      icon: Icons.schedule_rounded,
                      label: 'Horários Programados',
                      value: times,
                      valueColor: AppColors.violet,
                    ),
                  ],
                  if (stock != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Estoque Atual',
                      value:
                          '${stock!.quantity.toInt()} unids restantes (Alerta em ${stock!.lowStockLimit.toInt()})',
                      valueColor:
                          stock!.isLow
                              ? AppColors.danger
                              : AppColors.textPrimary,
                    ),
                  ],

                  const SizedBox(height: 24),

                  if (isPartner) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.violet.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.violet.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.violet,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Modo Parceiro: você pode acompanhar as doses, mas somente a parceira pode alterar horários ou excluir medicamentos.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Ações da Mulher: Editar e Excluir
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.violet,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => AddMedicationScreen(
                                  initialMedication: medication,
                                  initialTreatment: treatment,
                                  initialStock: stock,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      label: const Text(
                        'Editar Medicamento & Horários',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (dlgCtx) => AlertDialog(
                                title: const Text('Excluir Medicamento?'),
                                content: Text(
                                  'Tem certeza que deseja excluir ${medication.displayName}? Todas as doses programadas e estoques deste remédio serão removidos permanentemente.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(dlgCtx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.danger,
                                    ),
                                    onPressed:
                                        () => Navigator.pop(dlgCtx, true),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                        );

                        if (confirmed == true && context.mounted) {
                          Navigator.pop(ctx);
                          await ref
                              .read(medicationRepositoryProvider)
                              .deleteFull(medication.id);
                          final db = ref.read(databaseProvider);
                          await CloudSyncService.instance.syncWomanToCloud(db);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${medication.displayName} foi excluído com sucesso.',
                                ),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      label: const Text(
                        'Excluir Medicamento',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule = treatment?.rule;
    final times = rule?.times.map((t) => t.format()).join(' · ') ?? '';

    return AppCard(
      onTap: () => _showDetailsModal(context, ref),
      child: Column(
        children: [
          Row(
            children: [
              CategoryAvatar(category: medication.category),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        medication.form.label,
                        if (rule != null) rule.summary,
                      ].join(' · '),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    if (times.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColors.violet,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            times,
                            style: const TextStyle(
                              color: AppColors.violet,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              _Badge(lowStock: stock?.isLow ?? false),
            ],
          ),
          if (stock != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GradientProgress(
                    value:
                        stock!.totalCapacity == null ||
                                stock!.totalCapacity == 0
                            ? 1
                            : stock!.quantity / stock!.totalCapacity!,
                    danger: stock!.isLow,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${stock!.quantity.toInt()}${stock!.totalCapacity != null ? ' / ${stock!.totalCapacity!.toInt()}' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.lowStock});
  final bool lowStock;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, text) =
        lowStock
            ? (AppColors.danger, AppColors.dangerSoft, 'Estoque baixo')
            : (AppColors.success, AppColors.successSoft, 'Ativo');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: 'add-med',
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Adicionar',
          style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter'),
        ),
      ),
    );
  }
}
