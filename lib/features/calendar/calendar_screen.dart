import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dose_actions.dart';
import '../../models/enums.dart';
import '../../models/models.dart';
import '../../services/schedule_engine/schedule_engine.dart';

/// Calendário mensal com fases de ciclo, status de pílula tomada/esquecida e doses do dia (§15).
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _selected = dateOnly(DateTime.now());
  bool _showOccurrences = true;

  void _shiftMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final isPartner = ref.watch(isPartnerModeProvider);
    final treatments =
        ref.watch(activeTreatmentsProvider).valueOrNull ?? const <Treatment>[];
    final cyclic =
        treatments
            .where(
              (t) =>
                  t.rule.type == ScheduleType.cycle &&
                  (t.rule.pauseDays ?? 0) > 0,
            )
            .firstOrNull;
    final dayDoses = ref.watch(dosesForDayProvider(_selected));

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          AppCard(
            child: Column(
              children: [
                _MonthHeader(month: _month, onShift: _shiftMonth),
                const SizedBox(height: 12),
                _MonthGrid(
                  month: _month,
                  selected: _selected,
                  cyclic: cyclic,
                  treatments: treatments,
                  onSelect: (d) => setState(() => _selected = d),
                ),
                if (cyclic != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Legend(
                        color: Color(0xFF5B8E7D),
                        border: Colors.transparent,
                        label: 'Pílula tomada',
                      ),
                      _Legend(
                        color: Color(0xFFCFD8DC),
                        border: Colors.transparent,
                        label: 'Pílula inativa',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Legend(
                        color: Color(0xFFE04848),
                        border: Colors.transparent,
                        label: 'Pílula esquecida',
                      ),
                      _Legend(
                        color: Color(0xFFF9D2C8),
                        border: Colors.transparent,
                        label: 'Pílula ativa',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: _Legend(
                      color: Colors.transparent,
                      border: Color(0xFF1E293B),
                      borderWidth: 2,
                      label: 'Dia atual',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Alternador de Visualizar Ocorrências
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Visualizar ocorrências',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              Switch(
                value: _showOccurrences,
                onChanged: (v) => setState(() => _showOccurrences = v),
                activeColor: AppColors.violet,
              ),
            ],
          ),

          if (_showOccurrences) ...[
            const SizedBox(height: 12),
            SectionTitle(_selectedTitle()),
            dayDoses.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data:
                  (items) =>
                      items.isEmpty
                          ? const EmptyState(
                            icon: Icons.event_busy_rounded,
                            title: 'Nenhuma dose neste dia',
                          )
                          : Column(
                            children: [
                              for (final item in items) ...[
                                _DayDoseTile(
                                  item: item,
                                  canAct:
                                      !isPartner &&
                                      !_selected.isAfter(
                                        dateOnly(DateTime.now()),
                                      ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ),
            ),
          ],
        ],
      ),
    );
  }

  String _selectedTitle() {
    final today = dateOnly(DateTime.now());
    if (_selected == today) return 'Hoje';
    if (_selected == today.add(const Duration(days: 1))) return 'Amanhã';
    return DateFormat("d 'de' MMMM", 'pt_BR').format(_selected);
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month, required this.onShift});
  final DateTime month;
  final void Function(int) onShift;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMMM yyyy', 'pt_BR').format(month);
    return Row(
      children: [
        IconButton(
          onPressed: () => onShift(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            label[0].toUpperCase() + label.substring(1),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          onPressed: () => onShift(1),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.cyclic,
    required this.treatments,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final Treatment? cyclic;
  final List<Treatment> treatments;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(scheduleEngineProvider);
    final monthRecords =
        ref.watch(recordsForMonthProvider(month)).valueOrNull ??
        const <DoseRecord>[];
    final today = dateOnly(DateTime.now());
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1; // segunda = 0
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    return Column(
      children: [
        Row(
          children: [
            for (final w in weekdays)
              Expanded(
                child: Text(
                  w,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leading + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (_, i) {
            if (i < leading) return const SizedBox.shrink();
            final day = DateTime(month.year, month.month, i - leading + 1);
            final dayNormalized = dateOnly(day);
            final hasDoses = engine.forDay(treatments, day).isNotEmpty;

            Color bg = Colors.transparent;
            Color fg = AppColors.textPrimary;
            Border? ringBorder;

            if (cyclic != null &&
                !dayNormalized.isBefore(dateOnly(cyclic!.startDate))) {
              final info = CycleInfo.of(cyclic!, dayNormalized);
              if (!info.finished) {
                final dayRecords = monthRecords.where(
                  (r) =>
                      r.scheduledAt.year == day.year &&
                      r.scheduledAt.month == day.month &&
                      r.scheduledAt.day == day.day,
                );
                final isTaken = dayRecords.any(
                  (r) => r.status == DoseStatus.taken,
                );
                final isSkippedOrMissed = dayRecords.any(
                  (r) =>
                      r.status == DoseStatus.skipped ||
                      r.status == DoseStatus.missed,
                );

                if (info.isUsageDay) {
                  if (isTaken) {
                    // Pílula tomada -> Verde
                    bg = const Color(0xFF5B8E7D);
                    fg = Colors.white;
                  } else if (dayNormalized.isBefore(today) ||
                      isSkippedOrMissed) {
                    // Pílula esquecida -> Vermelho
                    bg = const Color(0xFFE04848);
                    fg = Colors.white;
                  } else {
                    // Pílula ativa pendente (hoje ou futuro) -> Rosa/Pêssego
                    bg = const Color(0xFFF9D2C8);
                    fg = const Color(0xFF991B1B);
                  }
                } else {
                  // Pílula inativa (pausa ou placebo) -> Cinza
                  bg = const Color(0xFFCFD8DC);
                  fg = const Color(0xFF475569);
                }
              }
            } else if (hasDoses) {
              final dayRecords = monthRecords.where(
                (r) =>
                    r.scheduledAt.year == day.year &&
                    r.scheduledAt.month == day.month &&
                    r.scheduledAt.day == day.day,
              );
              final isTaken = dayRecords.any(
                (r) => r.status == DoseStatus.taken,
              );
              if (isTaken) {
                bg = const Color(0xFF5B8E7D);
                fg = Colors.white;
              } else if (dayNormalized.isBefore(today)) {
                bg = const Color(0xFFE04848);
                fg = Colors.white;
              } else {
                bg = AppColors.violet.withValues(alpha: 0.15);
                fg = AppColors.violet;
              }
            }

            final isSelected = dayNormalized == selected;
            final isToday = dayNormalized == today;

            if (isToday) {
              ringBorder = Border.all(
                color: const Color(0xFF1E293B),
                width: 2.2,
              );
            }

            return GestureDetector(
              onTap: () => onSelect(dayNormalized),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border:
                      isSelected
                          ? Border.all(color: AppColors.violet, width: 2.5)
                          : ringBorder,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color:
                          isSelected && bg == Colors.transparent
                              ? AppColors.violet
                              : fg,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.border,
    this.borderWidth = 1.5,
    required this.label,
  });

  final Color color;
  final Color border;
  final double borderWidth;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: borderWidth),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DayDoseTile extends ConsumerWidget {
  const _DayDoseTile({required this.item, required this.canAct});
  final DoseItem item;
  final bool canAct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: canAct ? () => showDoseActions(context, ref, item) : null,
      child: Row(
        children: [
          CategoryAvatar(category: item.medication.category, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medication.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${DateFormat.Hm().format(item.occurrence.scheduledAt)} · ${item.quantityLabel}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(status: item.status, late: item.isLate),
          if (canAct && !item.isDone) ...[
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Tomei',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.successSoft,
                foregroundColor: AppColors.success,
              ),
              onPressed: () => takeDose(context, ref, item),
              icon: const Icon(Icons.check_rounded),
            ),
          ],
        ],
      ),
    );
  }
}
