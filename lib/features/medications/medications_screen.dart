import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/models.dart';



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
        !(m.activeIngredient ?? '').toLowerCase().contains(q)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final meds = ref.watch(medicationsProvider).valueOrNull ?? const [];
    final treatments = ref.watch(activeTreatmentsProvider).valueOrNull ?? const [];
    final stocks = ref.watch(stocksProvider).valueOrNull ?? const [];
    final tByMed = {for (final t in treatments) t.medicationId: t};
    final sByMed = {for (final s in stocks) s.medicationId: s};
    final isPartner = ref.watch(isPartnerModeProvider);
    final visible = meds.where((m) => _matches(m, tByMed[m.id])).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isPartner ? 'Métodos Cadastrados' : 'Meus Métodos'),
      ),
      floatingActionButton: isPartner
          ? null
          : _GradientFab(
              onPressed: () => context.push('/add-medication'),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Buscar método...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 18),
          if (visible.isEmpty)
            EmptyState(
              icon: Icons.medication_outlined,
              title: 'Nenhum método cadastrado',
              subtitle: isPartner
                  ? 'Aguardando sua parceira cadastrar métodos.'
                  : 'Toque em + para adicionar.',
            )
          else
            for (final m in visible) ...[
              _MedicationCard(medication: m, treatment: tByMed[m.id], stock: sByMed[m.id]),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({required this.medication, this.treatment, this.stock});

  final Medication medication;
  final Treatment? treatment;
  final Stock? stock;

  @override
  Widget build(BuildContext context) {
    final rule = treatment?.rule;
    final times = rule?.times.map((t) => t.format()).join(' · ') ?? '';

    return AppCard(
      onTap: () {},
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
                    Text(medication.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      [medication.form.label, if (rule != null) rule.summary].join(' · '),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    if (times.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.schedule_rounded, size: 14, color: AppColors.violet),
                        const SizedBox(width: 4),
                        Text(times,
                            style: const TextStyle(
                                color: AppColors.violet, fontWeight: FontWeight.w600, fontSize: 13)),
                      ]),
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
                    value: stock!.totalCapacity == null || stock!.totalCapacity == 0
                        ? 1
                        : stock!.quantity / stock!.totalCapacity!,
                    danger: stock!.isLow,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${stock!.quantity.toInt()}${stock!.totalCapacity != null ? ' / ${stock!.totalCapacity!.toInt()}' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
    final (fg, bg, text) = lowStock
        ? (AppColors.danger, AppColors.dangerSoft, 'Estoque baixo')
        : (AppColors.success, AppColors.successSoft, 'Ativo');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11.5)),
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
              offset: const Offset(0, 8)),
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
        label: const Text('Adicionar',
            style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Inter')),
      ),
    );
  }
}
