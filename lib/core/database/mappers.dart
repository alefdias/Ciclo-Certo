import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/enums.dart';
import '../../models/models.dart';
import '../../models/schedule_rule.dart';
import 'app_database.dart';

/// Conversões entre linhas do banco (Drift) e modelos de domínio.
///
/// Mantém a interface e o motor livres de qualquer detalhe do SQLite.
extension MedicationRowX on MedicationRow {
  Medication toDomain() => Medication(
        id: id,
        name: name,
        activeIngredient: activeIngredient,
        concentration: concentration,
        form: enumFromName(
            PharmaceuticalForm.values, form, PharmaceuticalForm.other),
        category: enumFromName(
            MedicationCategory.values, category, MedicationCategory.other),
        notes: notes,
      );
}

extension MedicationX on Medication {
  MedicationsCompanion toCompanion() => MedicationsCompanion.insert(
        id: id,
        name: name,
        activeIngredient: Value(activeIngredient),
        concentration: Value(concentration),
        form: Value(form.name),
        category: Value(category.name),
        notes: Value(notes),
      );
}

extension TreatmentRowX on TreatmentRow {
  Treatment toDomain() => Treatment(
        id: id,
        medicationId: medicationId,
        startDate: startDate,
        rule: ScheduleRule.fromJson(
            jsonDecode(scheduleData) as Map<String, dynamic>),
        dosePerIntake: dosePerIntake,
        status: enumFromName(
            TreatmentStatus.values, status, TreatmentStatus.active),
      );
}

extension TreatmentX on Treatment {
  TreatmentsCompanion toCompanion() => TreatmentsCompanion.insert(
        id: id,
        medicationId: medicationId,
        startDate: startDate,
        scheduleType: rule.type.name,
        scheduleData: jsonEncode(rule.toJson()),
        dosePerIntake: Value(dosePerIntake),
        status: Value(status.name),
      );
}

extension DoseRecordRowX on DoseRecordRow {
  DoseRecord toDomain() => DoseRecord(
        id: id,
        treatmentId: treatmentId,
        scheduledAt: scheduledAt,
        takenAt: takenAt,
        status: enumFromName(DoseStatus.values, status, DoseStatus.pending),
        quantity: quantity,
        note: note,
      );
}

extension DoseRecordX on DoseRecord {
  DoseRecordsCompanion toCompanion() => DoseRecordsCompanion.insert(
        id: id,
        treatmentId: treatmentId,
        scheduledAt: scheduledAt,
        takenAt: Value(takenAt),
        status: status.name,
        quantity: quantity,
        note: Value(note),
      );
}

extension StockRowX on StockRow {
  Stock toDomain() => Stock(
        medicationId: medicationId,
        quantity: quantity,
        totalCapacity: totalCapacity,
        lowStockLimit: lowStockLimit,
        expirationDate: expirationDate,
        batch: batch,
      );
}

extension StockX on Stock {
  StocksCompanion toCompanion() => StocksCompanion.insert(
        medicationId: medicationId,
        quantity: quantity,
        totalCapacity: Value(totalCapacity),
        lowStockLimit: Value(lowStockLimit),
        expirationDate: Value(expirationDate),
        batch: Value(batch),
      );
}
