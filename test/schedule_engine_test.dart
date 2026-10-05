import 'package:flutter_test/flutter_test.dart';
import 'package:velix_med/models/enums.dart';
import 'package:velix_med/models/models.dart';
import 'package:velix_med/models/schedule_rule.dart';
import 'package:velix_med/services/schedule_engine/schedule_engine.dart';

Treatment _t(ScheduleRule rule, {DateTime? start, double dose = 1}) =>
    Treatment(
      id: 't1',
      medicationId: 'm1',
      startDate: start ?? DateTime(2026, 10, 3),
      rule: rule,
      dosePerIntake: dose,
    );

void main() {
  final engine = ScheduleEngine();
  const t8 = DoseTime(8, 0);

  group('Uso diário / contínuo', () {
    test('1x ao dia gera uma dose por dia, sem fim', () {
      final t = _t(
        const ScheduleRule(type: ScheduleType.continuous, times: [t8]),
      );
      final doses = engine.generate(
        t,
        from: DateTime(2026, 10, 3),
        to: DateTime(2026, 11, 3),
      );
      expect(doses.length, 31);
      expect(doses.first.scheduledAt, DateTime(2026, 10, 3, 8));
    });

    test('3x ao dia em ordem cronológica', () {
      final t = _t(
        const ScheduleRule(
          type: ScheduleType.timesPerDay,
          times: [DoseTime(20, 0), DoseTime(8, 0), DoseTime(14, 0)],
        ),
      );
      final doses = engine.forDay([t], DateTime(2026, 10, 3));
      expect(doses.map((d) => d.scheduledAt.hour), [8, 14, 20]);
    });

    test('não gera doses antes da data de início', () {
      final t = _t(
        const ScheduleRule(type: ScheduleType.continuous, times: [t8]),
      );
      expect(engine.forDay([t], DateTime(2026, 10, 2)), isEmpty);
    });

    test('horário duplicado não gera dose duplicada', () {
      final t = _t(
        const ScheduleRule(type: ScheduleType.timesPerDay, times: [t8, t8]),
      );
      expect(engine.forDay([t], DateTime(2026, 10, 3)).length, 1);
    });
  });

  group('Duração e data final', () {
    test('7 dias gera exatamente 7 doses (03/10 a 09/10)', () {
      final t = _t(
        const ScheduleRule(
          type: ScheduleType.durationDays,
          times: [t8],
          durationDays: 7,
        ),
      );
      final doses = engine.generate(
        t,
        from: DateTime(2026, 10, 1),
        to: DateTime(2026, 12, 1),
      );
      expect(doses.length, 7);
      expect(doses.last.scheduledAt, DateTime(2026, 10, 9, 8));
    });

    test('5 dias, 2x ao dia = 10 doses', () {
      final t = _t(
        const ScheduleRule(
          type: ScheduleType.durationDays,
          times: [t8, DoseTime(20, 0)],
          durationDays: 5,
        ),
      );
      expect(
        engine
            .generate(t, from: DateTime(2026, 10, 1), to: DateTime(2027))
            .length,
        10,
      );
    });

    test('data final é inclusiva', () {
      final t = _t(
        ScheduleRule(
          type: ScheduleType.endDate,
          times: const [t8],
          endDate: DateTime(2026, 10, 5),
        ),
      );
      final doses = engine.generate(
        t,
        from: DateTime(2026, 10, 1),
        to: DateTime(2027),
      );
      expect(doses.length, 3);
    });

    test('tratamento encerrado não gera doses', () {
      final t = Treatment(
        id: 't',
        medicationId: 'm',
        startDate: DateTime(2026, 10, 3),
        rule: const ScheduleRule(type: ScheduleType.continuous, times: [t8]),
        status: TreatmentStatus.finished,
      );
      expect(engine.forDay([t], DateTime(2026, 10, 3)), isEmpty);
    });
  });

  group('Intervalo de horas', () {
    test('a cada 8h gera 3 doses por dia', () {
      final t = _t(
        const ScheduleRule(
          type: ScheduleType.intervalHours,
          times: [DoseTime(6, 0)],
          intervalHours: 8,
        ),
      );
      final doses = engine.forDay([t], DateTime(2026, 10, 4));
      expect(doses.map((d) => d.scheduledAt.hour), [6, 14, 22]);
    });

    test('a cada 12h com duração de 3 dias = 6 doses', () {
      final t = _t(
        const ScheduleRule(
          type: ScheduleType.intervalHours,
          times: [t8],
          intervalHours: 12,
          durationDays: 3,
        ),
      );
      expect(
        engine
            .generate(t, from: DateTime(2026, 10, 1), to: DateTime(2027))
            .length,
        6,
      );
    });
  });

  group('Ciclos', () {
    const rule21 = ScheduleRule(
      type: ScheduleType.cycle,
      times: [DoseTime(9, 0)],
      usageDays: 21,
      pauseDays: 7,
    );

    test('21 + 7: 21 dias de uso por ciclo de 28', () {
      final t = _t(rule21);
      final doses = engine.generate(
        t,
        from: DateTime(2026, 10, 3),
        to: DateTime(2026, 10, 3).add(const Duration(days: 28)),
      );
      expect(doses.length, 21);
    });

    test('dia 22 é pausa e dia 29 inicia nova cartela', () {
      final t = _t(rule21);
      final day22 = DateTime(2026, 10, 24);
      final day29 = DateTime(2026, 10, 31);
      expect(CycleInfo.of(t, day22).isUsageDay, isFalse);
      expect(CycleInfo.of(t, day22).dayOfCycle, 22);
      final info29 = CycleInfo.of(t, day29);
      expect(info29.isUsageDay, isTrue);
      expect(info29.cycleNumber, 2);
      expect(info29.dayOfCycle, 1);
    });

    test('próximo ciclo é calculado corretamente', () {
      final info = CycleInfo.of(_t(rule21), DateTime(2026, 10, 10));
      expect(info.nextCycleStart, DateTime(2026, 10, 31));
      expect(info.daysLeftInPhase, 14);
    });

    test('ciclo sem repetição termina após o primeiro', () {
      final t = _t(
        const ScheduleRule(
          type: ScheduleType.cycle,
          times: [t8],
          usageDays: 21,
          pauseDays: 7,
          repeat: false,
        ),
      );
      final doses = engine.generate(
        t,
        from: DateTime(2026, 10, 1),
        to: DateTime(2027),
      );
      expect(doses.length, 21);
    });

    test('24 + 4', () {
      final t = _t(
        const ScheduleRule(
          type: ScheduleType.cycle,
          times: [t8],
          usageDays: 24,
          pauseDays: 4,
        ),
      );
      final doses = engine.generate(
        t,
        from: DateTime(2026, 10, 3),
        to: DateTime(2026, 10, 3).add(const Duration(days: 56)),
      );
      expect(doses.length, 48);
    });

    test('contínuo (sem pausa) usa todos os dias', () {
      final t = _t(
        const ScheduleRule(
          type: ScheduleType.cycle,
          times: [t8],
          usageDays: 28,
          pauseDays: 0,
        ),
      );
      final doses = engine.generate(
        t,
        from: DateTime(2026, 10, 3),
        to: DateTime(2026, 10, 3).add(const Duration(days: 60)),
      );
      expect(doses.length, 60);
    });
  });

  group('Se necessário', () {
    test('nunca gera doses automáticas', () {
      final t = _t(
        const ScheduleRule(type: ScheduleType.asNeeded, times: [t8]),
      );
      expect(
        engine.generate(t, from: DateTime(2026, 10, 1), to: DateTime(2027)),
        isEmpty,
      );
    });
  });

  group('Serialização', () {
    test('ScheduleRule ida e volta em JSON', () {
      final rule = ScheduleRule(
        type: ScheduleType.cycle,
        times: const [DoseTime(9, 30)],
        usageDays: 21,
        pauseDays: 7,
        endDate: DateTime(2027, 1, 1),
      );
      final back = ScheduleRule.fromJson(rule.toJson());
      expect(back.type, ScheduleType.cycle);
      expect(back.times.single, const DoseTime(9, 30));
      expect(back.usageDays, 21);
      expect(back.pauseDays, 7);
      expect(back.endDate, DateTime(2027, 1, 1));
    });
  });
}
