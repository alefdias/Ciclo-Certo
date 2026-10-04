import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Tabelas (veja docs/arquitetura.md §Banco de dados)
// ---------------------------------------------------------------------------

@DataClassName('MedicationRow')
class Medications extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get activeIngredient => text().nullable()();
  TextColumn get concentration => text().nullable()();
  TextColumn get form => text().withDefault(const Constant('tablet'))();
  TextColumn get category => text().withDefault(const Constant('other'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TreatmentRow')
class Treatments extends Table {
  TextColumn get id => text()();
  TextColumn get medicationId =>
      text().references(Medications, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get scheduleType => text()();

  /// JSON de [ScheduleRule].
  TextColumn get scheduleData => text()();
  RealColumn get dosePerIntake => real().withDefault(const Constant(1))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DoseRecordRow')
class DoseRecords extends Table {
  TextColumn get id => text()();
  TextColumn get treatmentId =>
      text().references(Treatments, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get takenAt => dateTime().nullable()();
  RealColumn get quantity => real()();
  TextColumn get status => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {treatmentId, scheduledAt},
      ];
}

@DataClassName('StockRow')
class Stocks extends Table {
  TextColumn get medicationId =>
      text().references(Medications, #id, onDelete: KeyAction.cascade)();
  RealColumn get quantity => real()();
  RealColumn get totalCapacity => real().nullable()();
  RealColumn get lowStockLimit => real().withDefault(const Constant(7))();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  TextColumn get batch => text().nullable()();

  @override
  Set<Column> get primaryKey => {medicationId};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ---------------------------------------------------------------------------
// Banco
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [Medications, Treatments, DoseRecords, Stocks, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Usado em testes: `AppDatabase.forTesting(NativeDatabase.memory())`.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'velix_med.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
