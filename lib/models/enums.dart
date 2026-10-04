/// Enums de domínio do Ciclo Certo.
///
/// São persistidos no banco pelo [name], portanto **não renomeie** valores
/// existentes sem criar uma migração.
library;

/// Tipos de esquema suportados pelo Treatment Schedule Engine.
enum ScheduleType {
  /// Todos os dias, sem data final.
  continuous('Uso contínuo'),

  /// A cada N horas.
  intervalHours('Intervalo de horas'),

  /// N vezes ao dia em horários definidos.
  timesPerDay('Vezes ao dia'),

  /// Durante N dias.
  durationDays('Duração em dias'),

  /// Até uma data final.
  endDate('Até uma data'),

  /// Período de uso + período de pausa, com repetição (21+7, 24+4...).
  cycle('Ciclo'),

  /// Uso eventual — não gera doses automáticas.
  asNeeded('Se necessário'),

  /// Definido livremente pelo usuário.
  custom('Personalizado');

  const ScheduleType(this.label);
  final String label;
}

/// Status de uma dose.
enum DoseStatus {
  pending('Aguardando'),
  taken('Tomado'),
  skipped('Pulado'),
  snoozed('Adiado'),
  missed('Não registrado');

  const DoseStatus(this.label);
  final String label;
}

/// Status de um tratamento.
enum TreatmentStatus { active, paused, finished }

/// Forma farmacêutica.
enum PharmaceuticalForm {
  tablet('Comprimido', 'comprimido'),
  capsule('Cápsula', 'cápsula'),
  drops('Gotas', 'gota'),
  solution('Solução', 'mL'),
  syrup('Xarope', 'mL'),
  cream('Creme', 'aplicação'),
  ointment('Pomada', 'aplicação'),
  spray('Spray', 'jato'),
  patch('Adesivo', 'adesivo'),
  injectable('Injetável', 'dose'),
  other('Outro', 'unidade');

  const PharmaceuticalForm(this.label, this.unit);
  final String label;

  /// Unidade padrão no singular.
  final String unit;
}

/// Categoria do medicamento (define ícone e cor na interface).
enum MedicationCategory {
  pill('Pílula Anticoncepcional'),
  injection('Injeção'),
  patch('Adesivo'),
  ring('Anel Vaginal'),
  iud('DIU / Implante'),
  contraceptive('Anticoncepcional'),
  continuousUse('Uso Contínuo'),
  painFever('Dor e Febre'),
  antibiotic('Antibiótico'),
  vitamins('Vitaminas'),
  other('Outro Método');

  const MedicationCategory(this.label);
  final String label;
}

/// Converte com segurança um texto salvo no banco para o enum.
T enumFromName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
