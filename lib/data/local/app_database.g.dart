// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DailyLearningProgressTable extends DailyLearningProgress
    with TableInfo<$DailyLearningProgressTable, DailyLearningProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLearningProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _studentKeyMeta = const VerificationMeta(
    'studentKey',
  );
  @override
  late final GeneratedColumn<String> studentKey = GeneratedColumn<String>(
    'student_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _learningDateMeta = const VerificationMeta(
    'learningDate',
  );
  @override
  late final GeneratedColumn<String> learningDate = GeneratedColumn<String>(
    'learning_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hanjaIdMeta = const VerificationMeta(
    'hanjaId',
  );
  @override
  late final GeneratedColumn<String> hanjaId = GeneratedColumn<String>(
    'hanja_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    studentKey,
    learningDate,
    hanjaId,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_learning_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyLearningProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('student_key')) {
      context.handle(
        _studentKeyMeta,
        studentKey.isAcceptableOrUnknown(data['student_key']!, _studentKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_studentKeyMeta);
    }
    if (data.containsKey('learning_date')) {
      context.handle(
        _learningDateMeta,
        learningDate.isAcceptableOrUnknown(
          data['learning_date']!,
          _learningDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningDateMeta);
    }
    if (data.containsKey('hanja_id')) {
      context.handle(
        _hanjaIdMeta,
        hanjaId.isAcceptableOrUnknown(data['hanja_id']!, _hanjaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hanjaIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {studentKey, learningDate, hanjaId};
  @override
  DailyLearningProgressData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLearningProgressData(
      studentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_key'],
      )!,
      learningDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_date'],
      )!,
      hanjaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hanja_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $DailyLearningProgressTable createAlias(String alias) {
    return $DailyLearningProgressTable(attachedDatabase, alias);
  }
}

class DailyLearningProgressData extends DataClass
    implements Insertable<DailyLearningProgressData> {
  final String studentKey;
  final String learningDate;
  final String hanjaId;
  final DateTime completedAt;
  const DailyLearningProgressData({
    required this.studentKey,
    required this.learningDate,
    required this.hanjaId,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['student_key'] = Variable<String>(studentKey);
    map['learning_date'] = Variable<String>(learningDate);
    map['hanja_id'] = Variable<String>(hanjaId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  DailyLearningProgressCompanion toCompanion(bool nullToAbsent) {
    return DailyLearningProgressCompanion(
      studentKey: Value(studentKey),
      learningDate: Value(learningDate),
      hanjaId: Value(hanjaId),
      completedAt: Value(completedAt),
    );
  }

  factory DailyLearningProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLearningProgressData(
      studentKey: serializer.fromJson<String>(json['studentKey']),
      learningDate: serializer.fromJson<String>(json['learningDate']),
      hanjaId: serializer.fromJson<String>(json['hanjaId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'studentKey': serializer.toJson<String>(studentKey),
      'learningDate': serializer.toJson<String>(learningDate),
      'hanjaId': serializer.toJson<String>(hanjaId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  DailyLearningProgressData copyWith({
    String? studentKey,
    String? learningDate,
    String? hanjaId,
    DateTime? completedAt,
  }) => DailyLearningProgressData(
    studentKey: studentKey ?? this.studentKey,
    learningDate: learningDate ?? this.learningDate,
    hanjaId: hanjaId ?? this.hanjaId,
    completedAt: completedAt ?? this.completedAt,
  );
  DailyLearningProgressData copyWithCompanion(
    DailyLearningProgressCompanion data,
  ) {
    return DailyLearningProgressData(
      studentKey: data.studentKey.present
          ? data.studentKey.value
          : this.studentKey,
      learningDate: data.learningDate.present
          ? data.learningDate.value
          : this.learningDate,
      hanjaId: data.hanjaId.present ? data.hanjaId.value : this.hanjaId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLearningProgressData(')
          ..write('studentKey: $studentKey, ')
          ..write('learningDate: $learningDate, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(studentKey, learningDate, hanjaId, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLearningProgressData &&
          other.studentKey == this.studentKey &&
          other.learningDate == this.learningDate &&
          other.hanjaId == this.hanjaId &&
          other.completedAt == this.completedAt);
}

class DailyLearningProgressCompanion
    extends UpdateCompanion<DailyLearningProgressData> {
  final Value<String> studentKey;
  final Value<String> learningDate;
  final Value<String> hanjaId;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const DailyLearningProgressCompanion({
    this.studentKey = const Value.absent(),
    this.learningDate = const Value.absent(),
    this.hanjaId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyLearningProgressCompanion.insert({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : studentKey = Value(studentKey),
       learningDate = Value(learningDate),
       hanjaId = Value(hanjaId),
       completedAt = Value(completedAt);
  static Insertable<DailyLearningProgressData> custom({
    Expression<String>? studentKey,
    Expression<String>? learningDate,
    Expression<String>? hanjaId,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (studentKey != null) 'student_key': studentKey,
      if (learningDate != null) 'learning_date': learningDate,
      if (hanjaId != null) 'hanja_id': hanjaId,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyLearningProgressCompanion copyWith({
    Value<String>? studentKey,
    Value<String>? learningDate,
    Value<String>? hanjaId,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return DailyLearningProgressCompanion(
      studentKey: studentKey ?? this.studentKey,
      learningDate: learningDate ?? this.learningDate,
      hanjaId: hanjaId ?? this.hanjaId,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (studentKey.present) {
      map['student_key'] = Variable<String>(studentKey.value);
    }
    if (learningDate.present) {
      map['learning_date'] = Variable<String>(learningDate.value);
    }
    if (hanjaId.present) {
      map['hanja_id'] = Variable<String>(hanjaId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLearningProgressCompanion(')
          ..write('studentKey: $studentKey, ')
          ..write('learningDate: $learningDate, ')
          ..write('hanjaId: $hanjaId, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalXpEventsTable extends LocalXpEvents
    with TableInfo<$LocalXpEventsTable, LocalXpEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalXpEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentKeyMeta = const VerificationMeta(
    'studentKey',
  );
  @override
  late final GeneratedColumn<String> studentKey = GeneratedColumn<String>(
    'student_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentKey,
    source,
    amount,
    refId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_xp_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalXpEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_key')) {
      context.handle(
        _studentKeyMeta,
        studentKey.isAcceptableOrUnknown(data['student_key']!, _studentKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_studentKeyMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalXpEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalXpEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_key'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalXpEventsTable createAlias(String alias) {
    return $LocalXpEventsTable(attachedDatabase, alias);
  }
}

class LocalXpEvent extends DataClass implements Insertable<LocalXpEvent> {
  final String id;
  final String studentKey;
  final String source;
  final int amount;
  final String? refId;
  final DateTime createdAt;
  const LocalXpEvent({
    required this.id,
    required this.studentKey,
    required this.source,
    required this.amount,
    this.refId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_key'] = Variable<String>(studentKey);
    map['source'] = Variable<String>(source);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalXpEventsCompanion toCompanion(bool nullToAbsent) {
    return LocalXpEventsCompanion(
      id: Value(id),
      studentKey: Value(studentKey),
      source: Value(source),
      amount: Value(amount),
      refId: refId == null && nullToAbsent
          ? const Value.absent()
          : Value(refId),
      createdAt: Value(createdAt),
    );
  }

  factory LocalXpEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalXpEvent(
      id: serializer.fromJson<String>(json['id']),
      studentKey: serializer.fromJson<String>(json['studentKey']),
      source: serializer.fromJson<String>(json['source']),
      amount: serializer.fromJson<int>(json['amount']),
      refId: serializer.fromJson<String?>(json['refId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentKey': serializer.toJson<String>(studentKey),
      'source': serializer.toJson<String>(source),
      'amount': serializer.toJson<int>(amount),
      'refId': serializer.toJson<String?>(refId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalXpEvent copyWith({
    String? id,
    String? studentKey,
    String? source,
    int? amount,
    Value<String?> refId = const Value.absent(),
    DateTime? createdAt,
  }) => LocalXpEvent(
    id: id ?? this.id,
    studentKey: studentKey ?? this.studentKey,
    source: source ?? this.source,
    amount: amount ?? this.amount,
    refId: refId.present ? refId.value : this.refId,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalXpEvent copyWithCompanion(LocalXpEventsCompanion data) {
    return LocalXpEvent(
      id: data.id.present ? data.id.value : this.id,
      studentKey: data.studentKey.present
          ? data.studentKey.value
          : this.studentKey,
      source: data.source.present ? data.source.value : this.source,
      amount: data.amount.present ? data.amount.value : this.amount,
      refId: data.refId.present ? data.refId.value : this.refId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalXpEvent(')
          ..write('id: $id, ')
          ..write('studentKey: $studentKey, ')
          ..write('source: $source, ')
          ..write('amount: $amount, ')
          ..write('refId: $refId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, studentKey, source, amount, refId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalXpEvent &&
          other.id == this.id &&
          other.studentKey == this.studentKey &&
          other.source == this.source &&
          other.amount == this.amount &&
          other.refId == this.refId &&
          other.createdAt == this.createdAt);
}

class LocalXpEventsCompanion extends UpdateCompanion<LocalXpEvent> {
  final Value<String> id;
  final Value<String> studentKey;
  final Value<String> source;
  final Value<int> amount;
  final Value<String?> refId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalXpEventsCompanion({
    this.id = const Value.absent(),
    this.studentKey = const Value.absent(),
    this.source = const Value.absent(),
    this.amount = const Value.absent(),
    this.refId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalXpEventsCompanion.insert({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    this.refId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentKey = Value(studentKey),
       source = Value(source),
       amount = Value(amount),
       createdAt = Value(createdAt);
  static Insertable<LocalXpEvent> custom({
    Expression<String>? id,
    Expression<String>? studentKey,
    Expression<String>? source,
    Expression<int>? amount,
    Expression<String>? refId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentKey != null) 'student_key': studentKey,
      if (source != null) 'source': source,
      if (amount != null) 'amount': amount,
      if (refId != null) 'ref_id': refId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalXpEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentKey,
    Value<String>? source,
    Value<int>? amount,
    Value<String?>? refId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalXpEventsCompanion(
      id: id ?? this.id,
      studentKey: studentKey ?? this.studentKey,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      refId: refId ?? this.refId,
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
    if (studentKey.present) {
      map['student_key'] = Variable<String>(studentKey.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
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
    return (StringBuffer('LocalXpEventsCompanion(')
          ..write('id: $id, ')
          ..write('studentKey: $studentKey, ')
          ..write('source: $source, ')
          ..write('amount: $amount, ')
          ..write('refId: $refId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalGameResultsTable extends LocalGameResults
    with TableInfo<$LocalGameResultsTable, LocalGameResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGameResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentKeyMeta = const VerificationMeta(
    'studentKey',
  );
  @override
  late final GeneratedColumn<String> studentKey = GeneratedColumn<String>(
    'student_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _learningDateMeta = const VerificationMeta(
    'learningDate',
  );
  @override
  late final GeneratedColumn<String> learningDate = GeneratedColumn<String>(
    'learning_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSecMeta = const VerificationMeta(
    'timeSec',
  );
  @override
  late final GeneratedColumn<int> timeSec = GeneratedColumn<int>(
    'time_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentKey,
    learningDate,
    score,
    correctCount,
    totalCount,
    timeSec,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_game_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalGameResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_key')) {
      context.handle(
        _studentKeyMeta,
        studentKey.isAcceptableOrUnknown(data['student_key']!, _studentKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_studentKeyMeta);
    }
    if (data.containsKey('learning_date')) {
      context.handle(
        _learningDateMeta,
        learningDate.isAcceptableOrUnknown(
          data['learning_date']!,
          _learningDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningDateMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctCountMeta);
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCountMeta);
    }
    if (data.containsKey('time_sec')) {
      context.handle(
        _timeSecMeta,
        timeSec.isAcceptableOrUnknown(data['time_sec']!, _timeSecMeta),
      );
    } else if (isInserting) {
      context.missing(_timeSecMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalGameResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGameResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_key'],
      )!,
      learningDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_date'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
      timeSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_sec'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $LocalGameResultsTable createAlias(String alias) {
    return $LocalGameResultsTable(attachedDatabase, alias);
  }
}

class LocalGameResult extends DataClass implements Insertable<LocalGameResult> {
  final String id;
  final String studentKey;
  final String learningDate;
  final int score;
  final int correctCount;
  final int totalCount;
  final int timeSec;
  final DateTime completedAt;
  const LocalGameResult({
    required this.id,
    required this.studentKey,
    required this.learningDate,
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.timeSec,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_key'] = Variable<String>(studentKey);
    map['learning_date'] = Variable<String>(learningDate);
    map['score'] = Variable<int>(score);
    map['correct_count'] = Variable<int>(correctCount);
    map['total_count'] = Variable<int>(totalCount);
    map['time_sec'] = Variable<int>(timeSec);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  LocalGameResultsCompanion toCompanion(bool nullToAbsent) {
    return LocalGameResultsCompanion(
      id: Value(id),
      studentKey: Value(studentKey),
      learningDate: Value(learningDate),
      score: Value(score),
      correctCount: Value(correctCount),
      totalCount: Value(totalCount),
      timeSec: Value(timeSec),
      completedAt: Value(completedAt),
    );
  }

  factory LocalGameResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGameResult(
      id: serializer.fromJson<String>(json['id']),
      studentKey: serializer.fromJson<String>(json['studentKey']),
      learningDate: serializer.fromJson<String>(json['learningDate']),
      score: serializer.fromJson<int>(json['score']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
      timeSec: serializer.fromJson<int>(json['timeSec']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentKey': serializer.toJson<String>(studentKey),
      'learningDate': serializer.toJson<String>(learningDate),
      'score': serializer.toJson<int>(score),
      'correctCount': serializer.toJson<int>(correctCount),
      'totalCount': serializer.toJson<int>(totalCount),
      'timeSec': serializer.toJson<int>(timeSec),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  LocalGameResult copyWith({
    String? id,
    String? studentKey,
    String? learningDate,
    int? score,
    int? correctCount,
    int? totalCount,
    int? timeSec,
    DateTime? completedAt,
  }) => LocalGameResult(
    id: id ?? this.id,
    studentKey: studentKey ?? this.studentKey,
    learningDate: learningDate ?? this.learningDate,
    score: score ?? this.score,
    correctCount: correctCount ?? this.correctCount,
    totalCount: totalCount ?? this.totalCount,
    timeSec: timeSec ?? this.timeSec,
    completedAt: completedAt ?? this.completedAt,
  );
  LocalGameResult copyWithCompanion(LocalGameResultsCompanion data) {
    return LocalGameResult(
      id: data.id.present ? data.id.value : this.id,
      studentKey: data.studentKey.present
          ? data.studentKey.value
          : this.studentKey,
      learningDate: data.learningDate.present
          ? data.learningDate.value
          : this.learningDate,
      score: data.score.present ? data.score.value : this.score,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      timeSec: data.timeSec.present ? data.timeSec.value : this.timeSec,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGameResult(')
          ..write('id: $id, ')
          ..write('studentKey: $studentKey, ')
          ..write('learningDate: $learningDate, ')
          ..write('score: $score, ')
          ..write('correctCount: $correctCount, ')
          ..write('totalCount: $totalCount, ')
          ..write('timeSec: $timeSec, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentKey,
    learningDate,
    score,
    correctCount,
    totalCount,
    timeSec,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGameResult &&
          other.id == this.id &&
          other.studentKey == this.studentKey &&
          other.learningDate == this.learningDate &&
          other.score == this.score &&
          other.correctCount == this.correctCount &&
          other.totalCount == this.totalCount &&
          other.timeSec == this.timeSec &&
          other.completedAt == this.completedAt);
}

class LocalGameResultsCompanion extends UpdateCompanion<LocalGameResult> {
  final Value<String> id;
  final Value<String> studentKey;
  final Value<String> learningDate;
  final Value<int> score;
  final Value<int> correctCount;
  final Value<int> totalCount;
  final Value<int> timeSec;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const LocalGameResultsCompanion({
    this.id = const Value.absent(),
    this.studentKey = const Value.absent(),
    this.learningDate = const Value.absent(),
    this.score = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.timeSec = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGameResultsCompanion.insert({
    required String id,
    required String studentKey,
    required String learningDate,
    required int score,
    required int correctCount,
    required int totalCount,
    required int timeSec,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentKey = Value(studentKey),
       learningDate = Value(learningDate),
       score = Value(score),
       correctCount = Value(correctCount),
       totalCount = Value(totalCount),
       timeSec = Value(timeSec),
       completedAt = Value(completedAt);
  static Insertable<LocalGameResult> custom({
    Expression<String>? id,
    Expression<String>? studentKey,
    Expression<String>? learningDate,
    Expression<int>? score,
    Expression<int>? correctCount,
    Expression<int>? totalCount,
    Expression<int>? timeSec,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentKey != null) 'student_key': studentKey,
      if (learningDate != null) 'learning_date': learningDate,
      if (score != null) 'score': score,
      if (correctCount != null) 'correct_count': correctCount,
      if (totalCount != null) 'total_count': totalCount,
      if (timeSec != null) 'time_sec': timeSec,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGameResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentKey,
    Value<String>? learningDate,
    Value<int>? score,
    Value<int>? correctCount,
    Value<int>? totalCount,
    Value<int>? timeSec,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return LocalGameResultsCompanion(
      id: id ?? this.id,
      studentKey: studentKey ?? this.studentKey,
      learningDate: learningDate ?? this.learningDate,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      totalCount: totalCount ?? this.totalCount,
      timeSec: timeSec ?? this.timeSec,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentKey.present) {
      map['student_key'] = Variable<String>(studentKey.value);
    }
    if (learningDate.present) {
      map['learning_date'] = Variable<String>(learningDate.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (timeSec.present) {
      map['time_sec'] = Variable<int>(timeSec.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGameResultsCompanion(')
          ..write('id: $id, ')
          ..write('studentKey: $studentKey, ')
          ..write('learningDate: $learningDate, ')
          ..write('score: $score, ')
          ..write('correctCount: $correctCount, ')
          ..write('totalCount: $totalCount, ')
          ..write('timeSec: $timeSec, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalQuizResultsTable extends LocalQuizResults
    with TableInfo<$LocalQuizResultsTable, LocalQuizResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuizResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentKeyMeta = const VerificationMeta(
    'studentKey',
  );
  @override
  late final GeneratedColumn<String> studentKey = GeneratedColumn<String>(
    'student_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _learningDateMeta = const VerificationMeta(
    'learningDate',
  );
  @override
  late final GeneratedColumn<String> learningDate = GeneratedColumn<String>(
    'learning_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSecMeta = const VerificationMeta(
    'timeSec',
  );
  @override
  late final GeneratedColumn<int> timeSec = GeneratedColumn<int>(
    'time_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentKey,
    learningDate,
    score,
    correctCount,
    totalCount,
    timeSec,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_quiz_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalQuizResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_key')) {
      context.handle(
        _studentKeyMeta,
        studentKey.isAcceptableOrUnknown(data['student_key']!, _studentKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_studentKeyMeta);
    }
    if (data.containsKey('learning_date')) {
      context.handle(
        _learningDateMeta,
        learningDate.isAcceptableOrUnknown(
          data['learning_date']!,
          _learningDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningDateMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctCountMeta);
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCountMeta);
    }
    if (data.containsKey('time_sec')) {
      context.handle(
        _timeSecMeta,
        timeSec.isAcceptableOrUnknown(data['time_sec']!, _timeSecMeta),
      );
    } else if (isInserting) {
      context.missing(_timeSecMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQuizResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuizResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_key'],
      )!,
      learningDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_date'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
      timeSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_sec'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $LocalQuizResultsTable createAlias(String alias) {
    return $LocalQuizResultsTable(attachedDatabase, alias);
  }
}

class LocalQuizResult extends DataClass implements Insertable<LocalQuizResult> {
  final String id;
  final String studentKey;
  final String learningDate;
  final int score;
  final int correctCount;
  final int totalCount;
  final int timeSec;
  final DateTime completedAt;
  const LocalQuizResult({
    required this.id,
    required this.studentKey,
    required this.learningDate,
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.timeSec,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_key'] = Variable<String>(studentKey);
    map['learning_date'] = Variable<String>(learningDate);
    map['score'] = Variable<int>(score);
    map['correct_count'] = Variable<int>(correctCount);
    map['total_count'] = Variable<int>(totalCount);
    map['time_sec'] = Variable<int>(timeSec);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  LocalQuizResultsCompanion toCompanion(bool nullToAbsent) {
    return LocalQuizResultsCompanion(
      id: Value(id),
      studentKey: Value(studentKey),
      learningDate: Value(learningDate),
      score: Value(score),
      correctCount: Value(correctCount),
      totalCount: Value(totalCount),
      timeSec: Value(timeSec),
      completedAt: Value(completedAt),
    );
  }

  factory LocalQuizResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuizResult(
      id: serializer.fromJson<String>(json['id']),
      studentKey: serializer.fromJson<String>(json['studentKey']),
      learningDate: serializer.fromJson<String>(json['learningDate']),
      score: serializer.fromJson<int>(json['score']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
      timeSec: serializer.fromJson<int>(json['timeSec']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentKey': serializer.toJson<String>(studentKey),
      'learningDate': serializer.toJson<String>(learningDate),
      'score': serializer.toJson<int>(score),
      'correctCount': serializer.toJson<int>(correctCount),
      'totalCount': serializer.toJson<int>(totalCount),
      'timeSec': serializer.toJson<int>(timeSec),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  LocalQuizResult copyWith({
    String? id,
    String? studentKey,
    String? learningDate,
    int? score,
    int? correctCount,
    int? totalCount,
    int? timeSec,
    DateTime? completedAt,
  }) => LocalQuizResult(
    id: id ?? this.id,
    studentKey: studentKey ?? this.studentKey,
    learningDate: learningDate ?? this.learningDate,
    score: score ?? this.score,
    correctCount: correctCount ?? this.correctCount,
    totalCount: totalCount ?? this.totalCount,
    timeSec: timeSec ?? this.timeSec,
    completedAt: completedAt ?? this.completedAt,
  );
  LocalQuizResult copyWithCompanion(LocalQuizResultsCompanion data) {
    return LocalQuizResult(
      id: data.id.present ? data.id.value : this.id,
      studentKey: data.studentKey.present
          ? data.studentKey.value
          : this.studentKey,
      learningDate: data.learningDate.present
          ? data.learningDate.value
          : this.learningDate,
      score: data.score.present ? data.score.value : this.score,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      timeSec: data.timeSec.present ? data.timeSec.value : this.timeSec,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuizResult(')
          ..write('id: $id, ')
          ..write('studentKey: $studentKey, ')
          ..write('learningDate: $learningDate, ')
          ..write('score: $score, ')
          ..write('correctCount: $correctCount, ')
          ..write('totalCount: $totalCount, ')
          ..write('timeSec: $timeSec, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentKey,
    learningDate,
    score,
    correctCount,
    totalCount,
    timeSec,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuizResult &&
          other.id == this.id &&
          other.studentKey == this.studentKey &&
          other.learningDate == this.learningDate &&
          other.score == this.score &&
          other.correctCount == this.correctCount &&
          other.totalCount == this.totalCount &&
          other.timeSec == this.timeSec &&
          other.completedAt == this.completedAt);
}

class LocalQuizResultsCompanion extends UpdateCompanion<LocalQuizResult> {
  final Value<String> id;
  final Value<String> studentKey;
  final Value<String> learningDate;
  final Value<int> score;
  final Value<int> correctCount;
  final Value<int> totalCount;
  final Value<int> timeSec;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const LocalQuizResultsCompanion({
    this.id = const Value.absent(),
    this.studentKey = const Value.absent(),
    this.learningDate = const Value.absent(),
    this.score = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.timeSec = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQuizResultsCompanion.insert({
    required String id,
    required String studentKey,
    required String learningDate,
    required int score,
    required int correctCount,
    required int totalCount,
    required int timeSec,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentKey = Value(studentKey),
       learningDate = Value(learningDate),
       score = Value(score),
       correctCount = Value(correctCount),
       totalCount = Value(totalCount),
       timeSec = Value(timeSec),
       completedAt = Value(completedAt);
  static Insertable<LocalQuizResult> custom({
    Expression<String>? id,
    Expression<String>? studentKey,
    Expression<String>? learningDate,
    Expression<int>? score,
    Expression<int>? correctCount,
    Expression<int>? totalCount,
    Expression<int>? timeSec,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentKey != null) 'student_key': studentKey,
      if (learningDate != null) 'learning_date': learningDate,
      if (score != null) 'score': score,
      if (correctCount != null) 'correct_count': correctCount,
      if (totalCount != null) 'total_count': totalCount,
      if (timeSec != null) 'time_sec': timeSec,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQuizResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentKey,
    Value<String>? learningDate,
    Value<int>? score,
    Value<int>? correctCount,
    Value<int>? totalCount,
    Value<int>? timeSec,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return LocalQuizResultsCompanion(
      id: id ?? this.id,
      studentKey: studentKey ?? this.studentKey,
      learningDate: learningDate ?? this.learningDate,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      totalCount: totalCount ?? this.totalCount,
      timeSec: timeSec ?? this.timeSec,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentKey.present) {
      map['student_key'] = Variable<String>(studentKey.value);
    }
    if (learningDate.present) {
      map['learning_date'] = Variable<String>(learningDate.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (timeSec.present) {
      map['time_sec'] = Variable<int>(timeSec.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuizResultsCompanion(')
          ..write('id: $id, ')
          ..write('studentKey: $studentKey, ')
          ..write('learningDate: $learningDate, ')
          ..write('score: $score, ')
          ..write('correctCount: $correctCount, ')
          ..write('totalCount: $totalCount, ')
          ..write('timeSec: $timeSec, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalChallengeResultsTable extends LocalChallengeResults
    with TableInfo<$LocalChallengeResultsTable, LocalChallengeResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChallengeResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentKeyMeta = const VerificationMeta(
    'studentKey',
  );
  @override
  late final GeneratedColumn<String> studentKey = GeneratedColumn<String>(
    'student_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _learningDateMeta = const VerificationMeta(
    'learningDate',
  );
  @override
  late final GeneratedColumn<String> learningDate = GeneratedColumn<String>(
    'learning_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctCountMeta = const VerificationMeta(
    'correctCount',
  );
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
    'correct_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSecMeta = const VerificationMeta(
    'timeSec',
  );
  @override
  late final GeneratedColumn<int> timeSec = GeneratedColumn<int>(
    'time_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flippedTileCountMeta = const VerificationMeta(
    'flippedTileCount',
  );
  @override
  late final GeneratedColumn<int> flippedTileCount = GeneratedColumn<int>(
    'flipped_tile_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedXpMeta = const VerificationMeta(
    'earnedXp',
  );
  @override
  late final GeneratedColumn<int> earnedXp = GeneratedColumn<int>(
    'earned_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentKey,
    learningDate,
    mode,
    score,
    correctCount,
    totalCount,
    timeSec,
    flippedTileCount,
    earnedXp,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_challenge_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChallengeResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('student_key')) {
      context.handle(
        _studentKeyMeta,
        studentKey.isAcceptableOrUnknown(data['student_key']!, _studentKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_studentKeyMeta);
    }
    if (data.containsKey('learning_date')) {
      context.handle(
        _learningDateMeta,
        learningDate.isAcceptableOrUnknown(
          data['learning_date']!,
          _learningDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learningDateMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('correct_count')) {
      context.handle(
        _correctCountMeta,
        correctCount.isAcceptableOrUnknown(
          data['correct_count']!,
          _correctCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctCountMeta);
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCountMeta);
    }
    if (data.containsKey('time_sec')) {
      context.handle(
        _timeSecMeta,
        timeSec.isAcceptableOrUnknown(data['time_sec']!, _timeSecMeta),
      );
    } else if (isInserting) {
      context.missing(_timeSecMeta);
    }
    if (data.containsKey('flipped_tile_count')) {
      context.handle(
        _flippedTileCountMeta,
        flippedTileCount.isAcceptableOrUnknown(
          data['flipped_tile_count']!,
          _flippedTileCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_flippedTileCountMeta);
    }
    if (data.containsKey('earned_xp')) {
      context.handle(
        _earnedXpMeta,
        earnedXp.isAcceptableOrUnknown(data['earned_xp']!, _earnedXpMeta),
      );
    } else if (isInserting) {
      context.missing(_earnedXpMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalChallengeResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChallengeResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_key'],
      )!,
      learningDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learning_date'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      correctCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_count'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
      timeSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_sec'],
      )!,
      flippedTileCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flipped_tile_count'],
      )!,
      earnedXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}earned_xp'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $LocalChallengeResultsTable createAlias(String alias) {
    return $LocalChallengeResultsTable(attachedDatabase, alias);
  }
}

class LocalChallengeResult extends DataClass
    implements Insertable<LocalChallengeResult> {
  final String id;
  final String studentKey;
  final String learningDate;
  final String mode;
  final int score;
  final int correctCount;
  final int totalCount;
  final int timeSec;
  final int flippedTileCount;
  final int earnedXp;
  final DateTime completedAt;
  const LocalChallengeResult({
    required this.id,
    required this.studentKey,
    required this.learningDate,
    required this.mode,
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.timeSec,
    required this.flippedTileCount,
    required this.earnedXp,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['student_key'] = Variable<String>(studentKey);
    map['learning_date'] = Variable<String>(learningDate);
    map['mode'] = Variable<String>(mode);
    map['score'] = Variable<int>(score);
    map['correct_count'] = Variable<int>(correctCount);
    map['total_count'] = Variable<int>(totalCount);
    map['time_sec'] = Variable<int>(timeSec);
    map['flipped_tile_count'] = Variable<int>(flippedTileCount);
    map['earned_xp'] = Variable<int>(earnedXp);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  LocalChallengeResultsCompanion toCompanion(bool nullToAbsent) {
    return LocalChallengeResultsCompanion(
      id: Value(id),
      studentKey: Value(studentKey),
      learningDate: Value(learningDate),
      mode: Value(mode),
      score: Value(score),
      correctCount: Value(correctCount),
      totalCount: Value(totalCount),
      timeSec: Value(timeSec),
      flippedTileCount: Value(flippedTileCount),
      earnedXp: Value(earnedXp),
      completedAt: Value(completedAt),
    );
  }

  factory LocalChallengeResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChallengeResult(
      id: serializer.fromJson<String>(json['id']),
      studentKey: serializer.fromJson<String>(json['studentKey']),
      learningDate: serializer.fromJson<String>(json['learningDate']),
      mode: serializer.fromJson<String>(json['mode']),
      score: serializer.fromJson<int>(json['score']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
      timeSec: serializer.fromJson<int>(json['timeSec']),
      flippedTileCount: serializer.fromJson<int>(json['flippedTileCount']),
      earnedXp: serializer.fromJson<int>(json['earnedXp']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studentKey': serializer.toJson<String>(studentKey),
      'learningDate': serializer.toJson<String>(learningDate),
      'mode': serializer.toJson<String>(mode),
      'score': serializer.toJson<int>(score),
      'correctCount': serializer.toJson<int>(correctCount),
      'totalCount': serializer.toJson<int>(totalCount),
      'timeSec': serializer.toJson<int>(timeSec),
      'flippedTileCount': serializer.toJson<int>(flippedTileCount),
      'earnedXp': serializer.toJson<int>(earnedXp),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  LocalChallengeResult copyWith({
    String? id,
    String? studentKey,
    String? learningDate,
    String? mode,
    int? score,
    int? correctCount,
    int? totalCount,
    int? timeSec,
    int? flippedTileCount,
    int? earnedXp,
    DateTime? completedAt,
  }) => LocalChallengeResult(
    id: id ?? this.id,
    studentKey: studentKey ?? this.studentKey,
    learningDate: learningDate ?? this.learningDate,
    mode: mode ?? this.mode,
    score: score ?? this.score,
    correctCount: correctCount ?? this.correctCount,
    totalCount: totalCount ?? this.totalCount,
    timeSec: timeSec ?? this.timeSec,
    flippedTileCount: flippedTileCount ?? this.flippedTileCount,
    earnedXp: earnedXp ?? this.earnedXp,
    completedAt: completedAt ?? this.completedAt,
  );
  LocalChallengeResult copyWithCompanion(LocalChallengeResultsCompanion data) {
    return LocalChallengeResult(
      id: data.id.present ? data.id.value : this.id,
      studentKey: data.studentKey.present
          ? data.studentKey.value
          : this.studentKey,
      learningDate: data.learningDate.present
          ? data.learningDate.value
          : this.learningDate,
      mode: data.mode.present ? data.mode.value : this.mode,
      score: data.score.present ? data.score.value : this.score,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      timeSec: data.timeSec.present ? data.timeSec.value : this.timeSec,
      flippedTileCount: data.flippedTileCount.present
          ? data.flippedTileCount.value
          : this.flippedTileCount,
      earnedXp: data.earnedXp.present ? data.earnedXp.value : this.earnedXp,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChallengeResult(')
          ..write('id: $id, ')
          ..write('studentKey: $studentKey, ')
          ..write('learningDate: $learningDate, ')
          ..write('mode: $mode, ')
          ..write('score: $score, ')
          ..write('correctCount: $correctCount, ')
          ..write('totalCount: $totalCount, ')
          ..write('timeSec: $timeSec, ')
          ..write('flippedTileCount: $flippedTileCount, ')
          ..write('earnedXp: $earnedXp, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentKey,
    learningDate,
    mode,
    score,
    correctCount,
    totalCount,
    timeSec,
    flippedTileCount,
    earnedXp,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChallengeResult &&
          other.id == this.id &&
          other.studentKey == this.studentKey &&
          other.learningDate == this.learningDate &&
          other.mode == this.mode &&
          other.score == this.score &&
          other.correctCount == this.correctCount &&
          other.totalCount == this.totalCount &&
          other.timeSec == this.timeSec &&
          other.flippedTileCount == this.flippedTileCount &&
          other.earnedXp == this.earnedXp &&
          other.completedAt == this.completedAt);
}

class LocalChallengeResultsCompanion
    extends UpdateCompanion<LocalChallengeResult> {
  final Value<String> id;
  final Value<String> studentKey;
  final Value<String> learningDate;
  final Value<String> mode;
  final Value<int> score;
  final Value<int> correctCount;
  final Value<int> totalCount;
  final Value<int> timeSec;
  final Value<int> flippedTileCount;
  final Value<int> earnedXp;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const LocalChallengeResultsCompanion({
    this.id = const Value.absent(),
    this.studentKey = const Value.absent(),
    this.learningDate = const Value.absent(),
    this.mode = const Value.absent(),
    this.score = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.timeSec = const Value.absent(),
    this.flippedTileCount = const Value.absent(),
    this.earnedXp = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalChallengeResultsCompanion.insert({
    required String id,
    required String studentKey,
    required String learningDate,
    required String mode,
    required int score,
    required int correctCount,
    required int totalCount,
    required int timeSec,
    required int flippedTileCount,
    required int earnedXp,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studentKey = Value(studentKey),
       learningDate = Value(learningDate),
       mode = Value(mode),
       score = Value(score),
       correctCount = Value(correctCount),
       totalCount = Value(totalCount),
       timeSec = Value(timeSec),
       flippedTileCount = Value(flippedTileCount),
       earnedXp = Value(earnedXp),
       completedAt = Value(completedAt);
  static Insertable<LocalChallengeResult> custom({
    Expression<String>? id,
    Expression<String>? studentKey,
    Expression<String>? learningDate,
    Expression<String>? mode,
    Expression<int>? score,
    Expression<int>? correctCount,
    Expression<int>? totalCount,
    Expression<int>? timeSec,
    Expression<int>? flippedTileCount,
    Expression<int>? earnedXp,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentKey != null) 'student_key': studentKey,
      if (learningDate != null) 'learning_date': learningDate,
      if (mode != null) 'mode': mode,
      if (score != null) 'score': score,
      if (correctCount != null) 'correct_count': correctCount,
      if (totalCount != null) 'total_count': totalCount,
      if (timeSec != null) 'time_sec': timeSec,
      if (flippedTileCount != null) 'flipped_tile_count': flippedTileCount,
      if (earnedXp != null) 'earned_xp': earnedXp,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalChallengeResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? studentKey,
    Value<String>? learningDate,
    Value<String>? mode,
    Value<int>? score,
    Value<int>? correctCount,
    Value<int>? totalCount,
    Value<int>? timeSec,
    Value<int>? flippedTileCount,
    Value<int>? earnedXp,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return LocalChallengeResultsCompanion(
      id: id ?? this.id,
      studentKey: studentKey ?? this.studentKey,
      learningDate: learningDate ?? this.learningDate,
      mode: mode ?? this.mode,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      totalCount: totalCount ?? this.totalCount,
      timeSec: timeSec ?? this.timeSec,
      flippedTileCount: flippedTileCount ?? this.flippedTileCount,
      earnedXp: earnedXp ?? this.earnedXp,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (studentKey.present) {
      map['student_key'] = Variable<String>(studentKey.value);
    }
    if (learningDate.present) {
      map['learning_date'] = Variable<String>(learningDate.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (timeSec.present) {
      map['time_sec'] = Variable<int>(timeSec.value);
    }
    if (flippedTileCount.present) {
      map['flipped_tile_count'] = Variable<int>(flippedTileCount.value);
    }
    if (earnedXp.present) {
      map['earned_xp'] = Variable<int>(earnedXp.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChallengeResultsCompanion(')
          ..write('id: $id, ')
          ..write('studentKey: $studentKey, ')
          ..write('learningDate: $learningDate, ')
          ..write('mode: $mode, ')
          ..write('score: $score, ')
          ..write('correctCount: $correctCount, ')
          ..write('totalCount: $totalCount, ')
          ..write('timeSec: $timeSec, ')
          ..write('flippedTileCount: $flippedTileCount, ')
          ..write('earnedXp: $earnedXp, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalStudentLinksTable extends LocalStudentLinks
    with TableInfo<$LocalStudentLinksTable, LocalStudentLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStudentLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _studentKeyMeta = const VerificationMeta(
    'studentKey',
  );
  @override
  late final GeneratedColumn<String> studentKey = GeneratedColumn<String>(
    'student_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolNameMeta = const VerificationMeta(
    'schoolName',
  );
  @override
  late final GeneratedColumn<String> schoolName = GeneratedColumn<String>(
    'school_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relationTypeMeta = const VerificationMeta(
    'relationType',
  );
  @override
  late final GeneratedColumn<String> relationType = GeneratedColumn<String>(
    'relation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkedAtMeta = const VerificationMeta(
    'linkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> linkedAt = GeneratedColumn<DateTime>(
    'linked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    studentKey,
    displayName,
    schoolName,
    grade,
    relationType,
    linkedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_student_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalStudentLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('student_key')) {
      context.handle(
        _studentKeyMeta,
        studentKey.isAcceptableOrUnknown(data['student_key']!, _studentKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_studentKeyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('school_name')) {
      context.handle(
        _schoolNameMeta,
        schoolName.isAcceptableOrUnknown(data['school_name']!, _schoolNameMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('relation_type')) {
      context.handle(
        _relationTypeMeta,
        relationType.isAcceptableOrUnknown(
          data['relation_type']!,
          _relationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationTypeMeta);
    }
    if (data.containsKey('linked_at')) {
      context.handle(
        _linkedAtMeta,
        linkedAt.isAcceptableOrUnknown(data['linked_at']!, _linkedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_linkedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {studentKey, relationType};
  @override
  LocalStudentLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStudentLink(
      studentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_key'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      schoolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_name'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      ),
      relationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_type'],
      )!,
      linkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}linked_at'],
      )!,
    );
  }

  @override
  $LocalStudentLinksTable createAlias(String alias) {
    return $LocalStudentLinksTable(attachedDatabase, alias);
  }
}

class LocalStudentLink extends DataClass
    implements Insertable<LocalStudentLink> {
  final String studentKey;
  final String displayName;
  final String? schoolName;
  final int? grade;
  final String relationType;
  final DateTime linkedAt;
  const LocalStudentLink({
    required this.studentKey,
    required this.displayName,
    this.schoolName,
    this.grade,
    required this.relationType,
    required this.linkedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['student_key'] = Variable<String>(studentKey);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || schoolName != null) {
      map['school_name'] = Variable<String>(schoolName);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<int>(grade);
    }
    map['relation_type'] = Variable<String>(relationType);
    map['linked_at'] = Variable<DateTime>(linkedAt);
    return map;
  }

  LocalStudentLinksCompanion toCompanion(bool nullToAbsent) {
    return LocalStudentLinksCompanion(
      studentKey: Value(studentKey),
      displayName: Value(displayName),
      schoolName: schoolName == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolName),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      relationType: Value(relationType),
      linkedAt: Value(linkedAt),
    );
  }

  factory LocalStudentLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStudentLink(
      studentKey: serializer.fromJson<String>(json['studentKey']),
      displayName: serializer.fromJson<String>(json['displayName']),
      schoolName: serializer.fromJson<String?>(json['schoolName']),
      grade: serializer.fromJson<int?>(json['grade']),
      relationType: serializer.fromJson<String>(json['relationType']),
      linkedAt: serializer.fromJson<DateTime>(json['linkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'studentKey': serializer.toJson<String>(studentKey),
      'displayName': serializer.toJson<String>(displayName),
      'schoolName': serializer.toJson<String?>(schoolName),
      'grade': serializer.toJson<int?>(grade),
      'relationType': serializer.toJson<String>(relationType),
      'linkedAt': serializer.toJson<DateTime>(linkedAt),
    };
  }

  LocalStudentLink copyWith({
    String? studentKey,
    String? displayName,
    Value<String?> schoolName = const Value.absent(),
    Value<int?> grade = const Value.absent(),
    String? relationType,
    DateTime? linkedAt,
  }) => LocalStudentLink(
    studentKey: studentKey ?? this.studentKey,
    displayName: displayName ?? this.displayName,
    schoolName: schoolName.present ? schoolName.value : this.schoolName,
    grade: grade.present ? grade.value : this.grade,
    relationType: relationType ?? this.relationType,
    linkedAt: linkedAt ?? this.linkedAt,
  );
  LocalStudentLink copyWithCompanion(LocalStudentLinksCompanion data) {
    return LocalStudentLink(
      studentKey: data.studentKey.present
          ? data.studentKey.value
          : this.studentKey,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      schoolName: data.schoolName.present
          ? data.schoolName.value
          : this.schoolName,
      grade: data.grade.present ? data.grade.value : this.grade,
      relationType: data.relationType.present
          ? data.relationType.value
          : this.relationType,
      linkedAt: data.linkedAt.present ? data.linkedAt.value : this.linkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudentLink(')
          ..write('studentKey: $studentKey, ')
          ..write('displayName: $displayName, ')
          ..write('schoolName: $schoolName, ')
          ..write('grade: $grade, ')
          ..write('relationType: $relationType, ')
          ..write('linkedAt: $linkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    studentKey,
    displayName,
    schoolName,
    grade,
    relationType,
    linkedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStudentLink &&
          other.studentKey == this.studentKey &&
          other.displayName == this.displayName &&
          other.schoolName == this.schoolName &&
          other.grade == this.grade &&
          other.relationType == this.relationType &&
          other.linkedAt == this.linkedAt);
}

class LocalStudentLinksCompanion extends UpdateCompanion<LocalStudentLink> {
  final Value<String> studentKey;
  final Value<String> displayName;
  final Value<String?> schoolName;
  final Value<int?> grade;
  final Value<String> relationType;
  final Value<DateTime> linkedAt;
  final Value<int> rowid;
  const LocalStudentLinksCompanion({
    this.studentKey = const Value.absent(),
    this.displayName = const Value.absent(),
    this.schoolName = const Value.absent(),
    this.grade = const Value.absent(),
    this.relationType = const Value.absent(),
    this.linkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStudentLinksCompanion.insert({
    required String studentKey,
    required String displayName,
    this.schoolName = const Value.absent(),
    this.grade = const Value.absent(),
    required String relationType,
    required DateTime linkedAt,
    this.rowid = const Value.absent(),
  }) : studentKey = Value(studentKey),
       displayName = Value(displayName),
       relationType = Value(relationType),
       linkedAt = Value(linkedAt);
  static Insertable<LocalStudentLink> custom({
    Expression<String>? studentKey,
    Expression<String>? displayName,
    Expression<String>? schoolName,
    Expression<int>? grade,
    Expression<String>? relationType,
    Expression<DateTime>? linkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (studentKey != null) 'student_key': studentKey,
      if (displayName != null) 'display_name': displayName,
      if (schoolName != null) 'school_name': schoolName,
      if (grade != null) 'grade': grade,
      if (relationType != null) 'relation_type': relationType,
      if (linkedAt != null) 'linked_at': linkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalStudentLinksCompanion copyWith({
    Value<String>? studentKey,
    Value<String>? displayName,
    Value<String?>? schoolName,
    Value<int?>? grade,
    Value<String>? relationType,
    Value<DateTime>? linkedAt,
    Value<int>? rowid,
  }) {
    return LocalStudentLinksCompanion(
      studentKey: studentKey ?? this.studentKey,
      displayName: displayName ?? this.displayName,
      schoolName: schoolName ?? this.schoolName,
      grade: grade ?? this.grade,
      relationType: relationType ?? this.relationType,
      linkedAt: linkedAt ?? this.linkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (studentKey.present) {
      map['student_key'] = Variable<String>(studentKey.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (schoolName.present) {
      map['school_name'] = Variable<String>(schoolName.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (relationType.present) {
      map['relation_type'] = Variable<String>(relationType.value);
    }
    if (linkedAt.present) {
      map['linked_at'] = Variable<DateTime>(linkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudentLinksCompanion(')
          ..write('studentKey: $studentKey, ')
          ..write('displayName: $displayName, ')
          ..write('schoolName: $schoolName, ')
          ..write('grade: $grade, ')
          ..write('relationType: $relationType, ')
          ..write('linkedAt: $linkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalClassesTable extends LocalClasses
    with TableInfo<$LocalClassesTable, LocalClassesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classNameMeta = const VerificationMeta(
    'className',
  );
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
    'class_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classCodeMeta = const VerificationMeta(
    'classCode',
  );
  @override
  late final GeneratedColumn<String> classCode = GeneratedColumn<String>(
    'class_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolNameMeta = const VerificationMeta(
    'schoolName',
  );
  @override
  late final GeneratedColumn<String> schoolName = GeneratedColumn<String>(
    'school_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    className,
    classCode,
    schoolName,
    grade,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalClassesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('class_name')) {
      context.handle(
        _classNameMeta,
        className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta),
      );
    } else if (isInserting) {
      context.missing(_classNameMeta);
    }
    if (data.containsKey('class_code')) {
      context.handle(
        _classCodeMeta,
        classCode.isAcceptableOrUnknown(data['class_code']!, _classCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_classCodeMeta);
    }
    if (data.containsKey('school_name')) {
      context.handle(
        _schoolNameMeta,
        schoolName.isAcceptableOrUnknown(data['school_name']!, _schoolNameMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalClassesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalClassesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      className: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_name'],
      )!,
      classCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_code'],
      )!,
      schoolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_name'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalClassesTable createAlias(String alias) {
    return $LocalClassesTable(attachedDatabase, alias);
  }
}

class LocalClassesData extends DataClass
    implements Insertable<LocalClassesData> {
  final String id;
  final String className;
  final String classCode;
  final String? schoolName;
  final int? grade;
  final DateTime createdAt;
  const LocalClassesData({
    required this.id,
    required this.className,
    required this.classCode,
    this.schoolName,
    this.grade,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['class_name'] = Variable<String>(className);
    map['class_code'] = Variable<String>(classCode);
    if (!nullToAbsent || schoolName != null) {
      map['school_name'] = Variable<String>(schoolName);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<int>(grade);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalClassesCompanion toCompanion(bool nullToAbsent) {
    return LocalClassesCompanion(
      id: Value(id),
      className: Value(className),
      classCode: Value(classCode),
      schoolName: schoolName == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolName),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      createdAt: Value(createdAt),
    );
  }

  factory LocalClassesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalClassesData(
      id: serializer.fromJson<String>(json['id']),
      className: serializer.fromJson<String>(json['className']),
      classCode: serializer.fromJson<String>(json['classCode']),
      schoolName: serializer.fromJson<String?>(json['schoolName']),
      grade: serializer.fromJson<int?>(json['grade']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'className': serializer.toJson<String>(className),
      'classCode': serializer.toJson<String>(classCode),
      'schoolName': serializer.toJson<String?>(schoolName),
      'grade': serializer.toJson<int?>(grade),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalClassesData copyWith({
    String? id,
    String? className,
    String? classCode,
    Value<String?> schoolName = const Value.absent(),
    Value<int?> grade = const Value.absent(),
    DateTime? createdAt,
  }) => LocalClassesData(
    id: id ?? this.id,
    className: className ?? this.className,
    classCode: classCode ?? this.classCode,
    schoolName: schoolName.present ? schoolName.value : this.schoolName,
    grade: grade.present ? grade.value : this.grade,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalClassesData copyWithCompanion(LocalClassesCompanion data) {
    return LocalClassesData(
      id: data.id.present ? data.id.value : this.id,
      className: data.className.present ? data.className.value : this.className,
      classCode: data.classCode.present ? data.classCode.value : this.classCode,
      schoolName: data.schoolName.present
          ? data.schoolName.value
          : this.schoolName,
      grade: data.grade.present ? data.grade.value : this.grade,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalClassesData(')
          ..write('id: $id, ')
          ..write('className: $className, ')
          ..write('classCode: $classCode, ')
          ..write('schoolName: $schoolName, ')
          ..write('grade: $grade, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, className, classCode, schoolName, grade, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalClassesData &&
          other.id == this.id &&
          other.className == this.className &&
          other.classCode == this.classCode &&
          other.schoolName == this.schoolName &&
          other.grade == this.grade &&
          other.createdAt == this.createdAt);
}

class LocalClassesCompanion extends UpdateCompanion<LocalClassesData> {
  final Value<String> id;
  final Value<String> className;
  final Value<String> classCode;
  final Value<String?> schoolName;
  final Value<int?> grade;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalClassesCompanion({
    this.id = const Value.absent(),
    this.className = const Value.absent(),
    this.classCode = const Value.absent(),
    this.schoolName = const Value.absent(),
    this.grade = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalClassesCompanion.insert({
    required String id,
    required String className,
    required String classCode,
    this.schoolName = const Value.absent(),
    this.grade = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       className = Value(className),
       classCode = Value(classCode),
       createdAt = Value(createdAt);
  static Insertable<LocalClassesData> custom({
    Expression<String>? id,
    Expression<String>? className,
    Expression<String>? classCode,
    Expression<String>? schoolName,
    Expression<int>? grade,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (className != null) 'class_name': className,
      if (classCode != null) 'class_code': classCode,
      if (schoolName != null) 'school_name': schoolName,
      if (grade != null) 'grade': grade,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalClassesCompanion copyWith({
    Value<String>? id,
    Value<String>? className,
    Value<String>? classCode,
    Value<String?>? schoolName,
    Value<int?>? grade,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalClassesCompanion(
      id: id ?? this.id,
      className: className ?? this.className,
      classCode: classCode ?? this.classCode,
      schoolName: schoolName ?? this.schoolName,
      grade: grade ?? this.grade,
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
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (classCode.present) {
      map['class_code'] = Variable<String>(classCode.value);
    }
    if (schoolName.present) {
      map['school_name'] = Variable<String>(schoolName.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
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
    return (StringBuffer('LocalClassesCompanion(')
          ..write('id: $id, ')
          ..write('className: $className, ')
          ..write('classCode: $classCode, ')
          ..write('schoolName: $schoolName, ')
          ..write('grade: $grade, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalClassMembersTable extends LocalClassMembers
    with TableInfo<$LocalClassMembersTable, LocalClassMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalClassMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentKeyMeta = const VerificationMeta(
    'studentKey',
  );
  @override
  late final GeneratedColumn<String> studentKey = GeneratedColumn<String>(
    'student_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schoolNameMeta = const VerificationMeta(
    'schoolName',
  );
  @override
  late final GeneratedColumn<String> schoolName = GeneratedColumn<String>(
    'school_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    classId,
    studentKey,
    displayName,
    schoolName,
    grade,
    joinedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_class_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalClassMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('student_key')) {
      context.handle(
        _studentKeyMeta,
        studentKey.isAcceptableOrUnknown(data['student_key']!, _studentKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_studentKeyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('school_name')) {
      context.handle(
        _schoolNameMeta,
        schoolName.isAcceptableOrUnknown(data['school_name']!, _schoolNameMeta),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {classId, studentKey};
  @override
  LocalClassMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalClassMember(
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      studentKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_key'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      schoolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_name'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade'],
      ),
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
    );
  }

  @override
  $LocalClassMembersTable createAlias(String alias) {
    return $LocalClassMembersTable(attachedDatabase, alias);
  }
}

class LocalClassMember extends DataClass
    implements Insertable<LocalClassMember> {
  final String classId;
  final String studentKey;
  final String displayName;
  final String? schoolName;
  final int? grade;
  final DateTime joinedAt;
  const LocalClassMember({
    required this.classId,
    required this.studentKey,
    required this.displayName,
    this.schoolName,
    this.grade,
    required this.joinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['class_id'] = Variable<String>(classId);
    map['student_key'] = Variable<String>(studentKey);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || schoolName != null) {
      map['school_name'] = Variable<String>(schoolName);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<int>(grade);
    }
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  LocalClassMembersCompanion toCompanion(bool nullToAbsent) {
    return LocalClassMembersCompanion(
      classId: Value(classId),
      studentKey: Value(studentKey),
      displayName: Value(displayName),
      schoolName: schoolName == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolName),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      joinedAt: Value(joinedAt),
    );
  }

  factory LocalClassMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalClassMember(
      classId: serializer.fromJson<String>(json['classId']),
      studentKey: serializer.fromJson<String>(json['studentKey']),
      displayName: serializer.fromJson<String>(json['displayName']),
      schoolName: serializer.fromJson<String?>(json['schoolName']),
      grade: serializer.fromJson<int?>(json['grade']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'classId': serializer.toJson<String>(classId),
      'studentKey': serializer.toJson<String>(studentKey),
      'displayName': serializer.toJson<String>(displayName),
      'schoolName': serializer.toJson<String?>(schoolName),
      'grade': serializer.toJson<int?>(grade),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  LocalClassMember copyWith({
    String? classId,
    String? studentKey,
    String? displayName,
    Value<String?> schoolName = const Value.absent(),
    Value<int?> grade = const Value.absent(),
    DateTime? joinedAt,
  }) => LocalClassMember(
    classId: classId ?? this.classId,
    studentKey: studentKey ?? this.studentKey,
    displayName: displayName ?? this.displayName,
    schoolName: schoolName.present ? schoolName.value : this.schoolName,
    grade: grade.present ? grade.value : this.grade,
    joinedAt: joinedAt ?? this.joinedAt,
  );
  LocalClassMember copyWithCompanion(LocalClassMembersCompanion data) {
    return LocalClassMember(
      classId: data.classId.present ? data.classId.value : this.classId,
      studentKey: data.studentKey.present
          ? data.studentKey.value
          : this.studentKey,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      schoolName: data.schoolName.present
          ? data.schoolName.value
          : this.schoolName,
      grade: data.grade.present ? data.grade.value : this.grade,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalClassMember(')
          ..write('classId: $classId, ')
          ..write('studentKey: $studentKey, ')
          ..write('displayName: $displayName, ')
          ..write('schoolName: $schoolName, ')
          ..write('grade: $grade, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    classId,
    studentKey,
    displayName,
    schoolName,
    grade,
    joinedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalClassMember &&
          other.classId == this.classId &&
          other.studentKey == this.studentKey &&
          other.displayName == this.displayName &&
          other.schoolName == this.schoolName &&
          other.grade == this.grade &&
          other.joinedAt == this.joinedAt);
}

class LocalClassMembersCompanion extends UpdateCompanion<LocalClassMember> {
  final Value<String> classId;
  final Value<String> studentKey;
  final Value<String> displayName;
  final Value<String?> schoolName;
  final Value<int?> grade;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const LocalClassMembersCompanion({
    this.classId = const Value.absent(),
    this.studentKey = const Value.absent(),
    this.displayName = const Value.absent(),
    this.schoolName = const Value.absent(),
    this.grade = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalClassMembersCompanion.insert({
    required String classId,
    required String studentKey,
    required String displayName,
    this.schoolName = const Value.absent(),
    this.grade = const Value.absent(),
    required DateTime joinedAt,
    this.rowid = const Value.absent(),
  }) : classId = Value(classId),
       studentKey = Value(studentKey),
       displayName = Value(displayName),
       joinedAt = Value(joinedAt);
  static Insertable<LocalClassMember> custom({
    Expression<String>? classId,
    Expression<String>? studentKey,
    Expression<String>? displayName,
    Expression<String>? schoolName,
    Expression<int>? grade,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (classId != null) 'class_id': classId,
      if (studentKey != null) 'student_key': studentKey,
      if (displayName != null) 'display_name': displayName,
      if (schoolName != null) 'school_name': schoolName,
      if (grade != null) 'grade': grade,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalClassMembersCompanion copyWith({
    Value<String>? classId,
    Value<String>? studentKey,
    Value<String>? displayName,
    Value<String?>? schoolName,
    Value<int?>? grade,
    Value<DateTime>? joinedAt,
    Value<int>? rowid,
  }) {
    return LocalClassMembersCompanion(
      classId: classId ?? this.classId,
      studentKey: studentKey ?? this.studentKey,
      displayName: displayName ?? this.displayName,
      schoolName: schoolName ?? this.schoolName,
      grade: grade ?? this.grade,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (studentKey.present) {
      map['student_key'] = Variable<String>(studentKey.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (schoolName.present) {
      map['school_name'] = Variable<String>(schoolName.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalClassMembersCompanion(')
          ..write('classId: $classId, ')
          ..write('studentKey: $studentKey, ')
          ..write('displayName: $displayName, ')
          ..write('schoolName: $schoolName, ')
          ..write('grade: $grade, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalLearningEnvironmentSettingsTable
    extends LocalLearningEnvironmentSettings
    with
        TableInfo<
          $LocalLearningEnvironmentSettingsTable,
          LocalLearningEnvironmentSetting
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLearningEnvironmentSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backgroundMusicEnabledMeta =
      const VerificationMeta('backgroundMusicEnabled');
  @override
  late final GeneratedColumn<bool> backgroundMusicEnabled =
      GeneratedColumn<bool>(
        'background_music_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("background_music_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _soundEffectsEnabledMeta =
      const VerificationMeta('soundEffectsEnabled');
  @override
  late final GeneratedColumn<bool> soundEffectsEnabled = GeneratedColumn<bool>(
    'sound_effects_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sound_effects_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _strokeSoundEnabledMeta =
      const VerificationMeta('strokeSoundEnabled');
  @override
  late final GeneratedColumn<bool> strokeSoundEnabled = GeneratedColumn<bool>(
    'stroke_sound_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("stroke_sound_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    backgroundMusicEnabled,
    soundEffectsEnabled,
    strokeSoundEnabled,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_learning_environment_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalLearningEnvironmentSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('background_music_enabled')) {
      context.handle(
        _backgroundMusicEnabledMeta,
        backgroundMusicEnabled.isAcceptableOrUnknown(
          data['background_music_enabled']!,
          _backgroundMusicEnabledMeta,
        ),
      );
    }
    if (data.containsKey('sound_effects_enabled')) {
      context.handle(
        _soundEffectsEnabledMeta,
        soundEffectsEnabled.isAcceptableOrUnknown(
          data['sound_effects_enabled']!,
          _soundEffectsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('stroke_sound_enabled')) {
      context.handle(
        _strokeSoundEnabledMeta,
        strokeSoundEnabled.isAcceptableOrUnknown(
          data['stroke_sound_enabled']!,
          _strokeSoundEnabledMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalLearningEnvironmentSetting map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLearningEnvironmentSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      backgroundMusicEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}background_music_enabled'],
      )!,
      soundEffectsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sound_effects_enabled'],
      )!,
      strokeSoundEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}stroke_sound_enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalLearningEnvironmentSettingsTable createAlias(String alias) {
    return $LocalLearningEnvironmentSettingsTable(attachedDatabase, alias);
  }
}

class LocalLearningEnvironmentSetting extends DataClass
    implements Insertable<LocalLearningEnvironmentSetting> {
  final String id;
  final bool backgroundMusicEnabled;
  final bool soundEffectsEnabled;
  final bool strokeSoundEnabled;
  final DateTime updatedAt;
  const LocalLearningEnvironmentSetting({
    required this.id,
    required this.backgroundMusicEnabled,
    required this.soundEffectsEnabled,
    required this.strokeSoundEnabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['background_music_enabled'] = Variable<bool>(backgroundMusicEnabled);
    map['sound_effects_enabled'] = Variable<bool>(soundEffectsEnabled);
    map['stroke_sound_enabled'] = Variable<bool>(strokeSoundEnabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalLearningEnvironmentSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalLearningEnvironmentSettingsCompanion(
      id: Value(id),
      backgroundMusicEnabled: Value(backgroundMusicEnabled),
      soundEffectsEnabled: Value(soundEffectsEnabled),
      strokeSoundEnabled: Value(strokeSoundEnabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalLearningEnvironmentSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLearningEnvironmentSetting(
      id: serializer.fromJson<String>(json['id']),
      backgroundMusicEnabled: serializer.fromJson<bool>(
        json['backgroundMusicEnabled'],
      ),
      soundEffectsEnabled: serializer.fromJson<bool>(
        json['soundEffectsEnabled'],
      ),
      strokeSoundEnabled: serializer.fromJson<bool>(json['strokeSoundEnabled']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'backgroundMusicEnabled': serializer.toJson<bool>(backgroundMusicEnabled),
      'soundEffectsEnabled': serializer.toJson<bool>(soundEffectsEnabled),
      'strokeSoundEnabled': serializer.toJson<bool>(strokeSoundEnabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalLearningEnvironmentSetting copyWith({
    String? id,
    bool? backgroundMusicEnabled,
    bool? soundEffectsEnabled,
    bool? strokeSoundEnabled,
    DateTime? updatedAt,
  }) => LocalLearningEnvironmentSetting(
    id: id ?? this.id,
    backgroundMusicEnabled:
        backgroundMusicEnabled ?? this.backgroundMusicEnabled,
    soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
    strokeSoundEnabled: strokeSoundEnabled ?? this.strokeSoundEnabled,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalLearningEnvironmentSetting copyWithCompanion(
    LocalLearningEnvironmentSettingsCompanion data,
  ) {
    return LocalLearningEnvironmentSetting(
      id: data.id.present ? data.id.value : this.id,
      backgroundMusicEnabled: data.backgroundMusicEnabled.present
          ? data.backgroundMusicEnabled.value
          : this.backgroundMusicEnabled,
      soundEffectsEnabled: data.soundEffectsEnabled.present
          ? data.soundEffectsEnabled.value
          : this.soundEffectsEnabled,
      strokeSoundEnabled: data.strokeSoundEnabled.present
          ? data.strokeSoundEnabled.value
          : this.strokeSoundEnabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLearningEnvironmentSetting(')
          ..write('id: $id, ')
          ..write('backgroundMusicEnabled: $backgroundMusicEnabled, ')
          ..write('soundEffectsEnabled: $soundEffectsEnabled, ')
          ..write('strokeSoundEnabled: $strokeSoundEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    backgroundMusicEnabled,
    soundEffectsEnabled,
    strokeSoundEnabled,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLearningEnvironmentSetting &&
          other.id == this.id &&
          other.backgroundMusicEnabled == this.backgroundMusicEnabled &&
          other.soundEffectsEnabled == this.soundEffectsEnabled &&
          other.strokeSoundEnabled == this.strokeSoundEnabled &&
          other.updatedAt == this.updatedAt);
}

class LocalLearningEnvironmentSettingsCompanion
    extends UpdateCompanion<LocalLearningEnvironmentSetting> {
  final Value<String> id;
  final Value<bool> backgroundMusicEnabled;
  final Value<bool> soundEffectsEnabled;
  final Value<bool> strokeSoundEnabled;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalLearningEnvironmentSettingsCompanion({
    this.id = const Value.absent(),
    this.backgroundMusicEnabled = const Value.absent(),
    this.soundEffectsEnabled = const Value.absent(),
    this.strokeSoundEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLearningEnvironmentSettingsCompanion.insert({
    required String id,
    this.backgroundMusicEnabled = const Value.absent(),
    this.soundEffectsEnabled = const Value.absent(),
    this.strokeSoundEnabled = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt);
  static Insertable<LocalLearningEnvironmentSetting> custom({
    Expression<String>? id,
    Expression<bool>? backgroundMusicEnabled,
    Expression<bool>? soundEffectsEnabled,
    Expression<bool>? strokeSoundEnabled,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (backgroundMusicEnabled != null)
        'background_music_enabled': backgroundMusicEnabled,
      if (soundEffectsEnabled != null)
        'sound_effects_enabled': soundEffectsEnabled,
      if (strokeSoundEnabled != null)
        'stroke_sound_enabled': strokeSoundEnabled,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLearningEnvironmentSettingsCompanion copyWith({
    Value<String>? id,
    Value<bool>? backgroundMusicEnabled,
    Value<bool>? soundEffectsEnabled,
    Value<bool>? strokeSoundEnabled,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalLearningEnvironmentSettingsCompanion(
      id: id ?? this.id,
      backgroundMusicEnabled:
          backgroundMusicEnabled ?? this.backgroundMusicEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      strokeSoundEnabled: strokeSoundEnabled ?? this.strokeSoundEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (backgroundMusicEnabled.present) {
      map['background_music_enabled'] = Variable<bool>(
        backgroundMusicEnabled.value,
      );
    }
    if (soundEffectsEnabled.present) {
      map['sound_effects_enabled'] = Variable<bool>(soundEffectsEnabled.value);
    }
    if (strokeSoundEnabled.present) {
      map['stroke_sound_enabled'] = Variable<bool>(strokeSoundEnabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLearningEnvironmentSettingsCompanion(')
          ..write('id: $id, ')
          ..write('backgroundMusicEnabled: $backgroundMusicEnabled, ')
          ..write('soundEffectsEnabled: $soundEffectsEnabled, ')
          ..write('strokeSoundEnabled: $strokeSoundEnabled, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalNotificationSettingsTable extends LocalNotificationSettings
    with TableInfo<$LocalNotificationSettingsTable, LocalNotificationSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalNotificationSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dailyReminderEnabledMeta =
      const VerificationMeta('dailyReminderEnabled');
  @override
  late final GeneratedColumn<bool> dailyReminderEnabled = GeneratedColumn<bool>(
    'daily_reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("daily_reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderHourMeta = const VerificationMeta(
    'reminderHour',
  );
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(18),
  );
  static const VerificationMeta _reminderMinuteMeta = const VerificationMeta(
    'reminderMinute',
  );
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
    'reminder_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyReminderEnabled,
    reminderHour,
    reminderMinute,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_notification_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalNotificationSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('daily_reminder_enabled')) {
      context.handle(
        _dailyReminderEnabledMeta,
        dailyReminderEnabled.isAcceptableOrUnknown(
          data['daily_reminder_enabled']!,
          _dailyReminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(
          data['reminder_hour']!,
          _reminderHourMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
        _reminderMinuteMeta,
        reminderMinute.isAcceptableOrUnknown(
          data['reminder_minute']!,
          _reminderMinuteMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalNotificationSetting map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNotificationSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dailyReminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}daily_reminder_enabled'],
      )!,
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      )!,
      reminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalNotificationSettingsTable createAlias(String alias) {
    return $LocalNotificationSettingsTable(attachedDatabase, alias);
  }
}

class LocalNotificationSetting extends DataClass
    implements Insertable<LocalNotificationSetting> {
  final String id;
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final DateTime updatedAt;
  const LocalNotificationSetting({
    required this.id,
    required this.dailyReminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['daily_reminder_enabled'] = Variable<bool>(dailyReminderEnabled);
    map['reminder_hour'] = Variable<int>(reminderHour);
    map['reminder_minute'] = Variable<int>(reminderMinute);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalNotificationSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalNotificationSettingsCompanion(
      id: Value(id),
      dailyReminderEnabled: Value(dailyReminderEnabled),
      reminderHour: Value(reminderHour),
      reminderMinute: Value(reminderMinute),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalNotificationSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNotificationSetting(
      id: serializer.fromJson<String>(json['id']),
      dailyReminderEnabled: serializer.fromJson<bool>(
        json['dailyReminderEnabled'],
      ),
      reminderHour: serializer.fromJson<int>(json['reminderHour']),
      reminderMinute: serializer.fromJson<int>(json['reminderMinute']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dailyReminderEnabled': serializer.toJson<bool>(dailyReminderEnabled),
      'reminderHour': serializer.toJson<int>(reminderHour),
      'reminderMinute': serializer.toJson<int>(reminderMinute),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalNotificationSetting copyWith({
    String? id,
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    DateTime? updatedAt,
  }) => LocalNotificationSetting(
    id: id ?? this.id,
    dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalNotificationSetting copyWithCompanion(
    LocalNotificationSettingsCompanion data,
  ) {
    return LocalNotificationSetting(
      id: data.id.present ? data.id.value : this.id,
      dailyReminderEnabled: data.dailyReminderEnabled.present
          ? data.dailyReminderEnabled.value
          : this.dailyReminderEnabled,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
      reminderMinute: data.reminderMinute.present
          ? data.reminderMinute.value
          : this.reminderMinute,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotificationSetting(')
          ..write('id: $id, ')
          ..write('dailyReminderEnabled: $dailyReminderEnabled, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dailyReminderEnabled,
    reminderHour,
    reminderMinute,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNotificationSetting &&
          other.id == this.id &&
          other.dailyReminderEnabled == this.dailyReminderEnabled &&
          other.reminderHour == this.reminderHour &&
          other.reminderMinute == this.reminderMinute &&
          other.updatedAt == this.updatedAt);
}

class LocalNotificationSettingsCompanion
    extends UpdateCompanion<LocalNotificationSetting> {
  final Value<String> id;
  final Value<bool> dailyReminderEnabled;
  final Value<int> reminderHour;
  final Value<int> reminderMinute;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalNotificationSettingsCompanion({
    this.id = const Value.absent(),
    this.dailyReminderEnabled = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalNotificationSettingsCompanion.insert({
    required String id,
    this.dailyReminderEnabled = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt);
  static Insertable<LocalNotificationSetting> custom({
    Expression<String>? id,
    Expression<bool>? dailyReminderEnabled,
    Expression<int>? reminderHour,
    Expression<int>? reminderMinute,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyReminderEnabled != null)
        'daily_reminder_enabled': dailyReminderEnabled,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalNotificationSettingsCompanion copyWith({
    Value<String>? id,
    Value<bool>? dailyReminderEnabled,
    Value<int>? reminderHour,
    Value<int>? reminderMinute,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalNotificationSettingsCompanion(
      id: id ?? this.id,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dailyReminderEnabled.present) {
      map['daily_reminder_enabled'] = Variable<bool>(
        dailyReminderEnabled.value,
      );
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotificationSettingsCompanion(')
          ..write('id: $id, ')
          ..write('dailyReminderEnabled: $dailyReminderEnabled, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPendingSyncOperationsTable extends LocalPendingSyncOperations
    with
        TableInfo<$LocalPendingSyncOperationsTable, LocalPendingSyncOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPendingSyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationType,
    targetTable,
    payloadJson,
    attemptCount,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_pending_sync_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPendingSyncOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPendingSyncOperation map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPendingSyncOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalPendingSyncOperationsTable createAlias(String alias) {
    return $LocalPendingSyncOperationsTable(attachedDatabase, alias);
  }
}

class LocalPendingSyncOperation extends DataClass
    implements Insertable<LocalPendingSyncOperation> {
  final String id;
  final String operationType;
  final String targetTable;
  final String payloadJson;
  final int attemptCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalPendingSyncOperation({
    required this.id,
    required this.operationType,
    required this.targetTable,
    required this.payloadJson,
    required this.attemptCount,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation_type'] = Variable<String>(operationType);
    map['target_table'] = Variable<String>(targetTable);
    map['payload_json'] = Variable<String>(payloadJson);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalPendingSyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return LocalPendingSyncOperationsCompanion(
      id: Value(id),
      operationType: Value(operationType),
      targetTable: Value(targetTable),
      payloadJson: Value(payloadJson),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalPendingSyncOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPendingSyncOperation(
      id: serializer.fromJson<String>(json['id']),
      operationType: serializer.fromJson<String>(json['operationType']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operationType': serializer.toJson<String>(operationType),
      'targetTable': serializer.toJson<String>(targetTable),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalPendingSyncOperation copyWith({
    String? id,
    String? operationType,
    String? targetTable,
    String? payloadJson,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalPendingSyncOperation(
    id: id ?? this.id,
    operationType: operationType ?? this.operationType,
    targetTable: targetTable ?? this.targetTable,
    payloadJson: payloadJson ?? this.payloadJson,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalPendingSyncOperation copyWithCompanion(
    LocalPendingSyncOperationsCompanion data,
  ) {
    return LocalPendingSyncOperation(
      id: data.id.present ? data.id.value : this.id,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPendingSyncOperation(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('targetTable: $targetTable, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationType,
    targetTable,
    payloadJson,
    attemptCount,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPendingSyncOperation &&
          other.id == this.id &&
          other.operationType == this.operationType &&
          other.targetTable == this.targetTable &&
          other.payloadJson == this.payloadJson &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalPendingSyncOperationsCompanion
    extends UpdateCompanion<LocalPendingSyncOperation> {
  final Value<String> id;
  final Value<String> operationType;
  final Value<String> targetTable;
  final Value<String> payloadJson;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalPendingSyncOperationsCompanion({
    this.id = const Value.absent(),
    this.operationType = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPendingSyncOperationsCompanion.insert({
    required String id,
    required String operationType,
    required String targetTable,
    required String payloadJson,
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operationType = Value(operationType),
       targetTable = Value(targetTable),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalPendingSyncOperation> custom({
    Expression<String>? id,
    Expression<String>? operationType,
    Expression<String>? targetTable,
    Expression<String>? payloadJson,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationType != null) 'operation_type': operationType,
      if (targetTable != null) 'target_table': targetTable,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPendingSyncOperationsCompanion copyWith({
    Value<String>? id,
    Value<String>? operationType,
    Value<String>? targetTable,
    Value<String>? payloadJson,
    Value<int>? attemptCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalPendingSyncOperationsCompanion(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      targetTable: targetTable ?? this.targetTable,
      payloadJson: payloadJson ?? this.payloadJson,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPendingSyncOperationsCompanion(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('targetTable: $targetTable, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DailyLearningProgressTable dailyLearningProgress =
      $DailyLearningProgressTable(this);
  late final $LocalXpEventsTable localXpEvents = $LocalXpEventsTable(this);
  late final $LocalGameResultsTable localGameResults = $LocalGameResultsTable(
    this,
  );
  late final $LocalQuizResultsTable localQuizResults = $LocalQuizResultsTable(
    this,
  );
  late final $LocalChallengeResultsTable localChallengeResults =
      $LocalChallengeResultsTable(this);
  late final $LocalStudentLinksTable localStudentLinks =
      $LocalStudentLinksTable(this);
  late final $LocalClassesTable localClasses = $LocalClassesTable(this);
  late final $LocalClassMembersTable localClassMembers =
      $LocalClassMembersTable(this);
  late final $LocalLearningEnvironmentSettingsTable
  localLearningEnvironmentSettings = $LocalLearningEnvironmentSettingsTable(
    this,
  );
  late final $LocalNotificationSettingsTable localNotificationSettings =
      $LocalNotificationSettingsTable(this);
  late final $LocalPendingSyncOperationsTable localPendingSyncOperations =
      $LocalPendingSyncOperationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dailyLearningProgress,
    localXpEvents,
    localGameResults,
    localQuizResults,
    localChallengeResults,
    localStudentLinks,
    localClasses,
    localClassMembers,
    localLearningEnvironmentSettings,
    localNotificationSettings,
    localPendingSyncOperations,
  ];
}

typedef $$DailyLearningProgressTableCreateCompanionBuilder =
    DailyLearningProgressCompanion Function({
      required String studentKey,
      required String learningDate,
      required String hanjaId,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$DailyLearningProgressTableUpdateCompanionBuilder =
    DailyLearningProgressCompanion Function({
      Value<String> studentKey,
      Value<String> learningDate,
      Value<String> hanjaId,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$DailyLearningProgressTableFilterComposer
    extends Composer<_$AppDatabase, $DailyLearningProgressTable> {
  $$DailyLearningProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyLearningProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyLearningProgressTable> {
  $$DailyLearningProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hanjaId => $composableBuilder(
    column: $table.hanjaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyLearningProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyLearningProgressTable> {
  $$DailyLearningProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hanjaId =>
      $composableBuilder(column: $table.hanjaId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$DailyLearningProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyLearningProgressTable,
          DailyLearningProgressData,
          $$DailyLearningProgressTableFilterComposer,
          $$DailyLearningProgressTableOrderingComposer,
          $$DailyLearningProgressTableAnnotationComposer,
          $$DailyLearningProgressTableCreateCompanionBuilder,
          $$DailyLearningProgressTableUpdateCompanionBuilder,
          (
            DailyLearningProgressData,
            BaseReferences<
              _$AppDatabase,
              $DailyLearningProgressTable,
              DailyLearningProgressData
            >,
          ),
          DailyLearningProgressData,
          PrefetchHooks Function()
        > {
  $$DailyLearningProgressTableTableManager(
    _$AppDatabase db,
    $DailyLearningProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyLearningProgressTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DailyLearningProgressTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DailyLearningProgressTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> studentKey = const Value.absent(),
                Value<String> learningDate = const Value.absent(),
                Value<String> hanjaId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyLearningProgressCompanion(
                studentKey: studentKey,
                learningDate: learningDate,
                hanjaId: hanjaId,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String studentKey,
                required String learningDate,
                required String hanjaId,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => DailyLearningProgressCompanion.insert(
                studentKey: studentKey,
                learningDate: learningDate,
                hanjaId: hanjaId,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyLearningProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyLearningProgressTable,
      DailyLearningProgressData,
      $$DailyLearningProgressTableFilterComposer,
      $$DailyLearningProgressTableOrderingComposer,
      $$DailyLearningProgressTableAnnotationComposer,
      $$DailyLearningProgressTableCreateCompanionBuilder,
      $$DailyLearningProgressTableUpdateCompanionBuilder,
      (
        DailyLearningProgressData,
        BaseReferences<
          _$AppDatabase,
          $DailyLearningProgressTable,
          DailyLearningProgressData
        >,
      ),
      DailyLearningProgressData,
      PrefetchHooks Function()
    >;
typedef $$LocalXpEventsTableCreateCompanionBuilder =
    LocalXpEventsCompanion Function({
      required String id,
      required String studentKey,
      required String source,
      required int amount,
      Value<String?> refId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalXpEventsTableUpdateCompanionBuilder =
    LocalXpEventsCompanion Function({
      Value<String> id,
      Value<String> studentKey,
      Value<String> source,
      Value<int> amount,
      Value<String?> refId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalXpEventsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalXpEventsTable> {
  $$LocalXpEventsTableFilterComposer({
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

  ColumnFilters<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalXpEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalXpEventsTable> {
  $$LocalXpEventsTableOrderingComposer({
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

  ColumnOrderings<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalXpEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalXpEventsTable> {
  $$LocalXpEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalXpEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalXpEventsTable,
          LocalXpEvent,
          $$LocalXpEventsTableFilterComposer,
          $$LocalXpEventsTableOrderingComposer,
          $$LocalXpEventsTableAnnotationComposer,
          $$LocalXpEventsTableCreateCompanionBuilder,
          $$LocalXpEventsTableUpdateCompanionBuilder,
          (
            LocalXpEvent,
            BaseReferences<_$AppDatabase, $LocalXpEventsTable, LocalXpEvent>,
          ),
          LocalXpEvent,
          PrefetchHooks Function()
        > {
  $$LocalXpEventsTableTableManager(_$AppDatabase db, $LocalXpEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalXpEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalXpEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalXpEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentKey = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> refId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalXpEventsCompanion(
                id: id,
                studentKey: studentKey,
                source: source,
                amount: amount,
                refId: refId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentKey,
                required String source,
                required int amount,
                Value<String?> refId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalXpEventsCompanion.insert(
                id: id,
                studentKey: studentKey,
                source: source,
                amount: amount,
                refId: refId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalXpEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalXpEventsTable,
      LocalXpEvent,
      $$LocalXpEventsTableFilterComposer,
      $$LocalXpEventsTableOrderingComposer,
      $$LocalXpEventsTableAnnotationComposer,
      $$LocalXpEventsTableCreateCompanionBuilder,
      $$LocalXpEventsTableUpdateCompanionBuilder,
      (
        LocalXpEvent,
        BaseReferences<_$AppDatabase, $LocalXpEventsTable, LocalXpEvent>,
      ),
      LocalXpEvent,
      PrefetchHooks Function()
    >;
typedef $$LocalGameResultsTableCreateCompanionBuilder =
    LocalGameResultsCompanion Function({
      required String id,
      required String studentKey,
      required String learningDate,
      required int score,
      required int correctCount,
      required int totalCount,
      required int timeSec,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$LocalGameResultsTableUpdateCompanionBuilder =
    LocalGameResultsCompanion Function({
      Value<String> id,
      Value<String> studentKey,
      Value<String> learningDate,
      Value<int> score,
      Value<int> correctCount,
      Value<int> totalCount,
      Value<int> timeSec,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$LocalGameResultsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGameResultsTable> {
  $$LocalGameResultsTableFilterComposer({
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

  ColumnFilters<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSec => $composableBuilder(
    column: $table.timeSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalGameResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGameResultsTable> {
  $$LocalGameResultsTableOrderingComposer({
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

  ColumnOrderings<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSec => $composableBuilder(
    column: $table.timeSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalGameResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGameResultsTable> {
  $$LocalGameResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSec =>
      $composableBuilder(column: $table.timeSec, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$LocalGameResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalGameResultsTable,
          LocalGameResult,
          $$LocalGameResultsTableFilterComposer,
          $$LocalGameResultsTableOrderingComposer,
          $$LocalGameResultsTableAnnotationComposer,
          $$LocalGameResultsTableCreateCompanionBuilder,
          $$LocalGameResultsTableUpdateCompanionBuilder,
          (
            LocalGameResult,
            BaseReferences<
              _$AppDatabase,
              $LocalGameResultsTable,
              LocalGameResult
            >,
          ),
          LocalGameResult,
          PrefetchHooks Function()
        > {
  $$LocalGameResultsTableTableManager(
    _$AppDatabase db,
    $LocalGameResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalGameResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalGameResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalGameResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentKey = const Value.absent(),
                Value<String> learningDate = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<int> timeSec = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalGameResultsCompanion(
                id: id,
                studentKey: studentKey,
                learningDate: learningDate,
                score: score,
                correctCount: correctCount,
                totalCount: totalCount,
                timeSec: timeSec,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentKey,
                required String learningDate,
                required int score,
                required int correctCount,
                required int totalCount,
                required int timeSec,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalGameResultsCompanion.insert(
                id: id,
                studentKey: studentKey,
                learningDate: learningDate,
                score: score,
                correctCount: correctCount,
                totalCount: totalCount,
                timeSec: timeSec,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalGameResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalGameResultsTable,
      LocalGameResult,
      $$LocalGameResultsTableFilterComposer,
      $$LocalGameResultsTableOrderingComposer,
      $$LocalGameResultsTableAnnotationComposer,
      $$LocalGameResultsTableCreateCompanionBuilder,
      $$LocalGameResultsTableUpdateCompanionBuilder,
      (
        LocalGameResult,
        BaseReferences<_$AppDatabase, $LocalGameResultsTable, LocalGameResult>,
      ),
      LocalGameResult,
      PrefetchHooks Function()
    >;
typedef $$LocalQuizResultsTableCreateCompanionBuilder =
    LocalQuizResultsCompanion Function({
      required String id,
      required String studentKey,
      required String learningDate,
      required int score,
      required int correctCount,
      required int totalCount,
      required int timeSec,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$LocalQuizResultsTableUpdateCompanionBuilder =
    LocalQuizResultsCompanion Function({
      Value<String> id,
      Value<String> studentKey,
      Value<String> learningDate,
      Value<int> score,
      Value<int> correctCount,
      Value<int> totalCount,
      Value<int> timeSec,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$LocalQuizResultsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQuizResultsTable> {
  $$LocalQuizResultsTableFilterComposer({
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

  ColumnFilters<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSec => $composableBuilder(
    column: $table.timeSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalQuizResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQuizResultsTable> {
  $$LocalQuizResultsTableOrderingComposer({
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

  ColumnOrderings<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSec => $composableBuilder(
    column: $table.timeSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalQuizResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQuizResultsTable> {
  $$LocalQuizResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSec =>
      $composableBuilder(column: $table.timeSec, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$LocalQuizResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalQuizResultsTable,
          LocalQuizResult,
          $$LocalQuizResultsTableFilterComposer,
          $$LocalQuizResultsTableOrderingComposer,
          $$LocalQuizResultsTableAnnotationComposer,
          $$LocalQuizResultsTableCreateCompanionBuilder,
          $$LocalQuizResultsTableUpdateCompanionBuilder,
          (
            LocalQuizResult,
            BaseReferences<
              _$AppDatabase,
              $LocalQuizResultsTable,
              LocalQuizResult
            >,
          ),
          LocalQuizResult,
          PrefetchHooks Function()
        > {
  $$LocalQuizResultsTableTableManager(
    _$AppDatabase db,
    $LocalQuizResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuizResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuizResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQuizResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentKey = const Value.absent(),
                Value<String> learningDate = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<int> timeSec = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalQuizResultsCompanion(
                id: id,
                studentKey: studentKey,
                learningDate: learningDate,
                score: score,
                correctCount: correctCount,
                totalCount: totalCount,
                timeSec: timeSec,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentKey,
                required String learningDate,
                required int score,
                required int correctCount,
                required int totalCount,
                required int timeSec,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalQuizResultsCompanion.insert(
                id: id,
                studentKey: studentKey,
                learningDate: learningDate,
                score: score,
                correctCount: correctCount,
                totalCount: totalCount,
                timeSec: timeSec,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalQuizResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalQuizResultsTable,
      LocalQuizResult,
      $$LocalQuizResultsTableFilterComposer,
      $$LocalQuizResultsTableOrderingComposer,
      $$LocalQuizResultsTableAnnotationComposer,
      $$LocalQuizResultsTableCreateCompanionBuilder,
      $$LocalQuizResultsTableUpdateCompanionBuilder,
      (
        LocalQuizResult,
        BaseReferences<_$AppDatabase, $LocalQuizResultsTable, LocalQuizResult>,
      ),
      LocalQuizResult,
      PrefetchHooks Function()
    >;
typedef $$LocalChallengeResultsTableCreateCompanionBuilder =
    LocalChallengeResultsCompanion Function({
      required String id,
      required String studentKey,
      required String learningDate,
      required String mode,
      required int score,
      required int correctCount,
      required int totalCount,
      required int timeSec,
      required int flippedTileCount,
      required int earnedXp,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$LocalChallengeResultsTableUpdateCompanionBuilder =
    LocalChallengeResultsCompanion Function({
      Value<String> id,
      Value<String> studentKey,
      Value<String> learningDate,
      Value<String> mode,
      Value<int> score,
      Value<int> correctCount,
      Value<int> totalCount,
      Value<int> timeSec,
      Value<int> flippedTileCount,
      Value<int> earnedXp,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$LocalChallengeResultsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalChallengeResultsTable> {
  $$LocalChallengeResultsTableFilterComposer({
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

  ColumnFilters<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSec => $composableBuilder(
    column: $table.timeSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flippedTileCount => $composableBuilder(
    column: $table.flippedTileCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get earnedXp => $composableBuilder(
    column: $table.earnedXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalChallengeResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalChallengeResultsTable> {
  $$LocalChallengeResultsTableOrderingComposer({
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

  ColumnOrderings<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSec => $composableBuilder(
    column: $table.timeSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flippedTileCount => $composableBuilder(
    column: $table.flippedTileCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earnedXp => $composableBuilder(
    column: $table.earnedXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChallengeResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalChallengeResultsTable> {
  $$LocalChallengeResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get learningDate => $composableBuilder(
    column: $table.learningDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get correctCount => $composableBuilder(
    column: $table.correctCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSec =>
      $composableBuilder(column: $table.timeSec, builder: (column) => column);

  GeneratedColumn<int> get flippedTileCount => $composableBuilder(
    column: $table.flippedTileCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get earnedXp =>
      $composableBuilder(column: $table.earnedXp, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$LocalChallengeResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalChallengeResultsTable,
          LocalChallengeResult,
          $$LocalChallengeResultsTableFilterComposer,
          $$LocalChallengeResultsTableOrderingComposer,
          $$LocalChallengeResultsTableAnnotationComposer,
          $$LocalChallengeResultsTableCreateCompanionBuilder,
          $$LocalChallengeResultsTableUpdateCompanionBuilder,
          (
            LocalChallengeResult,
            BaseReferences<
              _$AppDatabase,
              $LocalChallengeResultsTable,
              LocalChallengeResult
            >,
          ),
          LocalChallengeResult,
          PrefetchHooks Function()
        > {
  $$LocalChallengeResultsTableTableManager(
    _$AppDatabase db,
    $LocalChallengeResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalChallengeResultsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalChallengeResultsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalChallengeResultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studentKey = const Value.absent(),
                Value<String> learningDate = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> correctCount = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<int> timeSec = const Value.absent(),
                Value<int> flippedTileCount = const Value.absent(),
                Value<int> earnedXp = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalChallengeResultsCompanion(
                id: id,
                studentKey: studentKey,
                learningDate: learningDate,
                mode: mode,
                score: score,
                correctCount: correctCount,
                totalCount: totalCount,
                timeSec: timeSec,
                flippedTileCount: flippedTileCount,
                earnedXp: earnedXp,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studentKey,
                required String learningDate,
                required String mode,
                required int score,
                required int correctCount,
                required int totalCount,
                required int timeSec,
                required int flippedTileCount,
                required int earnedXp,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalChallengeResultsCompanion.insert(
                id: id,
                studentKey: studentKey,
                learningDate: learningDate,
                mode: mode,
                score: score,
                correctCount: correctCount,
                totalCount: totalCount,
                timeSec: timeSec,
                flippedTileCount: flippedTileCount,
                earnedXp: earnedXp,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalChallengeResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalChallengeResultsTable,
      LocalChallengeResult,
      $$LocalChallengeResultsTableFilterComposer,
      $$LocalChallengeResultsTableOrderingComposer,
      $$LocalChallengeResultsTableAnnotationComposer,
      $$LocalChallengeResultsTableCreateCompanionBuilder,
      $$LocalChallengeResultsTableUpdateCompanionBuilder,
      (
        LocalChallengeResult,
        BaseReferences<
          _$AppDatabase,
          $LocalChallengeResultsTable,
          LocalChallengeResult
        >,
      ),
      LocalChallengeResult,
      PrefetchHooks Function()
    >;
typedef $$LocalStudentLinksTableCreateCompanionBuilder =
    LocalStudentLinksCompanion Function({
      required String studentKey,
      required String displayName,
      Value<String?> schoolName,
      Value<int?> grade,
      required String relationType,
      required DateTime linkedAt,
      Value<int> rowid,
    });
typedef $$LocalStudentLinksTableUpdateCompanionBuilder =
    LocalStudentLinksCompanion Function({
      Value<String> studentKey,
      Value<String> displayName,
      Value<String?> schoolName,
      Value<int?> grade,
      Value<String> relationType,
      Value<DateTime> linkedAt,
      Value<int> rowid,
    });

class $$LocalStudentLinksTableFilterComposer
    extends Composer<_$AppDatabase, $LocalStudentLinksTable> {
  $$LocalStudentLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get linkedAt => $composableBuilder(
    column: $table.linkedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalStudentLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalStudentLinksTable> {
  $$LocalStudentLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get linkedAt => $composableBuilder(
    column: $table.linkedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalStudentLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalStudentLinksTable> {
  $$LocalStudentLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get linkedAt =>
      $composableBuilder(column: $table.linkedAt, builder: (column) => column);
}

class $$LocalStudentLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalStudentLinksTable,
          LocalStudentLink,
          $$LocalStudentLinksTableFilterComposer,
          $$LocalStudentLinksTableOrderingComposer,
          $$LocalStudentLinksTableAnnotationComposer,
          $$LocalStudentLinksTableCreateCompanionBuilder,
          $$LocalStudentLinksTableUpdateCompanionBuilder,
          (
            LocalStudentLink,
            BaseReferences<
              _$AppDatabase,
              $LocalStudentLinksTable,
              LocalStudentLink
            >,
          ),
          LocalStudentLink,
          PrefetchHooks Function()
        > {
  $$LocalStudentLinksTableTableManager(
    _$AppDatabase db,
    $LocalStudentLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStudentLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalStudentLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalStudentLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> studentKey = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> schoolName = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<String> relationType = const Value.absent(),
                Value<DateTime> linkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalStudentLinksCompanion(
                studentKey: studentKey,
                displayName: displayName,
                schoolName: schoolName,
                grade: grade,
                relationType: relationType,
                linkedAt: linkedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String studentKey,
                required String displayName,
                Value<String?> schoolName = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                required String relationType,
                required DateTime linkedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalStudentLinksCompanion.insert(
                studentKey: studentKey,
                displayName: displayName,
                schoolName: schoolName,
                grade: grade,
                relationType: relationType,
                linkedAt: linkedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalStudentLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalStudentLinksTable,
      LocalStudentLink,
      $$LocalStudentLinksTableFilterComposer,
      $$LocalStudentLinksTableOrderingComposer,
      $$LocalStudentLinksTableAnnotationComposer,
      $$LocalStudentLinksTableCreateCompanionBuilder,
      $$LocalStudentLinksTableUpdateCompanionBuilder,
      (
        LocalStudentLink,
        BaseReferences<
          _$AppDatabase,
          $LocalStudentLinksTable,
          LocalStudentLink
        >,
      ),
      LocalStudentLink,
      PrefetchHooks Function()
    >;
typedef $$LocalClassesTableCreateCompanionBuilder =
    LocalClassesCompanion Function({
      required String id,
      required String className,
      required String classCode,
      Value<String?> schoolName,
      Value<int?> grade,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalClassesTableUpdateCompanionBuilder =
    LocalClassesCompanion Function({
      Value<String> id,
      Value<String> className,
      Value<String> classCode,
      Value<String?> schoolName,
      Value<int?> grade,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalClassesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalClassesTable> {
  $$LocalClassesTableFilterComposer({
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

  ColumnFilters<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classCode => $composableBuilder(
    column: $table.classCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalClassesTable> {
  $$LocalClassesTableOrderingComposer({
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

  ColumnOrderings<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classCode => $composableBuilder(
    column: $table.classCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalClassesTable> {
  $$LocalClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<String> get classCode =>
      $composableBuilder(column: $table.classCode, builder: (column) => column);

  GeneratedColumn<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalClassesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalClassesTable,
          LocalClassesData,
          $$LocalClassesTableFilterComposer,
          $$LocalClassesTableOrderingComposer,
          $$LocalClassesTableAnnotationComposer,
          $$LocalClassesTableCreateCompanionBuilder,
          $$LocalClassesTableUpdateCompanionBuilder,
          (
            LocalClassesData,
            BaseReferences<_$AppDatabase, $LocalClassesTable, LocalClassesData>,
          ),
          LocalClassesData,
          PrefetchHooks Function()
        > {
  $$LocalClassesTableTableManager(_$AppDatabase db, $LocalClassesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> className = const Value.absent(),
                Value<String> classCode = const Value.absent(),
                Value<String?> schoolName = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalClassesCompanion(
                id: id,
                className: className,
                classCode: classCode,
                schoolName: schoolName,
                grade: grade,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String className,
                required String classCode,
                Value<String?> schoolName = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalClassesCompanion.insert(
                id: id,
                className: className,
                classCode: classCode,
                schoolName: schoolName,
                grade: grade,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalClassesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalClassesTable,
      LocalClassesData,
      $$LocalClassesTableFilterComposer,
      $$LocalClassesTableOrderingComposer,
      $$LocalClassesTableAnnotationComposer,
      $$LocalClassesTableCreateCompanionBuilder,
      $$LocalClassesTableUpdateCompanionBuilder,
      (
        LocalClassesData,
        BaseReferences<_$AppDatabase, $LocalClassesTable, LocalClassesData>,
      ),
      LocalClassesData,
      PrefetchHooks Function()
    >;
typedef $$LocalClassMembersTableCreateCompanionBuilder =
    LocalClassMembersCompanion Function({
      required String classId,
      required String studentKey,
      required String displayName,
      Value<String?> schoolName,
      Value<int?> grade,
      required DateTime joinedAt,
      Value<int> rowid,
    });
typedef $$LocalClassMembersTableUpdateCompanionBuilder =
    LocalClassMembersCompanion Function({
      Value<String> classId,
      Value<String> studentKey,
      Value<String> displayName,
      Value<String?> schoolName,
      Value<int?> grade,
      Value<DateTime> joinedAt,
      Value<int> rowid,
    });

class $$LocalClassMembersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalClassMembersTable> {
  $$LocalClassMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalClassMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalClassMembersTable> {
  $$LocalClassMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalClassMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalClassMembersTable> {
  $$LocalClassMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get studentKey => $composableBuilder(
    column: $table.studentKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);
}

class $$LocalClassMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalClassMembersTable,
          LocalClassMember,
          $$LocalClassMembersTableFilterComposer,
          $$LocalClassMembersTableOrderingComposer,
          $$LocalClassMembersTableAnnotationComposer,
          $$LocalClassMembersTableCreateCompanionBuilder,
          $$LocalClassMembersTableUpdateCompanionBuilder,
          (
            LocalClassMember,
            BaseReferences<
              _$AppDatabase,
              $LocalClassMembersTable,
              LocalClassMember
            >,
          ),
          LocalClassMember,
          PrefetchHooks Function()
        > {
  $$LocalClassMembersTableTableManager(
    _$AppDatabase db,
    $LocalClassMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalClassMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalClassMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalClassMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> classId = const Value.absent(),
                Value<String> studentKey = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> schoolName = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalClassMembersCompanion(
                classId: classId,
                studentKey: studentKey,
                displayName: displayName,
                schoolName: schoolName,
                grade: grade,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String classId,
                required String studentKey,
                required String displayName,
                Value<String?> schoolName = const Value.absent(),
                Value<int?> grade = const Value.absent(),
                required DateTime joinedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalClassMembersCompanion.insert(
                classId: classId,
                studentKey: studentKey,
                displayName: displayName,
                schoolName: schoolName,
                grade: grade,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalClassMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalClassMembersTable,
      LocalClassMember,
      $$LocalClassMembersTableFilterComposer,
      $$LocalClassMembersTableOrderingComposer,
      $$LocalClassMembersTableAnnotationComposer,
      $$LocalClassMembersTableCreateCompanionBuilder,
      $$LocalClassMembersTableUpdateCompanionBuilder,
      (
        LocalClassMember,
        BaseReferences<
          _$AppDatabase,
          $LocalClassMembersTable,
          LocalClassMember
        >,
      ),
      LocalClassMember,
      PrefetchHooks Function()
    >;
typedef $$LocalLearningEnvironmentSettingsTableCreateCompanionBuilder =
    LocalLearningEnvironmentSettingsCompanion Function({
      required String id,
      Value<bool> backgroundMusicEnabled,
      Value<bool> soundEffectsEnabled,
      Value<bool> strokeSoundEnabled,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalLearningEnvironmentSettingsTableUpdateCompanionBuilder =
    LocalLearningEnvironmentSettingsCompanion Function({
      Value<String> id,
      Value<bool> backgroundMusicEnabled,
      Value<bool> soundEffectsEnabled,
      Value<bool> strokeSoundEnabled,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalLearningEnvironmentSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLearningEnvironmentSettingsTable> {
  $$LocalLearningEnvironmentSettingsTableFilterComposer({
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

  ColumnFilters<bool> get backgroundMusicEnabled => $composableBuilder(
    column: $table.backgroundMusicEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get soundEffectsEnabled => $composableBuilder(
    column: $table.soundEffectsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get strokeSoundEnabled => $composableBuilder(
    column: $table.strokeSoundEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalLearningEnvironmentSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLearningEnvironmentSettingsTable> {
  $$LocalLearningEnvironmentSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get backgroundMusicEnabled => $composableBuilder(
    column: $table.backgroundMusicEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get soundEffectsEnabled => $composableBuilder(
    column: $table.soundEffectsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get strokeSoundEnabled => $composableBuilder(
    column: $table.strokeSoundEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalLearningEnvironmentSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLearningEnvironmentSettingsTable> {
  $$LocalLearningEnvironmentSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get backgroundMusicEnabled => $composableBuilder(
    column: $table.backgroundMusicEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get soundEffectsEnabled => $composableBuilder(
    column: $table.soundEffectsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get strokeSoundEnabled => $composableBuilder(
    column: $table.strokeSoundEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalLearningEnvironmentSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalLearningEnvironmentSettingsTable,
          LocalLearningEnvironmentSetting,
          $$LocalLearningEnvironmentSettingsTableFilterComposer,
          $$LocalLearningEnvironmentSettingsTableOrderingComposer,
          $$LocalLearningEnvironmentSettingsTableAnnotationComposer,
          $$LocalLearningEnvironmentSettingsTableCreateCompanionBuilder,
          $$LocalLearningEnvironmentSettingsTableUpdateCompanionBuilder,
          (
            LocalLearningEnvironmentSetting,
            BaseReferences<
              _$AppDatabase,
              $LocalLearningEnvironmentSettingsTable,
              LocalLearningEnvironmentSetting
            >,
          ),
          LocalLearningEnvironmentSetting,
          PrefetchHooks Function()
        > {
  $$LocalLearningEnvironmentSettingsTableTableManager(
    _$AppDatabase db,
    $LocalLearningEnvironmentSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLearningEnvironmentSettingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalLearningEnvironmentSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalLearningEnvironmentSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> backgroundMusicEnabled = const Value.absent(),
                Value<bool> soundEffectsEnabled = const Value.absent(),
                Value<bool> strokeSoundEnabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalLearningEnvironmentSettingsCompanion(
                id: id,
                backgroundMusicEnabled: backgroundMusicEnabled,
                soundEffectsEnabled: soundEffectsEnabled,
                strokeSoundEnabled: strokeSoundEnabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<bool> backgroundMusicEnabled = const Value.absent(),
                Value<bool> soundEffectsEnabled = const Value.absent(),
                Value<bool> strokeSoundEnabled = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalLearningEnvironmentSettingsCompanion.insert(
                id: id,
                backgroundMusicEnabled: backgroundMusicEnabled,
                soundEffectsEnabled: soundEffectsEnabled,
                strokeSoundEnabled: strokeSoundEnabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalLearningEnvironmentSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalLearningEnvironmentSettingsTable,
      LocalLearningEnvironmentSetting,
      $$LocalLearningEnvironmentSettingsTableFilterComposer,
      $$LocalLearningEnvironmentSettingsTableOrderingComposer,
      $$LocalLearningEnvironmentSettingsTableAnnotationComposer,
      $$LocalLearningEnvironmentSettingsTableCreateCompanionBuilder,
      $$LocalLearningEnvironmentSettingsTableUpdateCompanionBuilder,
      (
        LocalLearningEnvironmentSetting,
        BaseReferences<
          _$AppDatabase,
          $LocalLearningEnvironmentSettingsTable,
          LocalLearningEnvironmentSetting
        >,
      ),
      LocalLearningEnvironmentSetting,
      PrefetchHooks Function()
    >;
typedef $$LocalNotificationSettingsTableCreateCompanionBuilder =
    LocalNotificationSettingsCompanion Function({
      required String id,
      Value<bool> dailyReminderEnabled,
      Value<int> reminderHour,
      Value<int> reminderMinute,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalNotificationSettingsTableUpdateCompanionBuilder =
    LocalNotificationSettingsCompanion Function({
      Value<String> id,
      Value<bool> dailyReminderEnabled,
      Value<int> reminderHour,
      Value<int> reminderMinute,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalNotificationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalNotificationSettingsTable> {
  $$LocalNotificationSettingsTableFilterComposer({
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

  ColumnFilters<bool> get dailyReminderEnabled => $composableBuilder(
    column: $table.dailyReminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalNotificationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalNotificationSettingsTable> {
  $$LocalNotificationSettingsTableOrderingComposer({
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

  ColumnOrderings<bool> get dailyReminderEnabled => $composableBuilder(
    column: $table.dailyReminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalNotificationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalNotificationSettingsTable> {
  $$LocalNotificationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get dailyReminderEnabled => $composableBuilder(
    column: $table.dailyReminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalNotificationSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalNotificationSettingsTable,
          LocalNotificationSetting,
          $$LocalNotificationSettingsTableFilterComposer,
          $$LocalNotificationSettingsTableOrderingComposer,
          $$LocalNotificationSettingsTableAnnotationComposer,
          $$LocalNotificationSettingsTableCreateCompanionBuilder,
          $$LocalNotificationSettingsTableUpdateCompanionBuilder,
          (
            LocalNotificationSetting,
            BaseReferences<
              _$AppDatabase,
              $LocalNotificationSettingsTable,
              LocalNotificationSetting
            >,
          ),
          LocalNotificationSetting,
          PrefetchHooks Function()
        > {
  $$LocalNotificationSettingsTableTableManager(
    _$AppDatabase db,
    $LocalNotificationSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalNotificationSettingsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalNotificationSettingsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalNotificationSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> dailyReminderEnabled = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalNotificationSettingsCompanion(
                id: id,
                dailyReminderEnabled: dailyReminderEnabled,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<bool> dailyReminderEnabled = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalNotificationSettingsCompanion.insert(
                id: id,
                dailyReminderEnabled: dailyReminderEnabled,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalNotificationSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalNotificationSettingsTable,
      LocalNotificationSetting,
      $$LocalNotificationSettingsTableFilterComposer,
      $$LocalNotificationSettingsTableOrderingComposer,
      $$LocalNotificationSettingsTableAnnotationComposer,
      $$LocalNotificationSettingsTableCreateCompanionBuilder,
      $$LocalNotificationSettingsTableUpdateCompanionBuilder,
      (
        LocalNotificationSetting,
        BaseReferences<
          _$AppDatabase,
          $LocalNotificationSettingsTable,
          LocalNotificationSetting
        >,
      ),
      LocalNotificationSetting,
      PrefetchHooks Function()
    >;
typedef $$LocalPendingSyncOperationsTableCreateCompanionBuilder =
    LocalPendingSyncOperationsCompanion Function({
      required String id,
      required String operationType,
      required String targetTable,
      required String payloadJson,
      Value<int> attemptCount,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalPendingSyncOperationsTableUpdateCompanionBuilder =
    LocalPendingSyncOperationsCompanion Function({
      Value<String> id,
      Value<String> operationType,
      Value<String> targetTable,
      Value<String> payloadJson,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalPendingSyncOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPendingSyncOperationsTable> {
  $$LocalPendingSyncOperationsTableFilterComposer({
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

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPendingSyncOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPendingSyncOperationsTable> {
  $$LocalPendingSyncOperationsTableOrderingComposer({
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

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPendingSyncOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPendingSyncOperationsTable> {
  $$LocalPendingSyncOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalPendingSyncOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPendingSyncOperationsTable,
          LocalPendingSyncOperation,
          $$LocalPendingSyncOperationsTableFilterComposer,
          $$LocalPendingSyncOperationsTableOrderingComposer,
          $$LocalPendingSyncOperationsTableAnnotationComposer,
          $$LocalPendingSyncOperationsTableCreateCompanionBuilder,
          $$LocalPendingSyncOperationsTableUpdateCompanionBuilder,
          (
            LocalPendingSyncOperation,
            BaseReferences<
              _$AppDatabase,
              $LocalPendingSyncOperationsTable,
              LocalPendingSyncOperation
            >,
          ),
          LocalPendingSyncOperation,
          PrefetchHooks Function()
        > {
  $$LocalPendingSyncOperationsTableTableManager(
    _$AppDatabase db,
    $LocalPendingSyncOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPendingSyncOperationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalPendingSyncOperationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalPendingSyncOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPendingSyncOperationsCompanion(
                id: id,
                operationType: operationType,
                targetTable: targetTable,
                payloadJson: payloadJson,
                attemptCount: attemptCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String operationType,
                required String targetTable,
                required String payloadJson,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalPendingSyncOperationsCompanion.insert(
                id: id,
                operationType: operationType,
                targetTable: targetTable,
                payloadJson: payloadJson,
                attemptCount: attemptCount,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPendingSyncOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPendingSyncOperationsTable,
      LocalPendingSyncOperation,
      $$LocalPendingSyncOperationsTableFilterComposer,
      $$LocalPendingSyncOperationsTableOrderingComposer,
      $$LocalPendingSyncOperationsTableAnnotationComposer,
      $$LocalPendingSyncOperationsTableCreateCompanionBuilder,
      $$LocalPendingSyncOperationsTableUpdateCompanionBuilder,
      (
        LocalPendingSyncOperation,
        BaseReferences<
          _$AppDatabase,
          $LocalPendingSyncOperationsTable,
          LocalPendingSyncOperation
        >,
      ),
      LocalPendingSyncOperation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DailyLearningProgressTableTableManager get dailyLearningProgress =>
      $$DailyLearningProgressTableTableManager(_db, _db.dailyLearningProgress);
  $$LocalXpEventsTableTableManager get localXpEvents =>
      $$LocalXpEventsTableTableManager(_db, _db.localXpEvents);
  $$LocalGameResultsTableTableManager get localGameResults =>
      $$LocalGameResultsTableTableManager(_db, _db.localGameResults);
  $$LocalQuizResultsTableTableManager get localQuizResults =>
      $$LocalQuizResultsTableTableManager(_db, _db.localQuizResults);
  $$LocalChallengeResultsTableTableManager get localChallengeResults =>
      $$LocalChallengeResultsTableTableManager(_db, _db.localChallengeResults);
  $$LocalStudentLinksTableTableManager get localStudentLinks =>
      $$LocalStudentLinksTableTableManager(_db, _db.localStudentLinks);
  $$LocalClassesTableTableManager get localClasses =>
      $$LocalClassesTableTableManager(_db, _db.localClasses);
  $$LocalClassMembersTableTableManager get localClassMembers =>
      $$LocalClassMembersTableTableManager(_db, _db.localClassMembers);
  $$LocalLearningEnvironmentSettingsTableTableManager
  get localLearningEnvironmentSettings =>
      $$LocalLearningEnvironmentSettingsTableTableManager(
        _db,
        _db.localLearningEnvironmentSettings,
      );
  $$LocalNotificationSettingsTableTableManager get localNotificationSettings =>
      $$LocalNotificationSettingsTableTableManager(
        _db,
        _db.localNotificationSettings,
      );
  $$LocalPendingSyncOperationsTableTableManager
  get localPendingSyncOperations =>
      $$LocalPendingSyncOperationsTableTableManager(
        _db,
        _db.localPendingSyncOperations,
      );
}
