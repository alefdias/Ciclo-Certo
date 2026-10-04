// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, MedicationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeIngredientMeta = const VerificationMeta(
    'activeIngredient',
  );
  @override
  late final GeneratedColumn<String> activeIngredient = GeneratedColumn<String>(
    'active_ingredient',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _concentrationMeta = const VerificationMeta(
    'concentration',
  );
  @override
  late final GeneratedColumn<String> concentration = GeneratedColumn<String>(
    'concentration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formMeta = const VerificationMeta('form');
  @override
  late final GeneratedColumn<String> form = GeneratedColumn<String>(
    'form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tablet'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    activeIngredient,
    concentration,
    form,
    category,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active_ingredient')) {
      context.handle(
        _activeIngredientMeta,
        activeIngredient.isAcceptableOrUnknown(
          data['active_ingredient']!,
          _activeIngredientMeta,
        ),
      );
    }
    if (data.containsKey('concentration')) {
      context.handle(
        _concentrationMeta,
        concentration.isAcceptableOrUnknown(
          data['concentration']!,
          _concentrationMeta,
        ),
      );
    }
    if (data.containsKey('form')) {
      context.handle(
        _formMeta,
        form.isAcceptableOrUnknown(data['form']!, _formMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      activeIngredient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_ingredient'],
      ),
      concentration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concentration'],
      ),
      form:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}form'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class MedicationRow extends DataClass implements Insertable<MedicationRow> {
  final String id;
  final String name;
  final String? activeIngredient;
  final String? concentration;
  final String form;
  final String category;
  final String? notes;
  final DateTime createdAt;
  const MedicationRow({
    required this.id,
    required this.name,
    this.activeIngredient,
    this.concentration,
    required this.form,
    required this.category,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || activeIngredient != null) {
      map['active_ingredient'] = Variable<String>(activeIngredient);
    }
    if (!nullToAbsent || concentration != null) {
      map['concentration'] = Variable<String>(concentration);
    }
    map['form'] = Variable<String>(form);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      name: Value(name),
      activeIngredient:
          activeIngredient == null && nullToAbsent
              ? const Value.absent()
              : Value(activeIngredient),
      concentration:
          concentration == null && nullToAbsent
              ? const Value.absent()
              : Value(concentration),
      form: Value(form),
      category: Value(category),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory MedicationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      activeIngredient: serializer.fromJson<String?>(json['activeIngredient']),
      concentration: serializer.fromJson<String?>(json['concentration']),
      form: serializer.fromJson<String>(json['form']),
      category: serializer.fromJson<String>(json['category']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'activeIngredient': serializer.toJson<String?>(activeIngredient),
      'concentration': serializer.toJson<String?>(concentration),
      'form': serializer.toJson<String>(form),
      'category': serializer.toJson<String>(category),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicationRow copyWith({
    String? id,
    String? name,
    Value<String?> activeIngredient = const Value.absent(),
    Value<String?> concentration = const Value.absent(),
    String? form,
    String? category,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => MedicationRow(
    id: id ?? this.id,
    name: name ?? this.name,
    activeIngredient:
        activeIngredient.present
            ? activeIngredient.value
            : this.activeIngredient,
    concentration:
        concentration.present ? concentration.value : this.concentration,
    form: form ?? this.form,
    category: category ?? this.category,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  MedicationRow copyWithCompanion(MedicationsCompanion data) {
    return MedicationRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      activeIngredient:
          data.activeIngredient.present
              ? data.activeIngredient.value
              : this.activeIngredient,
      concentration:
          data.concentration.present
              ? data.concentration.value
              : this.concentration,
      form: data.form.present ? data.form.value : this.form,
      category: data.category.present ? data.category.value : this.category,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('activeIngredient: $activeIngredient, ')
          ..write('concentration: $concentration, ')
          ..write('form: $form, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    activeIngredient,
    concentration,
    form,
    category,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.activeIngredient == this.activeIngredient &&
          other.concentration == this.concentration &&
          other.form == this.form &&
          other.category == this.category &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class MedicationsCompanion extends UpdateCompanion<MedicationRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> activeIngredient;
  final Value<String?> concentration;
  final Value<String> form;
  final Value<String> category;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.activeIngredient = const Value.absent(),
    this.concentration = const Value.absent(),
    this.form = const Value.absent(),
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    required String id,
    required String name,
    this.activeIngredient = const Value.absent(),
    this.concentration = const Value.absent(),
    this.form = const Value.absent(),
    this.category = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<MedicationRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? activeIngredient,
    Expression<String>? concentration,
    Expression<String>? form,
    Expression<String>? category,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (activeIngredient != null) 'active_ingredient': activeIngredient,
      if (concentration != null) 'concentration': concentration,
      if (form != null) 'form': form,
      if (category != null) 'category': category,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? activeIngredient,
    Value<String?>? concentration,
    Value<String>? form,
    Value<String>? category,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      concentration: concentration ?? this.concentration,
      form: form ?? this.form,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (activeIngredient.present) {
      map['active_ingredient'] = Variable<String>(activeIngredient.value);
    }
    if (concentration.present) {
      map['concentration'] = Variable<String>(concentration.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(form.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('activeIngredient: $activeIngredient, ')
          ..write('concentration: $concentration, ')
          ..write('form: $form, ')
          ..write('category: $category, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreatmentsTable extends Treatments
    with TableInfo<$TreatmentsTable, TreatmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreatmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleTypeMeta = const VerificationMeta(
    'scheduleType',
  );
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleDataMeta = const VerificationMeta(
    'scheduleData',
  );
  @override
  late final GeneratedColumn<String> scheduleData = GeneratedColumn<String>(
    'schedule_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosePerIntakeMeta = const VerificationMeta(
    'dosePerIntake',
  );
  @override
  late final GeneratedColumn<double> dosePerIntake = GeneratedColumn<double>(
    'dose_per_intake',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    startDate,
    scheduleType,
    scheduleData,
    dosePerIntake,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treatments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TreatmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
        _scheduleTypeMeta,
        scheduleType.isAcceptableOrUnknown(
          data['schedule_type']!,
          _scheduleTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleTypeMeta);
    }
    if (data.containsKey('schedule_data')) {
      context.handle(
        _scheduleDataMeta,
        scheduleData.isAcceptableOrUnknown(
          data['schedule_data']!,
          _scheduleDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduleDataMeta);
    }
    if (data.containsKey('dose_per_intake')) {
      context.handle(
        _dosePerIntakeMeta,
        dosePerIntake.isAcceptableOrUnknown(
          data['dose_per_intake']!,
          _dosePerIntakeMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TreatmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TreatmentRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      medicationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}medication_id'],
          )!,
      startDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}start_date'],
          )!,
      scheduleType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}schedule_type'],
          )!,
      scheduleData:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}schedule_data'],
          )!,
      dosePerIntake:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}dose_per_intake'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $TreatmentsTable createAlias(String alias) {
    return $TreatmentsTable(attachedDatabase, alias);
  }
}

class TreatmentRow extends DataClass implements Insertable<TreatmentRow> {
  final String id;
  final String medicationId;
  final DateTime startDate;
  final String scheduleType;

  /// JSON de [ScheduleRule].
  final String scheduleData;
  final double dosePerIntake;
  final String status;
  final DateTime createdAt;
  const TreatmentRow({
    required this.id,
    required this.medicationId,
    required this.startDate,
    required this.scheduleType,
    required this.scheduleData,
    required this.dosePerIntake,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medication_id'] = Variable<String>(medicationId);
    map['start_date'] = Variable<DateTime>(startDate);
    map['schedule_type'] = Variable<String>(scheduleType);
    map['schedule_data'] = Variable<String>(scheduleData);
    map['dose_per_intake'] = Variable<double>(dosePerIntake);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TreatmentsCompanion toCompanion(bool nullToAbsent) {
    return TreatmentsCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      startDate: Value(startDate),
      scheduleType: Value(scheduleType),
      scheduleData: Value(scheduleData),
      dosePerIntake: Value(dosePerIntake),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory TreatmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TreatmentRow(
      id: serializer.fromJson<String>(json['id']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      scheduleData: serializer.fromJson<String>(json['scheduleData']),
      dosePerIntake: serializer.fromJson<double>(json['dosePerIntake']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicationId': serializer.toJson<String>(medicationId),
      'startDate': serializer.toJson<DateTime>(startDate),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'scheduleData': serializer.toJson<String>(scheduleData),
      'dosePerIntake': serializer.toJson<double>(dosePerIntake),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TreatmentRow copyWith({
    String? id,
    String? medicationId,
    DateTime? startDate,
    String? scheduleType,
    String? scheduleData,
    double? dosePerIntake,
    String? status,
    DateTime? createdAt,
  }) => TreatmentRow(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    startDate: startDate ?? this.startDate,
    scheduleType: scheduleType ?? this.scheduleType,
    scheduleData: scheduleData ?? this.scheduleData,
    dosePerIntake: dosePerIntake ?? this.dosePerIntake,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  TreatmentRow copyWithCompanion(TreatmentsCompanion data) {
    return TreatmentRow(
      id: data.id.present ? data.id.value : this.id,
      medicationId:
          data.medicationId.present
              ? data.medicationId.value
              : this.medicationId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      scheduleType:
          data.scheduleType.present
              ? data.scheduleType.value
              : this.scheduleType,
      scheduleData:
          data.scheduleData.present
              ? data.scheduleData.value
              : this.scheduleData,
      dosePerIntake:
          data.dosePerIntake.present
              ? data.dosePerIntake.value
              : this.dosePerIntake,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TreatmentRow(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('startDate: $startDate, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('scheduleData: $scheduleData, ')
          ..write('dosePerIntake: $dosePerIntake, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    startDate,
    scheduleType,
    scheduleData,
    dosePerIntake,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TreatmentRow &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.startDate == this.startDate &&
          other.scheduleType == this.scheduleType &&
          other.scheduleData == this.scheduleData &&
          other.dosePerIntake == this.dosePerIntake &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class TreatmentsCompanion extends UpdateCompanion<TreatmentRow> {
  final Value<String> id;
  final Value<String> medicationId;
  final Value<DateTime> startDate;
  final Value<String> scheduleType;
  final Value<String> scheduleData;
  final Value<double> dosePerIntake;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TreatmentsCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.scheduleData = const Value.absent(),
    this.dosePerIntake = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreatmentsCompanion.insert({
    required String id,
    required String medicationId,
    required DateTime startDate,
    required String scheduleType,
    required String scheduleData,
    this.dosePerIntake = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicationId = Value(medicationId),
       startDate = Value(startDate),
       scheduleType = Value(scheduleType),
       scheduleData = Value(scheduleData);
  static Insertable<TreatmentRow> custom({
    Expression<String>? id,
    Expression<String>? medicationId,
    Expression<DateTime>? startDate,
    Expression<String>? scheduleType,
    Expression<String>? scheduleData,
    Expression<double>? dosePerIntake,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (startDate != null) 'start_date': startDate,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (scheduleData != null) 'schedule_data': scheduleData,
      if (dosePerIntake != null) 'dose_per_intake': dosePerIntake,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreatmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? medicationId,
    Value<DateTime>? startDate,
    Value<String>? scheduleType,
    Value<String>? scheduleData,
    Value<double>? dosePerIntake,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TreatmentsCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      startDate: startDate ?? this.startDate,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduleData: scheduleData ?? this.scheduleData,
      dosePerIntake: dosePerIntake ?? this.dosePerIntake,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (scheduleData.present) {
      map['schedule_data'] = Variable<String>(scheduleData.value);
    }
    if (dosePerIntake.present) {
      map['dose_per_intake'] = Variable<double>(dosePerIntake.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreatmentsCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('startDate: $startDate, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('scheduleData: $scheduleData, ')
          ..write('dosePerIntake: $dosePerIntake, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DoseRecordsTable extends DoseRecords
    with TableInfo<$DoseRecordsTable, DoseRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoseRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _treatmentIdMeta = const VerificationMeta(
    'treatmentId',
  );
  @override
  late final GeneratedColumn<String> treatmentId = GeneratedColumn<String>(
    'treatment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES treatments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    treatmentId,
    scheduledAt,
    takenAt,
    quantity,
    status,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dose_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoseRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('treatment_id')) {
      context.handle(
        _treatmentIdMeta,
        treatmentId.isAcceptableOrUnknown(
          data['treatment_id']!,
          _treatmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_treatmentIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {treatmentId, scheduledAt},
  ];
  @override
  DoseRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoseRecordRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      treatmentId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}treatment_id'],
          )!,
      scheduledAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}scheduled_at'],
          )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      ),
      quantity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}quantity'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $DoseRecordsTable createAlias(String alias) {
    return $DoseRecordsTable(attachedDatabase, alias);
  }
}

class DoseRecordRow extends DataClass implements Insertable<DoseRecordRow> {
  final String id;
  final String treatmentId;
  final DateTime scheduledAt;
  final DateTime? takenAt;
  final double quantity;
  final String status;
  final String? note;
  const DoseRecordRow({
    required this.id,
    required this.treatmentId,
    required this.scheduledAt,
    this.takenAt,
    required this.quantity,
    required this.status,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['treatment_id'] = Variable<String>(treatmentId);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || takenAt != null) {
      map['taken_at'] = Variable<DateTime>(takenAt);
    }
    map['quantity'] = Variable<double>(quantity);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  DoseRecordsCompanion toCompanion(bool nullToAbsent) {
    return DoseRecordsCompanion(
      id: Value(id),
      treatmentId: Value(treatmentId),
      scheduledAt: Value(scheduledAt),
      takenAt:
          takenAt == null && nullToAbsent
              ? const Value.absent()
              : Value(takenAt),
      quantity: Value(quantity),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory DoseRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoseRecordRow(
      id: serializer.fromJson<String>(json['id']),
      treatmentId: serializer.fromJson<String>(json['treatmentId']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      takenAt: serializer.fromJson<DateTime?>(json['takenAt']),
      quantity: serializer.fromJson<double>(json['quantity']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'treatmentId': serializer.toJson<String>(treatmentId),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'takenAt': serializer.toJson<DateTime?>(takenAt),
      'quantity': serializer.toJson<double>(quantity),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
    };
  }

  DoseRecordRow copyWith({
    String? id,
    String? treatmentId,
    DateTime? scheduledAt,
    Value<DateTime?> takenAt = const Value.absent(),
    double? quantity,
    String? status,
    Value<String?> note = const Value.absent(),
  }) => DoseRecordRow(
    id: id ?? this.id,
    treatmentId: treatmentId ?? this.treatmentId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    takenAt: takenAt.present ? takenAt.value : this.takenAt,
    quantity: quantity ?? this.quantity,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
  );
  DoseRecordRow copyWithCompanion(DoseRecordsCompanion data) {
    return DoseRecordRow(
      id: data.id.present ? data.id.value : this.id,
      treatmentId:
          data.treatmentId.present ? data.treatmentId.value : this.treatmentId,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoseRecordRow(')
          ..write('id: $id, ')
          ..write('treatmentId: $treatmentId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('takenAt: $takenAt, ')
          ..write('quantity: $quantity, ')
          ..write('status: $status, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    treatmentId,
    scheduledAt,
    takenAt,
    quantity,
    status,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoseRecordRow &&
          other.id == this.id &&
          other.treatmentId == this.treatmentId &&
          other.scheduledAt == this.scheduledAt &&
          other.takenAt == this.takenAt &&
          other.quantity == this.quantity &&
          other.status == this.status &&
          other.note == this.note);
}

class DoseRecordsCompanion extends UpdateCompanion<DoseRecordRow> {
  final Value<String> id;
  final Value<String> treatmentId;
  final Value<DateTime> scheduledAt;
  final Value<DateTime?> takenAt;
  final Value<double> quantity;
  final Value<String> status;
  final Value<String?> note;
  final Value<int> rowid;
  const DoseRecordsCompanion({
    this.id = const Value.absent(),
    this.treatmentId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.quantity = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoseRecordsCompanion.insert({
    required String id,
    required String treatmentId,
    required DateTime scheduledAt,
    this.takenAt = const Value.absent(),
    required double quantity,
    required String status,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       treatmentId = Value(treatmentId),
       scheduledAt = Value(scheduledAt),
       quantity = Value(quantity),
       status = Value(status);
  static Insertable<DoseRecordRow> custom({
    Expression<String>? id,
    Expression<String>? treatmentId,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? takenAt,
    Expression<double>? quantity,
    Expression<String>? status,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (treatmentId != null) 'treatment_id': treatmentId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (takenAt != null) 'taken_at': takenAt,
      if (quantity != null) 'quantity': quantity,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoseRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? treatmentId,
    Value<DateTime>? scheduledAt,
    Value<DateTime?>? takenAt,
    Value<double>? quantity,
    Value<String>? status,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return DoseRecordsCompanion(
      id: id ?? this.id,
      treatmentId: treatmentId ?? this.treatmentId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      takenAt: takenAt ?? this.takenAt,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (treatmentId.present) {
      map['treatment_id'] = Variable<String>(treatmentId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoseRecordsCompanion(')
          ..write('id: $id, ')
          ..write('treatmentId: $treatmentId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('takenAt: $takenAt, ')
          ..write('quantity: $quantity, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StocksTable extends Stocks with TableInfo<$StocksTable, StockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCapacityMeta = const VerificationMeta(
    'totalCapacity',
  );
  @override
  late final GeneratedColumn<double> totalCapacity = GeneratedColumn<double>(
    'total_capacity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lowStockLimitMeta = const VerificationMeta(
    'lowStockLimit',
  );
  @override
  late final GeneratedColumn<double> lowStockLimit = GeneratedColumn<double>(
    'low_stock_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _expirationDateMeta = const VerificationMeta(
    'expirationDate',
  );
  @override
  late final GeneratedColumn<DateTime> expirationDate =
      GeneratedColumn<DateTime>(
        'expiration_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _batchMeta = const VerificationMeta('batch');
  @override
  late final GeneratedColumn<String> batch = GeneratedColumn<String>(
    'batch',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    medicationId,
    quantity,
    totalCapacity,
    lowStockLimit,
    expirationDate,
    batch,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('total_capacity')) {
      context.handle(
        _totalCapacityMeta,
        totalCapacity.isAcceptableOrUnknown(
          data['total_capacity']!,
          _totalCapacityMeta,
        ),
      );
    }
    if (data.containsKey('low_stock_limit')) {
      context.handle(
        _lowStockLimitMeta,
        lowStockLimit.isAcceptableOrUnknown(
          data['low_stock_limit']!,
          _lowStockLimitMeta,
        ),
      );
    }
    if (data.containsKey('expiration_date')) {
      context.handle(
        _expirationDateMeta,
        expirationDate.isAcceptableOrUnknown(
          data['expiration_date']!,
          _expirationDateMeta,
        ),
      );
    }
    if (data.containsKey('batch')) {
      context.handle(
        _batchMeta,
        batch.isAcceptableOrUnknown(data['batch']!, _batchMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {medicationId};
  @override
  StockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockRow(
      medicationId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}medication_id'],
          )!,
      quantity:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}quantity'],
          )!,
      totalCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_capacity'],
      ),
      lowStockLimit:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}low_stock_limit'],
          )!,
      expirationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiration_date'],
      ),
      batch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch'],
      ),
    );
  }

  @override
  $StocksTable createAlias(String alias) {
    return $StocksTable(attachedDatabase, alias);
  }
}

class StockRow extends DataClass implements Insertable<StockRow> {
  final String medicationId;
  final double quantity;
  final double? totalCapacity;
  final double lowStockLimit;
  final DateTime? expirationDate;
  final String? batch;
  const StockRow({
    required this.medicationId,
    required this.quantity,
    this.totalCapacity,
    required this.lowStockLimit,
    this.expirationDate,
    this.batch,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['medication_id'] = Variable<String>(medicationId);
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || totalCapacity != null) {
      map['total_capacity'] = Variable<double>(totalCapacity);
    }
    map['low_stock_limit'] = Variable<double>(lowStockLimit);
    if (!nullToAbsent || expirationDate != null) {
      map['expiration_date'] = Variable<DateTime>(expirationDate);
    }
    if (!nullToAbsent || batch != null) {
      map['batch'] = Variable<String>(batch);
    }
    return map;
  }

  StocksCompanion toCompanion(bool nullToAbsent) {
    return StocksCompanion(
      medicationId: Value(medicationId),
      quantity: Value(quantity),
      totalCapacity:
          totalCapacity == null && nullToAbsent
              ? const Value.absent()
              : Value(totalCapacity),
      lowStockLimit: Value(lowStockLimit),
      expirationDate:
          expirationDate == null && nullToAbsent
              ? const Value.absent()
              : Value(expirationDate),
      batch:
          batch == null && nullToAbsent ? const Value.absent() : Value(batch),
    );
  }

  factory StockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockRow(
      medicationId: serializer.fromJson<String>(json['medicationId']),
      quantity: serializer.fromJson<double>(json['quantity']),
      totalCapacity: serializer.fromJson<double?>(json['totalCapacity']),
      lowStockLimit: serializer.fromJson<double>(json['lowStockLimit']),
      expirationDate: serializer.fromJson<DateTime?>(json['expirationDate']),
      batch: serializer.fromJson<String?>(json['batch']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'medicationId': serializer.toJson<String>(medicationId),
      'quantity': serializer.toJson<double>(quantity),
      'totalCapacity': serializer.toJson<double?>(totalCapacity),
      'lowStockLimit': serializer.toJson<double>(lowStockLimit),
      'expirationDate': serializer.toJson<DateTime?>(expirationDate),
      'batch': serializer.toJson<String?>(batch),
    };
  }

  StockRow copyWith({
    String? medicationId,
    double? quantity,
    Value<double?> totalCapacity = const Value.absent(),
    double? lowStockLimit,
    Value<DateTime?> expirationDate = const Value.absent(),
    Value<String?> batch = const Value.absent(),
  }) => StockRow(
    medicationId: medicationId ?? this.medicationId,
    quantity: quantity ?? this.quantity,
    totalCapacity:
        totalCapacity.present ? totalCapacity.value : this.totalCapacity,
    lowStockLimit: lowStockLimit ?? this.lowStockLimit,
    expirationDate:
        expirationDate.present ? expirationDate.value : this.expirationDate,
    batch: batch.present ? batch.value : this.batch,
  );
  StockRow copyWithCompanion(StocksCompanion data) {
    return StockRow(
      medicationId:
          data.medicationId.present
              ? data.medicationId.value
              : this.medicationId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      totalCapacity:
          data.totalCapacity.present
              ? data.totalCapacity.value
              : this.totalCapacity,
      lowStockLimit:
          data.lowStockLimit.present
              ? data.lowStockLimit.value
              : this.lowStockLimit,
      expirationDate:
          data.expirationDate.present
              ? data.expirationDate.value
              : this.expirationDate,
      batch: data.batch.present ? data.batch.value : this.batch,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockRow(')
          ..write('medicationId: $medicationId, ')
          ..write('quantity: $quantity, ')
          ..write('totalCapacity: $totalCapacity, ')
          ..write('lowStockLimit: $lowStockLimit, ')
          ..write('expirationDate: $expirationDate, ')
          ..write('batch: $batch')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    medicationId,
    quantity,
    totalCapacity,
    lowStockLimit,
    expirationDate,
    batch,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockRow &&
          other.medicationId == this.medicationId &&
          other.quantity == this.quantity &&
          other.totalCapacity == this.totalCapacity &&
          other.lowStockLimit == this.lowStockLimit &&
          other.expirationDate == this.expirationDate &&
          other.batch == this.batch);
}

class StocksCompanion extends UpdateCompanion<StockRow> {
  final Value<String> medicationId;
  final Value<double> quantity;
  final Value<double?> totalCapacity;
  final Value<double> lowStockLimit;
  final Value<DateTime?> expirationDate;
  final Value<String?> batch;
  final Value<int> rowid;
  const StocksCompanion({
    this.medicationId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.totalCapacity = const Value.absent(),
    this.lowStockLimit = const Value.absent(),
    this.expirationDate = const Value.absent(),
    this.batch = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StocksCompanion.insert({
    required String medicationId,
    required double quantity,
    this.totalCapacity = const Value.absent(),
    this.lowStockLimit = const Value.absent(),
    this.expirationDate = const Value.absent(),
    this.batch = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : medicationId = Value(medicationId),
       quantity = Value(quantity);
  static Insertable<StockRow> custom({
    Expression<String>? medicationId,
    Expression<double>? quantity,
    Expression<double>? totalCapacity,
    Expression<double>? lowStockLimit,
    Expression<DateTime>? expirationDate,
    Expression<String>? batch,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (medicationId != null) 'medication_id': medicationId,
      if (quantity != null) 'quantity': quantity,
      if (totalCapacity != null) 'total_capacity': totalCapacity,
      if (lowStockLimit != null) 'low_stock_limit': lowStockLimit,
      if (expirationDate != null) 'expiration_date': expirationDate,
      if (batch != null) 'batch': batch,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StocksCompanion copyWith({
    Value<String>? medicationId,
    Value<double>? quantity,
    Value<double?>? totalCapacity,
    Value<double>? lowStockLimit,
    Value<DateTime?>? expirationDate,
    Value<String?>? batch,
    Value<int>? rowid,
  }) {
    return StocksCompanion(
      medicationId: medicationId ?? this.medicationId,
      quantity: quantity ?? this.quantity,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      lowStockLimit: lowStockLimit ?? this.lowStockLimit,
      expirationDate: expirationDate ?? this.expirationDate,
      batch: batch ?? this.batch,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (totalCapacity.present) {
      map['total_capacity'] = Variable<double>(totalCapacity.value);
    }
    if (lowStockLimit.present) {
      map['low_stock_limit'] = Variable<double>(lowStockLimit.value);
    }
    if (expirationDate.present) {
      map['expiration_date'] = Variable<DateTime>(expirationDate.value);
    }
    if (batch.present) {
      map['batch'] = Variable<String>(batch.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StocksCompanion(')
          ..write('medicationId: $medicationId, ')
          ..write('quantity: $quantity, ')
          ..write('totalCapacity: $totalCapacity, ')
          ..write('lowStockLimit: $lowStockLimit, ')
          ..write('expirationDate: $expirationDate, ')
          ..write('batch: $batch, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $TreatmentsTable treatments = $TreatmentsTable(this);
  late final $DoseRecordsTable doseRecords = $DoseRecordsTable(this);
  late final $StocksTable stocks = $StocksTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    medications,
    treatments,
    doseRecords,
    stocks,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('treatments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'treatments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('dose_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medications',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('stocks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      required String id,
      required String name,
      Value<String?> activeIngredient,
      Value<String?> concentration,
      Value<String> form,
      Value<String> category,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> activeIngredient,
      Value<String?> concentration,
      Value<String> form,
      Value<String> category,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MedicationsTableReferences
    extends BaseReferences<_$AppDatabase, $MedicationsTable, MedicationRow> {
  $$MedicationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TreatmentsTable, List<TreatmentRow>>
  _treatmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.treatments,
    aliasName: $_aliasNameGenerator(
      db.medications.id,
      db.treatments.medicationId,
    ),
  );

  $$TreatmentsTableProcessedTableManager get treatmentsRefs {
    final manager = $$TreatmentsTableTableManager(
      $_db,
      $_db.treatments,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_treatmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StocksTable, List<StockRow>> _stocksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.stocks,
    aliasName: $_aliasNameGenerator(db.medications.id, db.stocks.medicationId),
  );

  $$StocksTableProcessedTableManager get stocksRefs {
    final manager = $$StocksTableTableManager(
      $_db,
      $_db.stocks,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concentration => $composableBuilder(
    column: $table.concentration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> treatmentsRefs(
    Expression<bool> Function($$TreatmentsTableFilterComposer f) f,
  ) {
    final $$TreatmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatments,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableFilterComposer(
            $db: $db,
            $table: $db.treatments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stocksRefs(
    Expression<bool> Function($$StocksTableFilterComposer f) f,
  ) {
    final $$StocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stocks,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StocksTableFilterComposer(
            $db: $db,
            $table: $db.stocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concentration => $composableBuilder(
    column: $table.concentration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => column,
  );

  GeneratedColumn<String> get concentration => $composableBuilder(
    column: $table.concentration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> treatmentsRefs<T extends Object>(
    Expression<T> Function($$TreatmentsTableAnnotationComposer a) f,
  ) {
    final $$TreatmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatments,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.treatments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stocksRefs<T extends Object>(
    Expression<T> Function($$StocksTableAnnotationComposer a) f,
  ) {
    final $$StocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stocks,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StocksTableAnnotationComposer(
            $db: $db,
            $table: $db.stocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          MedicationRow,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (MedicationRow, $$MedicationsTableReferences),
          MedicationRow,
          PrefetchHooks Function({bool treatmentsRefs, bool stocksRefs})
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> activeIngredient = const Value.absent(),
                Value<String?> concentration = const Value.absent(),
                Value<String> form = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                name: name,
                activeIngredient: activeIngredient,
                concentration: concentration,
                form: form,
                category: category,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> activeIngredient = const Value.absent(),
                Value<String?> concentration = const Value.absent(),
                Value<String> form = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                name: name,
                activeIngredient: activeIngredient,
                concentration: concentration,
                form: form,
                category: category,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MedicationsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            treatmentsRefs = false,
            stocksRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (treatmentsRefs) db.treatments,
                if (stocksRefs) db.stocks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (treatmentsRefs)
                    await $_getPrefetchedData<
                      MedicationRow,
                      $MedicationsTable,
                      TreatmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$MedicationsTableReferences
                          ._treatmentsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).treatmentsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.medicationId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (stocksRefs)
                    await $_getPrefetchedData<
                      MedicationRow,
                      $MedicationsTable,
                      StockRow
                    >(
                      currentTable: table,
                      referencedTable: $$MedicationsTableReferences
                          ._stocksRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MedicationsTableReferences(
                                db,
                                table,
                                p0,
                              ).stocksRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.medicationId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      MedicationRow,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (MedicationRow, $$MedicationsTableReferences),
      MedicationRow,
      PrefetchHooks Function({bool treatmentsRefs, bool stocksRefs})
    >;
typedef $$TreatmentsTableCreateCompanionBuilder =
    TreatmentsCompanion Function({
      required String id,
      required String medicationId,
      required DateTime startDate,
      required String scheduleType,
      required String scheduleData,
      Value<double> dosePerIntake,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TreatmentsTableUpdateCompanionBuilder =
    TreatmentsCompanion Function({
      Value<String> id,
      Value<String> medicationId,
      Value<DateTime> startDate,
      Value<String> scheduleType,
      Value<String> scheduleData,
      Value<double> dosePerIntake,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TreatmentsTableReferences
    extends BaseReferences<_$AppDatabase, $TreatmentsTable, TreatmentRow> {
  $$TreatmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(db.treatments.medicationId, db.medications.id),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<String>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DoseRecordsTable, List<DoseRecordRow>>
  _doseRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.doseRecords,
    aliasName: $_aliasNameGenerator(
      db.treatments.id,
      db.doseRecords.treatmentId,
    ),
  );

  $$DoseRecordsTableProcessedTableManager get doseRecordsRefs {
    final manager = $$DoseRecordsTableTableManager(
      $_db,
      $_db.doseRecords,
    ).filter((f) => f.treatmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_doseRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TreatmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TreatmentsTable> {
  $$TreatmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleData => $composableBuilder(
    column: $table.scheduleData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dosePerIntake => $composableBuilder(
    column: $table.dosePerIntake,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> doseRecordsRefs(
    Expression<bool> Function($$DoseRecordsTableFilterComposer f) f,
  ) {
    final $$DoseRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doseRecords,
      getReferencedColumn: (t) => t.treatmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoseRecordsTableFilterComposer(
            $db: $db,
            $table: $db.doseRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreatmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TreatmentsTable> {
  $$TreatmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleData => $composableBuilder(
    column: $table.scheduleData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dosePerIntake => $composableBuilder(
    column: $table.dosePerIntake,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreatmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreatmentsTable> {
  $$TreatmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleData => $composableBuilder(
    column: $table.scheduleData,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dosePerIntake => $composableBuilder(
    column: $table.dosePerIntake,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> doseRecordsRefs<T extends Object>(
    Expression<T> Function($$DoseRecordsTableAnnotationComposer a) f,
  ) {
    final $$DoseRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.doseRecords,
      getReferencedColumn: (t) => t.treatmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DoseRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.doseRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreatmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreatmentsTable,
          TreatmentRow,
          $$TreatmentsTableFilterComposer,
          $$TreatmentsTableOrderingComposer,
          $$TreatmentsTableAnnotationComposer,
          $$TreatmentsTableCreateCompanionBuilder,
          $$TreatmentsTableUpdateCompanionBuilder,
          (TreatmentRow, $$TreatmentsTableReferences),
          TreatmentRow,
          PrefetchHooks Function({bool medicationId, bool doseRecordsRefs})
        > {
  $$TreatmentsTableTableManager(_$AppDatabase db, $TreatmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TreatmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TreatmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TreatmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicationId = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<String> scheduleData = const Value.absent(),
                Value<double> dosePerIntake = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreatmentsCompanion(
                id: id,
                medicationId: medicationId,
                startDate: startDate,
                scheduleType: scheduleType,
                scheduleData: scheduleData,
                dosePerIntake: dosePerIntake,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicationId,
                required DateTime startDate,
                required String scheduleType,
                required String scheduleData,
                Value<double> dosePerIntake = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreatmentsCompanion.insert(
                id: id,
                medicationId: medicationId,
                startDate: startDate,
                scheduleType: scheduleType,
                scheduleData: scheduleData,
                dosePerIntake: dosePerIntake,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$TreatmentsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            medicationId = false,
            doseRecordsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (doseRecordsRefs) db.doseRecords],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (medicationId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.medicationId,
                            referencedTable: $$TreatmentsTableReferences
                                ._medicationIdTable(db),
                            referencedColumn:
                                $$TreatmentsTableReferences
                                    ._medicationIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (doseRecordsRefs)
                    await $_getPrefetchedData<
                      TreatmentRow,
                      $TreatmentsTable,
                      DoseRecordRow
                    >(
                      currentTable: table,
                      referencedTable: $$TreatmentsTableReferences
                          ._doseRecordsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$TreatmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).doseRecordsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.treatmentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TreatmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreatmentsTable,
      TreatmentRow,
      $$TreatmentsTableFilterComposer,
      $$TreatmentsTableOrderingComposer,
      $$TreatmentsTableAnnotationComposer,
      $$TreatmentsTableCreateCompanionBuilder,
      $$TreatmentsTableUpdateCompanionBuilder,
      (TreatmentRow, $$TreatmentsTableReferences),
      TreatmentRow,
      PrefetchHooks Function({bool medicationId, bool doseRecordsRefs})
    >;
typedef $$DoseRecordsTableCreateCompanionBuilder =
    DoseRecordsCompanion Function({
      required String id,
      required String treatmentId,
      required DateTime scheduledAt,
      Value<DateTime?> takenAt,
      required double quantity,
      required String status,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$DoseRecordsTableUpdateCompanionBuilder =
    DoseRecordsCompanion Function({
      Value<String> id,
      Value<String> treatmentId,
      Value<DateTime> scheduledAt,
      Value<DateTime?> takenAt,
      Value<double> quantity,
      Value<String> status,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$DoseRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $DoseRecordsTable, DoseRecordRow> {
  $$DoseRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TreatmentsTable _treatmentIdTable(_$AppDatabase db) =>
      db.treatments.createAlias(
        $_aliasNameGenerator(db.doseRecords.treatmentId, db.treatments.id),
      );

  $$TreatmentsTableProcessedTableManager get treatmentId {
    final $_column = $_itemColumn<String>('treatment_id')!;

    final manager = $$TreatmentsTableTableManager(
      $_db,
      $_db.treatments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_treatmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DoseRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $DoseRecordsTable> {
  $$DoseRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$TreatmentsTableFilterComposer get treatmentId {
    final $$TreatmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatmentId,
      referencedTable: $db.treatments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableFilterComposer(
            $db: $db,
            $table: $db.treatments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DoseRecordsTable> {
  $$DoseRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$TreatmentsTableOrderingComposer get treatmentId {
    final $$TreatmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatmentId,
      referencedTable: $db.treatments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableOrderingComposer(
            $db: $db,
            $table: $db.treatments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoseRecordsTable> {
  $$DoseRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$TreatmentsTableAnnotationComposer get treatmentId {
    final $$TreatmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatmentId,
      referencedTable: $db.treatments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.treatments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DoseRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DoseRecordsTable,
          DoseRecordRow,
          $$DoseRecordsTableFilterComposer,
          $$DoseRecordsTableOrderingComposer,
          $$DoseRecordsTableAnnotationComposer,
          $$DoseRecordsTableCreateCompanionBuilder,
          $$DoseRecordsTableUpdateCompanionBuilder,
          (DoseRecordRow, $$DoseRecordsTableReferences),
          DoseRecordRow,
          PrefetchHooks Function({bool treatmentId})
        > {
  $$DoseRecordsTableTableManager(_$AppDatabase db, $DoseRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DoseRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$DoseRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$DoseRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> treatmentId = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<DateTime?> takenAt = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoseRecordsCompanion(
                id: id,
                treatmentId: treatmentId,
                scheduledAt: scheduledAt,
                takenAt: takenAt,
                quantity: quantity,
                status: status,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String treatmentId,
                required DateTime scheduledAt,
                Value<DateTime?> takenAt = const Value.absent(),
                required double quantity,
                required String status,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoseRecordsCompanion.insert(
                id: id,
                treatmentId: treatmentId,
                scheduledAt: scheduledAt,
                takenAt: takenAt,
                quantity: quantity,
                status: status,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$DoseRecordsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({treatmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (treatmentId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.treatmentId,
                            referencedTable: $$DoseRecordsTableReferences
                                ._treatmentIdTable(db),
                            referencedColumn:
                                $$DoseRecordsTableReferences
                                    ._treatmentIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DoseRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DoseRecordsTable,
      DoseRecordRow,
      $$DoseRecordsTableFilterComposer,
      $$DoseRecordsTableOrderingComposer,
      $$DoseRecordsTableAnnotationComposer,
      $$DoseRecordsTableCreateCompanionBuilder,
      $$DoseRecordsTableUpdateCompanionBuilder,
      (DoseRecordRow, $$DoseRecordsTableReferences),
      DoseRecordRow,
      PrefetchHooks Function({bool treatmentId})
    >;
typedef $$StocksTableCreateCompanionBuilder =
    StocksCompanion Function({
      required String medicationId,
      required double quantity,
      Value<double?> totalCapacity,
      Value<double> lowStockLimit,
      Value<DateTime?> expirationDate,
      Value<String?> batch,
      Value<int> rowid,
    });
typedef $$StocksTableUpdateCompanionBuilder =
    StocksCompanion Function({
      Value<String> medicationId,
      Value<double> quantity,
      Value<double?> totalCapacity,
      Value<double> lowStockLimit,
      Value<DateTime?> expirationDate,
      Value<String?> batch,
      Value<int> rowid,
    });

final class $$StocksTableReferences
    extends BaseReferences<_$AppDatabase, $StocksTable, StockRow> {
  $$StocksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicationsTable _medicationIdTable(_$AppDatabase db) =>
      db.medications.createAlias(
        $_aliasNameGenerator(db.stocks.medicationId, db.medications.id),
      );

  $$MedicationsTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<String>('medication_id')!;

    final manager = $$MedicationsTableTableManager(
      $_db,
      $_db.medications,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StocksTableFilterComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCapacity => $composableBuilder(
    column: $table.totalCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lowStockLimit => $composableBuilder(
    column: $table.lowStockLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expirationDate => $composableBuilder(
    column: $table.expirationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batch => $composableBuilder(
    column: $table.batch,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicationsTableFilterComposer get medicationId {
    final $$MedicationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableFilterComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StocksTableOrderingComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCapacity => $composableBuilder(
    column: $table.totalCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lowStockLimit => $composableBuilder(
    column: $table.lowStockLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expirationDate => $composableBuilder(
    column: $table.expirationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batch => $composableBuilder(
    column: $table.batch,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicationsTableOrderingComposer get medicationId {
    final $$MedicationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableOrderingComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get totalCapacity => $composableBuilder(
    column: $table.totalCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lowStockLimit => $composableBuilder(
    column: $table.lowStockLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expirationDate => $composableBuilder(
    column: $table.expirationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batch =>
      $composableBuilder(column: $table.batch, builder: (column) => column);

  $$MedicationsTableAnnotationComposer get medicationId {
    final $$MedicationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medications,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableAnnotationComposer(
            $db: $db,
            $table: $db.medications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StocksTable,
          StockRow,
          $$StocksTableFilterComposer,
          $$StocksTableOrderingComposer,
          $$StocksTableAnnotationComposer,
          $$StocksTableCreateCompanionBuilder,
          $$StocksTableUpdateCompanionBuilder,
          (StockRow, $$StocksTableReferences),
          StockRow,
          PrefetchHooks Function({bool medicationId})
        > {
  $$StocksTableTableManager(_$AppDatabase db, $StocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$StocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$StocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$StocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> medicationId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double?> totalCapacity = const Value.absent(),
                Value<double> lowStockLimit = const Value.absent(),
                Value<DateTime?> expirationDate = const Value.absent(),
                Value<String?> batch = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksCompanion(
                medicationId: medicationId,
                quantity: quantity,
                totalCapacity: totalCapacity,
                lowStockLimit: lowStockLimit,
                expirationDate: expirationDate,
                batch: batch,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String medicationId,
                required double quantity,
                Value<double?> totalCapacity = const Value.absent(),
                Value<double> lowStockLimit = const Value.absent(),
                Value<DateTime?> expirationDate = const Value.absent(),
                Value<String?> batch = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksCompanion.insert(
                medicationId: medicationId,
                quantity: quantity,
                totalCapacity: totalCapacity,
                lowStockLimit: lowStockLimit,
                expirationDate: expirationDate,
                batch: batch,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$StocksTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({medicationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (medicationId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.medicationId,
                            referencedTable: $$StocksTableReferences
                                ._medicationIdTable(db),
                            referencedColumn:
                                $$StocksTableReferences
                                    ._medicationIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StocksTable,
      StockRow,
      $$StocksTableFilterComposer,
      $$StocksTableOrderingComposer,
      $$StocksTableAnnotationComposer,
      $$StocksTableCreateCompanionBuilder,
      $$StocksTableUpdateCompanionBuilder,
      (StockRow, $$StocksTableReferences),
      StockRow,
      PrefetchHooks Function({bool medicationId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$TreatmentsTableTableManager get treatments =>
      $$TreatmentsTableTableManager(_db, _db.treatments);
  $$DoseRecordsTableTableManager get doseRecords =>
      $$DoseRecordsTableTableManager(_db, _db.doseRecords);
  $$StocksTableTableManager get stocks =>
      $$StocksTableTableManager(_db, _db.stocks);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
