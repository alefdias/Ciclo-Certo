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
import '../../services/cloud_sync_service.dart';
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
    final isPartner = ref.watch(isPartnerModeProvider);
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
              const SizedBox(height: 16),
              if (isPartner)
                const _PartnerCaringActionsCard()
              else
                const _WomanPartnerLoveBanner(),
              const SizedBox(height: 8),
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              const _CycleCard(),
              if (isPartner) ...[
                const SizedBox(height: 16),
                const _PartnerCyclePhaseGuideCard(),
              ],
              const SizedBox(height: 16),
              const _QuickStats(),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.violet.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.violet.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: 12,
                            color: AppColors.violet,
                          ),
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
        _RoundIcon(
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xFF16A34A),
          tooltip: 'ZapCiclo',
          onTap: () => context.push('/zapciclo'),
        ),
        const SizedBox(width: 8),
        _RoundIcon(icon: Icons.notifications_none_rounded, onTap: () {}),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.onTap,
    this.color,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: AppColors.surfaceSoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color ?? AppColors.textPrimary),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
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
      onTap:
          isPartner
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
          if (!item.isDone && !isPartner)
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
            label: low == 1 ? 'Cartela\nacabando' : 'Cartelas\nacabando',
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

class _PartnerCaringActionsCard extends StatelessWidget {
  const _PartnerCaringActionsCard();

  void _send(
    BuildContext context,
    String type,
    String title,
    String message,
  ) async {
    await CloudSyncService.instance.sendPartnerReaction(
      type: type,
      message: message,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title enviado com sucesso para sua parceira! 💖'),
          backgroundColor: AppColors.violet,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _customMessageDialog(BuildContext context) {
    final controller = TextEditingController(
      text: 'Pensando em você e torcendo pelo seu bem-estar! Amo você ❤️',
    );
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.favorite_rounded, color: AppColors.violet),
                SizedBox(width: 8),
                Text('Enviar Mensagem de Amor'),
              ],
            ),
            content: TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escreva uma mensagem carinhosa...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.violet,
                ),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Enviar'),
                onPressed: () {
                  final text = controller.text.trim();
                  Navigator.pop(ctx);
                  if (text.isNotEmpty) {
                    _send(context, 'love_note', 'Mensagem de amor', text);
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.violet.withValues(alpha: 0.12),
            const Color(0xFF6366F1).withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.volunteer_activism_rounded,
                color: AppColors.violet,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Enviar Carinho à Parceira',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.violet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Toque para enviar uma surpresa carinhosa no celular dela agora:',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CarinhoButton(
                  emoji: '☕',
                  label: 'Oferecer Chá',
                  onTap:
                      () => _send(
                        context,
                        'tea',
                        'Chá quentinho',
                        'Seu amor preparou um chá quentinho para você com muito carinho ☕❤️',
                      ),
                ),
                const SizedBox(width: 8),
                _CarinhoButton(
                  emoji: '💧',
                  label: 'Lembrar de Água',
                  onTap:
                      () => _send(
                        context,
                        'water',
                        'Lembrete de água',
                        'Seu amor lembrou você de beber um copo d\'água fresquinha para se hidratar! 💧🌸',
                      ),
                ),
                const SizedBox(width: 8),
                _CarinhoButton(
                  emoji: '💆‍♀️',
                  label: 'Massagem',
                  onTap:
                      () => _send(
                        context,
                        'massage',
                        'Convite de massagem',
                        'Seu amor quer te fazer uma massagem relaxante para aliviar a tensão hoje! 💆‍♀️💖',
                      ),
                ),
                const SizedBox(width: 8),
                _CarinhoButton(
                  emoji: '💌',
                  label: 'Mensagem',
                  onTap: () => _customMessageDialog(context),
                ),
                const SizedBox(width: 8),
                _CarinhoButton(
                  emoji: '💬',
                  label: 'ZapCiclo',
                  onTap: () => context.push('/zapciclo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CarinhoButton extends StatelessWidget {
  const _CarinhoButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WomanPartnerLoveBanner extends StatelessWidget {
  const _WomanPartnerLoveBanner();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: CloudSyncService.instance.reactionStream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        final message = data['message'] as String?;
        if (message == null || message.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF43F5E).withValues(alpha: 0.12),
                const Color(0xFFFB7185).withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF43F5E).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFF43F5E),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Carinho do seu Parceiro 💕',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFFBE123C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Responder no ZapCiclo',
                icon: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Color(0xFFBE123C),
                  size: 20,
                ),
                onPressed: () => context.push('/zapciclo'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PartnerCyclePhaseGuideCard extends ConsumerWidget {
  const _PartnerCyclePhaseGuideCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatments =
        ref.watch(activeTreatmentsProvider).valueOrNull ?? const [];
    final cyclic =
        treatments
            .where(
              (t) =>
                  t.rule.type == ScheduleType.cycle &&
                  (t.rule.pauseDays ?? 0) > 0,
            )
            .toList();
    if (cyclic.isEmpty) return const SizedBox.shrink();

    final info = CycleInfo.of(cyclic.first, DateTime.now());

    String phaseName;
    String empathyTip;
    String practicalCare;
    IconData icon;
    Color color;

    if (!info.isUsageDay) {
      phaseName = 'Fase Menstrual (Pausa da cartela)';
      empathyTip = 'Queda hormonal e possíveis cólicas ou desconforto físico.';
      practicalCare =
          'Ofereça bolsa morna, evite sobrecarregá-la com tarefas e seja o refúgio seguro dela.';
      icon = Icons.spa_rounded;
      color = const Color(0xFFE11D48);
    } else if (info.dayOfCycle <= 5) {
      phaseName = 'Início de Cartela';
      empathyTip = 'O corpo está reiniciando o ciclo hormonal.';
      practicalCare =
          'Mantenha o carinho e ajude a lembrar do horário do comprimido com muito amor.';
      icon = Icons.calendar_today_rounded;
      color = AppColors.violet;
    } else if (info.dayOfCycle <= 12) {
      phaseName = 'Fase Folicular';
      empathyTip =
          'O estrogênio está subindo! Ela tende a ter mais ânimo, disposição e criatividade.';
      practicalCare =
          'Ótimo momento para planejar saídas a dois, passeios e conversas empolgantes.';
      icon = Icons.wb_sunny_rounded;
      color = const Color(0xFFF59E0B);
    } else if (info.dayOfCycle <= 16) {
      phaseName = 'Fase Fértil / Ovulatória (Correspondente)';
      empathyTip = 'Pico de vitalidade, autoconfiança e atração no ciclo.';
      practicalCare =
          'Momento especial de conexão afetiva, elogios e cumplicidade.';
      icon = Icons.favorite_rounded;
      color = const Color(0xFFEC4899);
    } else {
      phaseName = 'Fase Lútea (Pré-Menstrual / TPM)';
      empathyTip =
          'A progesterona domina. Pode haver oscilações de humor, cansaço ou retenção de líquido.';
      practicalCare =
          'Muita paciência, ouvidos atentos sem julgamento, docinhos favoritos e aconchego.';
      icon = Icons.nightlight_round;
      color = const Color(0xFF8B5CF6);
    }

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guia do Ciclo para Você · Dia ${info.dayOfCycle}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      phaseName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            empathyTip,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: AppColors.teal,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    practicalCare,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
