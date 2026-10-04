import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dose_actions.dart';
import '../../models/enums.dart';
import '../../models/models.dart';
import '../../services/schedule_engine/schedule_engine.dart';

/// Tela "Hoje": responde "o que preciso fazer agora?" (§16 e §54).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doses = ref.watch(todayDosesProvider);

    return Scaffold(
      body: SafeArea(
        child: doses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro ao carregar: $e')),
          data: (items) => _HomeContent(items: items),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.items});
  final List<DoseItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = items.where((i) => !i.isDone).toList();
    final next = pending.isEmpty ? null : pending.first;
    final done = items.where((i) => i.status == DoseStatus.taken).length;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverList.list(
            children: [
              const _Header(),
              const SizedBox(height: 20),
              next == null
                  ? _AllDoneCard(hasDoses: items.isNotEmpty)
                  : _NextDoseCard(item: next),
              const SizedBox(height: 24),
              _DayProgress(done: done, total: items.length),
              const SizedBox(height: 24),
              const SectionTitle('Hoje'),
            ],
          ),
        ),
        if (items.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.event_available_rounded,
              title: 'Nenhuma dose programada para hoje',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _DoseTile(item: items[i]),
            ),
          ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _CycleCard(),
              SizedBox(height: 16),
              _QuickStats(),
            ]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isPartner = ref.watch(isPartnerModeProvider);
    final greeting =
        now.hour < 12
            ? 'Bom dia'
            : now.hour < 18
            ? 'Boa tarde'
            : 'Boa noite';
    final date = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const VelixLogo(size: 18),
                  if (isPartner) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.violet.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.violet.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_rounded, size: 12, color: AppColors.violet),
                          SizedBox(width: 4),
                          Text(
                            'Parceiro (Visualização)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.violet,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '$greeting 👋',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 2),
              Text(
                date[0].toUpperCase() + date.substring(1),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        _RoundIcon(icon: Icons.notifications_none_rounded, onTap: () {}),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// Card em destaque com a próxima dose.
class _NextDoseCard extends ConsumerWidget {
  const _NextDoseCard({required this.item});
  final DoseItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = DateFormat.Hm().format(item.occurrence.scheduledAt);
    final diff = item.occurrence.scheduledAt.difference(DateTime.now());
    final when =
        item.isLate
            ? 'Atrasada há ${_fmt(-diff)}'
            : diff.isNegative
            ? 'Agora'
            : 'Em ${_fmt(diff)}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'PRÓXIMA DOSE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      when,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      CategoryStyle.of(item.medication.category).icon,
                      color: CategoryStyle.of(item.medication.category).color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.medication.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          item.quantityLabel,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (ref.watch(isPartnerModeProvider))
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Modo Parceiro · Apenas Visualização',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.violet,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () => takeDose(context, ref, item),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('TOMEI'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.white54,
                            width: 1.5,
                          ),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () => showDoseActions(context, ref, item),
                        child: const Text('Adiar'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(Duration d) {
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}min';
    return '${d.inMinutes} min';
  }
}

class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard({required this.hasDoses});
  final bool hasDoses;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.celebration_rounded,
            color: AppColors.success,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              hasDoses
                  ? 'Tudo certo por hoje!\nTodas as doses foram registradas.'
                  : 'Sem doses para hoje.',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayProgress extends StatelessWidget {
  const _DayProgress({required this.done, required this.total});
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: total == 0 ? 0 : done / total,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.surfaceSoft,
                  valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                ),
                Text(
                  '$done/$total',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progresso do dia',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  total == 0
                      ? 'Nenhuma dose programada'
                      : '$done de $total doses registradas como tomadas',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseTile extends ConsumerWidget {
  const _DoseTile({required this.item});
  final DoseItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = DateFormat.Hm().format(item.occurrence.scheduledAt);
    final isPartner = ref.watch(isPartnerModeProvider);
    final taken = item.status == DoseStatus.taken;

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: isPartner
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Modo Parceiro: apenas visualização.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          : () => showDoseActions(context, ref, item),
      child: Row(
        children: [
          SizedBox(
            width: 54,
            child: Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: taken ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
          ),
          CategoryAvatar(category: item.medication.category, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medication.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: taken ? TextDecoration.lineThrough : null,
                    color: taken ? AppColors.textMuted : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                StatusChip(status: item.status, late: item.isLate),
              ],
            ),
          ),
          if (!item.isDone)
            IconButton.filledTonal(
              tooltip: 'Tomei',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.successSoft,
                foregroundColor: AppColors.success,
              ),
              onPressed: () => takeDose(context, ref, item),
              icon: const Icon(Icons.check_rounded),
            )
          else
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// Mostra o ciclo ativo (anticoncepcional / esquemas cíclicos).
class _CycleCard extends ConsumerWidget {
  const _CycleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatments =
        ref.watch(activeTreatmentsProvider).valueOrNull ?? const [];
    final meds = ref.watch(medicationsProvider).valueOrNull ?? const [];
    final cyclic =
        treatments
            .where(
              (t) =>
                  t.rule.type == ScheduleType.cycle &&
                  (t.rule.pauseDays ?? 0) > 0,
            )
            .toList();
    if (cyclic.isEmpty) return const SizedBox.shrink();

    final t = cyclic.first;
    final med = meds.where((m) => m.id == t.medicationId).firstOrNull;
    final info = CycleInfo.of(t, DateTime.now());
    final next = info.nextCycleStart;

    return AppCard(
      onTap: () => context.go('/calendar'),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value:
                      info.cycleLength == 0
                          ? 0
                          : info.dayOfCycle / info.cycleLength,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0xFFFCE7F3),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFEC4899)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${info.dayOfCycle}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        height: 1,
                      ),
                    ),
                    Text(
                      'de ${info.cycleLength}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med?.displayName ?? 'Ciclo',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.isUsageDay
                      ? 'Período de uso · faltam ${info.daysLeftInPhase} dias'
                      : 'Intervalo · faltam ${info.daysLeftInPhase} dias',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (next != null)
                  Text(
                    'Próxima cartela: ${DateFormat('dd/MM').format(next)}',
                    style: const TextStyle(
                      color: AppColors.violet,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _QuickStats extends ConsumerWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeTreatmentsProvider).valueOrNull?.length ?? 0;
    final low =
        (ref.watch(stocksProvider).valueOrNull ?? const <Stock>[])
            .where((s) => s.isLow)
            .length;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.medication_rounded,
            color: AppColors.violet,
            soft: const Color(0xFFEDE9FE),
            value: '$active',
            label: 'Métodos\nativos',
            onTap: () => context.go('/medications'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.inventory_2_rounded,
            color: low > 0 ? AppColors.danger : AppColors.success,
            soft: low > 0 ? AppColors.dangerSoft : AppColors.successSoft,
            value: '$low',
            label:
                low == 1 ? 'Cartela\nacabando' : 'Cartelas\nacabando',
            onTap: () => context.push('/stock'),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.soft,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color soft;
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.3),
          ),
        ],
      ),
    );
  }
}
