import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/dose_service.dart';
import '../services/notification_service.dart';
import '../services/schedule_engine/schedule_engine.dart';
import 'database/app_database.dart';

// ---------------------------------------------------------------------------
// Infraestrutura (injeção de dependências)
// ---------------------------------------------------------------------------

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final medicationRepositoryProvider =
    Provider((ref) => MedicationRepository(ref.watch(databaseProvider)));
final treatmentRepositoryProvider =
    Provider((ref) => TreatmentRepository(ref.watch(databaseProvider)));
final stockRepositoryProvider =
    Provider((ref) => StockRepository(ref.watch(databaseProvider)));
final doseRecordRepositoryProvider =
    Provider((ref) => DoseRecordRepository(ref.watch(databaseProvider)));

final scheduleEngineProvider = Provider((_) => ScheduleEngine());

final doseServiceProvider = Provider((ref) => DoseService(
      ref.watch(databaseProvider),
      ref.watch(doseRecordRepositoryProvider),
      ref.watch(stockRepositoryProvider),
    ));

final notificationServiceProvider = Provider((_) => NotificationService());


// ---------------------------------------------------------------------------
// Dados reativos (atualizam sozinhos quando o banco muda)
// ---------------------------------------------------------------------------

final medicationsProvider = StreamProvider<List<Medication>>(
    (ref) => ref.watch(medicationRepositoryProvider).watchAll());

final activeTreatmentsProvider = StreamProvider<List<Treatment>>(
    (ref) => ref.watch(treatmentRepositoryProvider).watchActive());

final stocksProvider = StreamProvider<List<Stock>>(
    (ref) => ref.watch(stockRepositoryProvider).watchAll());

final recentRecordsProvider = StreamProvider<List<DoseRecord>>(
    (ref) => ref.watch(doseRecordRepositoryProvider).watchRecent());

/// Registros de um dia específico.
final recordsForDayProvider =
    StreamProvider.family<List<DoseRecord>, DateTime>((ref, day) {
  final start = dateOnly(day);
  final end = DateTime(start.year, start.month, start.day + 1);
  return ref.watch(doseRecordRepositoryProvider).watchBetween(start, end);
});

// ---------------------------------------------------------------------------
// View models
// ---------------------------------------------------------------------------

/// Uma dose pronta para exibir: previsão do motor + medicamento + registro.
class DoseItem {
  const DoseItem({
    required this.occurrence,
    required this.medication,
    required this.treatment,
    this.record,
  });

  final DoseOccurrence occurrence;
  final Medication medication;
  final Treatment treatment;
  final DoseRecord? record;

  DoseStatus get status => record?.status ?? DoseStatus.pending;
  bool get isDone => status == DoseStatus.taken || status == DoseStatus.skipped;

  /// Pendente e já passou mais de 30 min do horário.
  bool get isLate =>
      status == DoseStatus.pending &&
      DateTime.now().difference(occurrence.scheduledAt).inMinutes > 30;

  String get quantityLabel {
    final q = occurrence.quantity;
    final n = q == q.roundToDouble() ? q.toInt().toString() : q.toString();
    final unit = medication.form.unit;
    final plural = q > 1 && !unit.endsWith('L') ? '${unit}s' : unit;
    return '$n $plural';
  }
}

/// Doses de um dia, combinando motor + banco.
final dosesForDayProvider =
    Provider.family<AsyncValue<List<DoseItem>>, DateTime>((ref, day) {
  final meds = ref.watch(medicationsProvider);
  final treatments = ref.watch(activeTreatmentsProvider);
  final records = ref.watch(recordsForDayProvider(dateOnly(day)));
  final engine = ref.watch(scheduleEngineProvider);

  if (meds.hasError) return AsyncError(meds.error!, meds.stackTrace!);
  if (treatments.hasError) return AsyncError(treatments.error!, treatments.stackTrace!);
  if (!meds.hasValue || !treatments.hasValue || !records.hasValue) {
    return const AsyncLoading();
  }

  final medById = {for (final m in meds.value!) m.id: m};
  final tById = {for (final t in treatments.value!) t.id: t};
  final recByKey = {
    for (final r in records.value!) '${r.treatmentId}@${r.scheduledAt.toIso8601String()}': r,
  };

  final items = <DoseItem>[
    for (final o in engine.forDay(treatments.value!, day))
      if (medById[tById[o.treatmentId]?.medicationId] != null)
        DoseItem(
          occurrence: o,
          treatment: tById[o.treatmentId]!,
          medication: medById[tById[o.treatmentId]!.medicationId]!,
          record: recByKey[o.key],
        ),
  ];
  return AsyncData(items);
});

/// Atalho para hoje.
final todayDosesProvider =
    Provider((ref) => ref.watch(dosesForDayProvider(dateOnly(DateTime.now()))));

/// Mantém as notificações sincronizadas com as doses de hoje.
final notificationSyncProvider = Provider((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  
  ref.listen(todayDosesProvider, (previous, next) {
    if (next.hasValue && next.value != null) {
      notificationService.syncNotifications(next.value!);
    }
  }, fireImmediately: true);
});

