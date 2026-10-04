import 'enums.dart';
import 'schedule_rule.dart';

/// Medicamento cadastrado pelo usuário.
class Medication {
  const Medication({
    required this.id,
    required this.name,
    this.activeIngredient,
    this.concentration,
    this.form = PharmaceuticalForm.tablet,
    this.category = MedicationCategory.other,
    this.notes,
  });

  final String id;
  final String name;
  final String? activeIngredient;
  final String? concentration;
  final PharmaceuticalForm form;
  final MedicationCategory category;
  final String? notes;

  /// Ex.: "Losartana 50 mg".
  String get displayName =>
      concentration == null || concentration!.isEmpty
          ? name
          : '$name $concentration';
}

/// Tratamento: um medicamento + um esquema + período.
class Treatment {
  const Treatment({
    required this.id,
    required this.medicationId,
    required this.startDate,
    required this.rule,
    this.dosePerIntake = 1,
    this.status = TreatmentStatus.active,
  });

  final String id;
  final String medicationId;
  final DateTime startDate;
  final ScheduleRule rule;

  /// Quantidade por dose (ex.: 1 comprimido, 5 mL).
  final double dosePerIntake;
  final TreatmentStatus status;
}

/// Estoque de um medicamento.
class Stock {
  const Stock({
    required this.medicationId,
    required this.quantity,
    this.totalCapacity,
    this.lowStockLimit = 7,
    this.expirationDate,
    this.batch,
  });

  final String medicationId;
  final double quantity;

  /// Capacidade de referência (ex.: 30 da caixa) para a barra de progresso.
  final double? totalCapacity;
  final double lowStockLimit;
  final DateTime? expirationDate;
  final String? batch;

  bool get isLow => quantity <= lowStockLimit;
}

/// Dose prevista gerada pelo motor de esquemas (ainda não persistida).
class DoseOccurrence {
  const DoseOccurrence({
    required this.treatmentId,
    required this.scheduledAt,
    required this.quantity,
  });

  final String treatmentId;
  final DateTime scheduledAt;
  final double quantity;

  /// Chave estável para cruzar com registros salvos.
  String get key => '$treatmentId@${scheduledAt.toIso8601String()}';

  @override
  bool operator ==(Object other) =>
      other is DoseOccurrence &&
      other.treatmentId == treatmentId &&
      other.scheduledAt == scheduledAt;

  @override
  int get hashCode => Object.hash(treatmentId, scheduledAt);

  @override
  String toString() => 'DoseOccurrence($treatmentId, $scheduledAt)';
}

/// Registro do que aconteceu com uma dose (tomada, pulada, adiada...).
class DoseRecord {
  const DoseRecord({
    required this.id,
    required this.treatmentId,
    required this.scheduledAt,
    required this.status,
    required this.quantity,
    this.takenAt,
    this.note,
  });

  final String id;
  final String treatmentId;
  final DateTime scheduledAt;
  final DateTime? takenAt;
  final DoseStatus status;
  final double quantity;
  final String? note;
}
