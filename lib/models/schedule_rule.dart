import 'enums.dart';

/// Horário do dia (independente do Flutter, para manter o domínio em Dart puro).
class DoseTime implements Comparable<DoseTime> {
  const DoseTime(this.hour, this.minute)
      : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60);

  /// Converte "08:30" em [DoseTime].
  factory DoseTime.parse(String value) {
    final parts = value.split(':');
    return DoseTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  final int hour;
  final int minute;

  int get totalMinutes => hour * 60 + minute;

  DateTime on(DateTime day) =>
      DateTime(day.year, day.month, day.day, hour, minute);

  String format() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(DoseTime other) => totalMinutes.compareTo(other.totalMinutes);

  @override
  bool operator ==(Object other) =>
      other is DoseTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => format();
}

/// Regra de um esquema de tratamento.
///
/// É serializada como JSON na coluna `schedule_data` da tabela `treatments`,
/// o que permite adicionar novos tipos de esquema sem alterar o banco.
class ScheduleRule {
  const ScheduleRule({
    required this.type,
    this.times = const [],
    this.intervalHours,
    this.durationDays,
    this.endDate,
    this.usageDays,
    this.pauseDays,
    this.repeat = true,
  });

  final ScheduleType type;

  /// Horários das doses (usado por quase todos os tipos).
  /// Para [ScheduleType.intervalHours], o primeiro horário é a primeira dose.
  final List<DoseTime> times;

  /// Para [ScheduleType.intervalHours].
  final int? intervalHours;

  /// Para [ScheduleType.durationDays].
  final int? durationDays;

  /// Para [ScheduleType.endDate] (inclusive).
  final DateTime? endDate;

  /// Para [ScheduleType.cycle] / [ScheduleType.custom]: dias de uso.
  final int? usageDays;

  /// Para [ScheduleType.cycle] / [ScheduleType.custom]: dias de pausa.
  final int? pauseDays;

  /// Para ciclos: repetir após a pausa.
  final bool repeat;

  int get cycleLength => (usageDays ?? 0) + (pauseDays ?? 0);

  /// Descrição curta, ex.: "1x ao dia", "21 dias + 7 de pausa".
  String get summary {
    switch (type) {
      case ScheduleType.continuous:
      case ScheduleType.timesPerDay:
        return '${times.length}x ao dia';
      case ScheduleType.intervalHours:
        return 'A cada ${intervalHours ?? '?'}h';
      case ScheduleType.durationDays:
        return '${times.length}x ao dia · $durationDays dias';
      case ScheduleType.endDate:
        return '${times.length}x ao dia · até data final';
      case ScheduleType.cycle:
      case ScheduleType.custom:
        return (pauseDays ?? 0) == 0
            ? 'Contínuo · sem pausa'
            : '$usageDays dias + $pauseDays de pausa';
      case ScheduleType.asNeeded:
        return 'Se necessário';
    }
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'times': times.map((t) => t.format()).toList(),
        if (intervalHours != null) 'intervalHours': intervalHours,
        if (durationDays != null) 'durationDays': durationDays,
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (usageDays != null) 'usageDays': usageDays,
        if (pauseDays != null) 'pauseDays': pauseDays,
        'repeat': repeat,
      };

  factory ScheduleRule.fromJson(Map<String, dynamic> json) => ScheduleRule(
        type: enumFromName(
            ScheduleType.values, json['type'] as String?, ScheduleType.custom),
        times: ((json['times'] as List?) ?? const [])
            .map((e) => DoseTime.parse(e as String))
            .toList(),
        intervalHours: json['intervalHours'] as int?,
        durationDays: json['durationDays'] as int?,
        endDate: json['endDate'] == null
            ? null
            : DateTime.parse(json['endDate'] as String),
        usageDays: json['usageDays'] as int?,
        pauseDays: json['pauseDays'] as int?,
        repeat: (json['repeat'] as bool?) ?? true,
      );
}
