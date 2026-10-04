import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../models/enums.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

/// Regras de negócio ao registrar doses.
///
/// - "Tomei" grava o registro **e** desconta do estoque na mesma transação.
/// - Desfazer devolve a quantidade ao estoque.
/// - Nunca sugere compensação de dose (documento §8).
class DoseService {
  DoseService(this._db, this._records, this._stocks);

  final AppDatabase _db;
  final DoseRecordRepository _records;
  final StockRepository _stocks;
  static const _uuid = Uuid();

  Future<void> markTaken(DoseOccurrence dose, {required String medicationId}) {
    return _db.transaction(() async {
      final existing = await _records.find(dose.treatmentId, dose.scheduledAt);
      if (existing?.status == DoseStatus.taken) return;
      await _records.upsert(DoseRecord(
        id: existing?.id ?? _uuid.v4(),
        treatmentId: dose.treatmentId,
        scheduledAt: dose.scheduledAt,
        takenAt: DateTime.now(),
        status: DoseStatus.taken,
        quantity: dose.quantity,
      ));
      await _stocks.adjust(medicationId, -dose.quantity);
    });
  }

  Future<void> markSkipped(DoseOccurrence dose) => _setStatus(dose, DoseStatus.skipped);

  Future<void> snooze(DoseOccurrence dose, Duration by) => _setStatus(
        dose,
        DoseStatus.snoozed,
        note: 'Adiado para ${DateTime.now().add(by).toIso8601String()}',
      );

  /// Volta a dose para "aguardando" e devolve o estoque, se havia sido tomada.
  Future<void> undo(DoseOccurrence dose, {required String medicationId}) {
    return _db.transaction(() async {
      final existing = await _records.find(dose.treatmentId, dose.scheduledAt);
      if (existing == null) return;
      await _records.delete(dose.treatmentId, dose.scheduledAt);
      if (existing.status == DoseStatus.taken) {
        await _stocks.adjust(medicationId, existing.quantity);
      }
    });
  }

  Future<void> _setStatus(DoseOccurrence dose, DoseStatus status, {String? note}) async {
    final existing = await _records.find(dose.treatmentId, dose.scheduledAt);
    await _records.upsert(DoseRecord(
      id: existing?.id ?? _uuid.v4(),
      treatmentId: dose.treatmentId,
      scheduledAt: dose.scheduledAt,
      status: status,
      quantity: dose.quantity,
      note: note,
    ));
  }
}
