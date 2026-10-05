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

/// Calendário mensal com fases de ciclo e doses do dia (§15).
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _selected = dateOnly(DateTime.now());

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
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _Legend(
                        color: AppColors.dangerSoft,
                        border: AppColors.danger,
                        label: 'Dia de uso',
                      ),
                      _Legend(
                        color: AppColors.pauseSoft,
                        border: AppColors.pause,
                        label: 'Pausa',
                      ),
                      _Legend(
                        color: Color(0xFFEDE9FE),
                        border: AppColors.violet,
                        label: 'Nova cartela',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
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
            final hasDoses = engine.forDay(treatments, day).isNotEmpty;

            Color bg = Colors.transparent;
            Color fg = AppColors.textPrimary;
            if (cyclic != null && !day.isBefore(dateOnly(cyclic!.startDate))) {
              final info = CycleInfo.of(cyclic!, day);
              if (!info.finished) {
                if (info.dayOfCycle == 1) {
                  bg = const Color(0xFFEDE9FE);
                  fg = AppColors.violet;
                } else if (info.isUsageDay) {
                  bg = AppColors.dangerSoft;
                  fg = AppColors.danger;
                } else {
                  bg = AppColors.pauseSoft;
                  fg = const Color(0xFF0369A1);
                }
              }
            }
            final isSelected = day == selected;
            final isToday = day == today;

            return GestureDetector(
              onTap: () => onSelect(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? null : bg,
                  gradient: isSelected ? AppColors.brandGradient : null,
                  shape: BoxShape.circle,
                  border:
                      isToday && !isSelected
                          ? Border.all(color: AppColors.violet, width: 2)
                          : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : fg,
                      ),
                    ),
                    if (hasDoses && cyclic == null)
                      Positioned(
                        bottom: 5,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : AppColors.teal,
                          ),
                        ),
                      ),
                  ],
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
    required this.label,
  });
  final Color color;
  final Color border;
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
            border: Border.all(color: border, width: 1.5),
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
          if (canAct)
            StatusChip(status: item.status, late: item.isLate)
          else
            const Icon(
              Icons.schedule_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
        ],
      ),
    );
  }
}
