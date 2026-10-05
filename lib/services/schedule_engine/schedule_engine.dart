import '../../models/enums.dart';
import '../../models/models.dart';
import '../../models/schedule_rule.dart';

/// Treatment Schedule Engine — núcleo do Velix Med.
///
/// Transforma um [Treatment] (medicamento + regra) em uma lista de
/// [DoseOccurrence] dentro de um intervalo de datas.
///
/// É totalmente independente da interface e do banco de dados, o que permite
/// testá-lo isoladamente (veja `test/schedule_engine_test.dart`).
class ScheduleEngine {
  ScheduleEngine({Map<ScheduleType, ScheduleStrategy>? strategies})
    : _strategies = strategies ?? _defaultStrategies;

  static final Map<ScheduleType, ScheduleStrategy> _defaultStrategies = {
    ScheduleType.continuous: const DailyTimesStrategy(),
    ScheduleType.timesPerDay: const DailyTimesStrategy(),
    ScheduleType.durationDays: const DailyTimesStrategy(),
    ScheduleType.endDate: const DailyTimesStrategy(),
    ScheduleType.intervalHours: const IntervalStrategy(),
    ScheduleType.cycle: const CycleStrategy(),
    ScheduleType.custom: const CycleStrategy(),
    ScheduleType.asNeeded: const AsNeededStrategy(),
  };

  final Map<ScheduleType, ScheduleStrategy> _strategies;

  /// Gera as doses com `from <= scheduledAt < to`, em ordem cronológica.
  List<DoseOccurrence> generate(
    Treatment treatment, {
    required DateTime from,
    required DateTime to,
  }) {
    if (treatment.status != TreatmentStatus.active || !from.isBefore(to)) {
      return const [];
    }
    final strategy = _strategies[treatment.rule.type];
    if (strategy == null) return const [];
    final result =
        strategy
            .generate(treatment, from, to)
            .where(
              (d) =>
                  !d.scheduledAt.isBefore(from) && d.scheduledAt.isBefore(to),
            )
            .toSet()
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return result;
  }

  /// Gera as doses de vários tratamentos em um dia.
  List<DoseOccurrence> forDay(Iterable<Treatment> treatments, DateTime day) {
    final start = dateOnly(day);
    final end = DateTime(start.year, start.month, start.day + 1);
    return treatments.expand((t) => generate(t, from: start, to: end)).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }
}

/// Estratégia para um tipo de esquema.
abstract class ScheduleStrategy {
  const ScheduleStrategy();

  List<DoseOccurrence> generate(Treatment t, DateTime from, DateTime to);
}

// ---------------------------------------------------------------------------
// Utilitários de data (seguros contra horário de verão)
// ---------------------------------------------------------------------------

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Diferença em dias de calendário (ignora horas e horário de verão).
int calendarDaysBetween(DateTime a, DateTime b) {
  final ua = DateTime.utc(a.year, a.month, a.day);
  final ub = DateTime.utc(b.year, b.month, b.day);
  return ub.difference(ua).inDays;
}

/// Último dia (inclusive) do tratamento, ou `null` se não houver fim.
DateTime? lastDayOf(Treatment t) {
  final r = t.rule;
  if (r.durationDays != null && r.durationDays! > 0) {
    final s = dateOnly(t.startDate);
    return DateTime(s.year, s.month, s.day + r.durationDays! - 1);
  }
  if (r.endDate != null) return dateOnly(r.endDate!);
  return null;
}

Iterable<DateTime> _days(Treatment t, DateTime from, DateTime to) sync* {
  final start = dateOnly(t.startDate);
  var day = dateOnly(from).isBefore(start) ? start : dateOnly(from);
  final last = lastDayOf(t);
  while (day.isBefore(to)) {
    if (last != null && day.isAfter(last)) return;
    yield day;
    day = DateTime(day.year, day.month, day.day + 1);
  }
}

// ---------------------------------------------------------------------------
// Estratégias
// ---------------------------------------------------------------------------

/// Horários fixos todos os dias. Cobre: uso contínuo, vezes ao dia,
/// duração em dias e data final.
class DailyTimesStrategy extends ScheduleStrategy {
  const DailyTimesStrategy();

  @override
  List<DoseOccurrence> generate(Treatment t, DateTime from, DateTime to) {
    final times = [...t.rule.times]..sort();
    return [
      for (final day in _days(t, from, to))
        for (final time in times)
          DoseOccurrence(
            treatmentId: t.id,
            scheduledAt: time.on(day),
            quantity: t.dosePerIntake,
          ),
    ];
  }
}

/// A cada N horas, a partir do primeiro horário no dia de início.
class IntervalStrategy extends ScheduleStrategy {
  const IntervalStrategy();

  @override
  List<DoseOccurrence> generate(Treatment t, DateTime from, DateTime to) {
    final hours = t.rule.intervalHours;
    if (hours == null || hours <= 0) return const [];
    final firstTime =
        t.rule.times.isEmpty ? const DoseTime(8, 0) : t.rule.times.first;
    final last = lastDayOf(t);
    final limit =
        last == null ? to : DateTime(last.year, last.month, last.day + 1);
    final end = limit.isBefore(to) ? limit : to;

    // Avança direto até perto de `from` sem iterar desde o início.
    var current = firstTime.on(dateOnly(t.startDate));
    if (current.isBefore(from)) {
      final steps = from.difference(current).inMinutes ~/ (hours * 60);
      current = current.add(Duration(hours: steps * hours));
    }
    final out = <DoseOccurrence>[];
    while (current.isBefore(end)) {
      out.add(
        DoseOccurrence(
          treatmentId: t.id,
          scheduledAt: current,
          quantity: t.dosePerIntake,
        ),
      );
      current = current.add(Duration(hours: hours));
    }
    return out;
  }
}

/// Períodos de uso + pausa (21+7, 24+4, contínuo, personalizado...).
class CycleStrategy extends ScheduleStrategy {
  const CycleStrategy();

  @override
  List<DoseOccurrence> generate(Treatment t, DateTime from, DateTime to) {
    final times = [...t.rule.times]..sort();
    return [
      for (final day in _days(t, from, to))
        if (CycleInfo.of(t, day).isUsageDay)
          for (final time in times)
            DoseOccurrence(
              treatmentId: t.id,
              scheduledAt: time.on(day),
              quantity: t.dosePerIntake,
            ),
    ];
  }
}

/// Uso eventual: nunca gera doses automáticas (regra do documento, §14).
class AsNeededStrategy extends ScheduleStrategy {
  const AsNeededStrategy();

  @override
  List<DoseOccurrence> generate(Treatment t, DateTime from, DateTime to) =>
      const [];
}

// ---------------------------------------------------------------------------
// Informações de ciclo
// ---------------------------------------------------------------------------

/// Situação de um tratamento cíclico em uma data.
class CycleInfo {
  const CycleInfo({
    required this.cycleNumber,
    required this.dayOfCycle,
    required this.usageDays,
    required this.pauseDays,
    required this.isUsageDay,
    required this.daysLeftInPhase,
    required this.nextCycleStart,
    required this.finished,
  });

  /// Ciclo atual (1 = primeira cartela).
  final int cycleNumber;

  /// Dia dentro do ciclo (1-based).
  final int dayOfCycle;
  final int usageDays;
  final int pauseDays;
  final bool isUsageDay;

  /// Dias restantes na fase atual (uso ou pausa), incluindo hoje.
  final int daysLeftInPhase;
  final DateTime? nextCycleStart;

  /// Ciclo sem repetição já encerrado.
  final bool finished;

  int get cycleLength => usageDays + pauseDays;

  static CycleInfo of(Treatment t, DateTime date) {
    final usage = t.rule.usageDays ?? 0;
    final pause = t.rule.pauseDays ?? 0;
    final length = usage + pause;
    final start = dateOnly(t.startDate);
    final d = calendarDaysBetween(start, date);

    // Sem pausa configurada → todos os dias são de uso.
    if (usage <= 0 || pause <= 0 || length <= 0) {
      return CycleInfo(
        cycleNumber: usage > 0 && d >= 0 ? d ~/ usage + 1 : 1,
        dayOfCycle: usage > 0 && d >= 0 ? d % usage + 1 : d + 1,
        usageDays: usage,
        pauseDays: 0,
        isUsageDay: d >= 0,
        daysLeftInPhase: usage > 0 && d >= 0 ? usage - d % usage : 0,
        nextCycleStart:
            usage > 0 && d >= 0
                ? DateTime(
                  start.year,
                  start.month,
                  start.day + (d ~/ usage + 1) * usage,
                )
                : null,
        finished: false,
      );
    }

    if (d < 0) {
      return CycleInfo(
        cycleNumber: 0,
        dayOfCycle: 0,
        usageDays: usage,
        pauseDays: pause,
        isUsageDay: false,
        daysLeftInPhase: -d,
        nextCycleStart: start,
        finished: false,
      );
    }

    final cycleIndex = d ~/ length;
    final pos = d % length;
    final finished = !t.rule.repeat && cycleIndex >= 1;
    final inUse = !finished && pos < usage;
    final nextStart =
        finished
            ? null
            : DateTime(
              start.year,
              start.month,
              start.day + (cycleIndex + 1) * length,
            );

    return CycleInfo(
      cycleNumber: cycleIndex + 1,
      dayOfCycle: pos + 1,
      usageDays: usage,
      pauseDays: pause,
      isUsageDay: inUse,
      daysLeftInPhase: pos < usage ? usage - pos : length - pos,
      nextCycleStart: (!t.rule.repeat && cycleIndex == 0) ? null : nextStart,
      finished: finished,
    );
  }
}
