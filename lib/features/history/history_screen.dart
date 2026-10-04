import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/enums.dart';
import '../../models/models.dart';

/// Tela de Histórico de Doses e Adesão Descritiva (§9 e §10).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _selectedFilter = 0; // 0: Todos, 1: Tomados, 2: Atrasados/Outros

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recentRecordsProvider);
    final medsAsync = ref.watch(medicationsProvider);
    final treatmentsAsync = ref.watch(activeTreatmentsProvider);

    final meds = medsAsync.valueOrNull ?? const [];
    final treatments = treatmentsAsync.valueOrNull ?? const [];
    final records = recordsAsync.valueOrNull ?? const [];

    final medById = {for (final m in meds) m.id: m};
    final treatById = {for (final t in treatments) t.id: t};

    // Filtros
    final filtered = records.where((r) {
      if (_selectedFilter == 1) return r.status == DoseStatus.taken;
      if (_selectedFilter == 2) {
        return r.status == DoseStatus.skipped ||
            r.status == DoseStatus.missed ||
            r.status == DoseStatus.snoozed;
      }
      return true;
    }).toList();

    // Cálculo descritivo de adesão (§10)
    final total = records.length;
    final takenCount =
        records.where((r) => r.status == DoseStatus.taken).length;
    final adherencePercent = total > 0 ? ((takenCount / total) * 100).round() : 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          // Card de Adesão Descritiva (§10)
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Adesão ao tratamento',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$adherencePercent%',
                          style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GradientProgress(
                  value: total > 0 ? takenCount / total : 1.0,
                  height: 10,
                ),
                const SizedBox(height: 10),
                Text(
                  total == 0
                      ? 'Nenhuma dose registrada ainda.'
                      : '$takenCount tomadas de $total registradas no histórico.',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Filtro de abas
          Row(
            children: [
              _buildFilterChip(0, 'Todos'),
              const SizedBox(width: 8),
              _buildFilterChip(1, 'Tomados'),
              const SizedBox(width: 8),
              _buildFilterChip(2, 'Atrasados / Pulados'),
            ],
          ),
          const SizedBox(height: 18),

          if (recordsAsync.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.history_rounded,
              title: 'Nenhum registro encontrado',
              subtitle: 'As doses tomadas ou puladas aparecerão aqui.',
            )
          else ...[
            for (final record in filtered) ...[
              _HistoryTile(
                record: record,
                medication: medById[treatById[record.treatmentId]?.medicationId],
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      onSelected: (_) => setState(() => _selectedFilter = index),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record, this.medication});

  final DoseRecord record;
  final Medication? medication;

  @override
  Widget build(BuildContext context) {
    final medName = medication?.displayName ?? 'Medicamento';
    final dateStr = DateFormat('dd/MM - HH:mm').format(record.scheduledAt);
    final takenAtStr = record.takenAt != null
        ? 'Tomado às ${DateFormat.Hm().format(record.takenAt!)}'
        : null;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CategoryAvatar(
            category: medication?.category ?? MedicationCategory.other,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  takenAtStr ?? dateStr,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          StatusChip(status: record.status),
        ],
      ),
    );
  }
}
