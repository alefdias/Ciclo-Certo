import 'package:drift/drift.dart';

import '../core/database/app_database.dart';
import '../core/database/mappers.dart';
import '../models/enums.dart';
import '../models/models.dart';

/// Acesso a medicamentos, tratamentos e estoque.
class MedicationRepository {
  MedicationRepository(this._db);
  final AppDatabase _db;

  Stream<List<Medication>> watchAll() => (_db.select(_db.medications)
        ..orderBy([(m) => OrderingTerm.asc(m.name)]))
      .watch()
      .map((rows) => rows.map((r) => r.toDomain()).toList());

  Future<bool> isEmpty() async {
    final count = _db.medications.id.count();
    final q = _db.selectOnly(_db.medications)..addColumns([count]);
    return (await q.map((r) => r.read(count)).getSingle() ?? 0) == 0;
  }

  /// Salva medicamento + tratamento + estoque em uma única transação.
  Future<void> save({
    required Medication medication,
    required Treatment treatment,
    Stock? stock,
  }) {
    return _db.transaction(() async {
      await _db.into(_db.medications).insertOnConflictUpdate(medication.toCompanion());
      await _db.into(_db.treatments).insertOnConflictUpdate(treatment.toCompanion());
      if (stock != null) {
        await _db.into(_db.stocks).insertOnConflictUpdate(stock.toCompanion());
      }
    });
  }

  Future<void> delete(String medicationId) =>
      (_db.delete(_db.medications)..where((m) => m.id.equals(medicationId))).go();
}

class TreatmentRepository {
  TreatmentRepository(this._db);
  final AppDatabase _db;

  Stream<List<Treatment>> watchActive() => (_db.select(_db.treatments)
        ..where((t) => t.status.equals(TreatmentStatus.active.name)))
      .watch()
      .map((rows) => rows.map((r) => r.toDomain()).toList());
}

class StockRepository {
  StockRepository(this._db);
  final AppDatabase _db;

  Stream<List<Stock>> watchAll() => _db
      .select(_db.stocks)
      .watch()
      .map((rows) => rows.map((r) => r.toDomain()).toList());

  /// Soma [delta] ao estoque (negativo para consumir). Nunca fica abaixo de 0.
  Future<void> adjust(String medicationId, double delta) {
    return _db.customUpdate(
      'UPDATE stocks SET quantity = MAX(0, quantity + ?) WHERE medication_id = ?',
      variables: [Variable.withReal(delta), Variable.withString(medicationId)],
      updates: {_db.stocks},
    );
  }
}

class DoseRecordRepository {
  DoseRecordRepository(this._db);
  final AppDatabase _db;

  Stream<List<DoseRecord>> watchBetween(DateTime from, DateTime to) =>
      (_db.select(_db.doseRecords)
            ..where((r) =>
                r.scheduledAt.isBiggerOrEqualValue(from) &
                r.scheduledAt.isSmallerThanValue(to))
            ..orderBy([(r) => OrderingTerm.desc(r.scheduledAt)]))
          .watch()
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  Stream<List<DoseRecord>> watchRecent({int limit = 200}) =>
      (_db.select(_db.doseRecords)
            ..orderBy([(r) => OrderingTerm.desc(r.scheduledAt)])
            ..limit(limit))
          .watch()
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  Future<DoseRecord?> find(String treatmentId, DateTime scheduledAt) async {
    final row = await (_db.select(_db.doseRecords)
          ..where((r) =>
              r.treatmentId.equals(treatmentId) &
              r.scheduledAt.equals(scheduledAt)))
        .getSingleOrNull();
    return row?.toDomain();
  }

  Future<void> upsert(DoseRecord record) =>
      _db.into(_db.doseRecords).insert(
            DoseRecordsCompanion.insert(
              id: record.id,
              treatmentId: record.treatmentId,
              scheduledAt: record.scheduledAt,
              takenAt: Value(record.takenAt),
              quantity: record.quantity,
              status: record.status.name,
              note: Value(record.note),
            ),
            onConflict: DoUpdate(
              (_) => DoseRecordsCompanion(
                takenAt: Value(record.takenAt),
                status: Value(record.status.name),
                note: Value(record.note),
              ),
              target: [_db.doseRecords.treatmentId, _db.doseRecords.scheduledAt],
            ),
          );

  Future<void> delete(String treatmentId, DateTime scheduledAt) =>
      (_db.delete(_db.doseRecords)
            ..where((r) =>
                r.treatmentId.equals(treatmentId) &
                r.scheduledAt.equals(scheduledAt)))
          .go();
}
