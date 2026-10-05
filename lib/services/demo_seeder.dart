import 'package:uuid/uuid.dart';

import '../models/enums.dart';
import '../models/models.dart';
import '../models/schedule_rule.dart';
import '../repositories/repositories.dart';

class DemoSeeder {
  const DemoSeeder(this.repo);
  final MedicationRepository repo;

  Future<void> seedIfEmpty() async {
    if (!await repo.isEmpty()) return;

    final now = DateTime.now();
    final today8am = DateTime(now.year, now.month, now.day, 8, 0);

    const uuid = Uuid();

    final List<Map<String, dynamic>> meds = [
      {
        'name': 'Selene',
        'type': ScheduleType.cycle,
        'usageDays': 21,
        'pauseDays': 7,
      },
      {
        'name': 'Qlaira',
        'type': ScheduleType.continuous,
        'usageDays': 28,
        'pauseDays': 0,
      },
      {
        'name': 'Yaz',
        'type': ScheduleType.cycle,
        'usageDays': 24,
        'pauseDays': 4,
      },
      {
        'name': 'Yasmin',
        'type': ScheduleType.cycle,
        'usageDays': 21,
        'pauseDays': 7,
      },
      {
        'name': 'Cerazette',
        'type': ScheduleType.continuous,
        'usageDays': 28,
        'pauseDays': 0,
      },
      {
        'name': 'Diane 35',
        'type': ScheduleType.cycle,
        'usageDays': 21,
        'pauseDays': 7,
      },
      {
        'name': 'Microvlar',
        'type': ScheduleType.cycle,
        'usageDays': 21,
        'pauseDays': 7,
      },
      {
        'name': 'Iumi',
        'type': ScheduleType.cycle,
        'usageDays': 24,
        'pauseDays': 4,
      },
      {
        'name': 'Allestra 20',
        'type': ScheduleType.cycle,
        'usageDays': 21,
        'pauseDays': 7,
      },
      {
        'name': 'Slinda',
        'type': ScheduleType.cycle,
        'usageDays': 24,
        'pauseDays': 4,
      },
    ];

    for (int i = 0; i < meds.length; i++) {
      final m = meds[i];
      final id = uuid.v4();
      final isCycle = m['type'] == ScheduleType.cycle;
      final usage = m['usageDays'] as int;
      final pause = m['pauseDays'] as int;

      await repo.save(
        medication: Medication(
          id: id,
          name: m['name'] as String,
          form: PharmaceuticalForm.tablet,
          category:
              isCycle
                  ? MedicationCategory.contraceptive
                  : MedicationCategory.continuousUse,
        ),
        treatment: Treatment(
          id: uuid.v4(),
          medicationId: id,
          startDate: today8am.subtract(Duration(days: i)), // espalha o início
          rule: ScheduleRule(
            type: m['type'] as ScheduleType,
            times: const [DoseTime(8, 0)],
            usageDays: isCycle ? usage : null,
            pauseDays: isCycle ? pause : null,
            repeat: isCycle,
          ),
        ),
        stock: Stock(
          medicationId: id,
          quantity: usage.toDouble(),
          totalCapacity: usage.toDouble() + pause.toDouble(),
        ),
      );
    }
  }
}
