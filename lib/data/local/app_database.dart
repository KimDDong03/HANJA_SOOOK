import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class DailyLearningProgress extends Table {
  TextColumn get studentKey => text()();
  TextColumn get learningDate => text()();
  TextColumn get hanjaId => text()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {studentKey, learningDate, hanjaId};
}

class LocalXpEvents extends Table {
  TextColumn get id => text()();
  TextColumn get studentKey => text()();
  TextColumn get source => text()();
  IntColumn get amount => integer()();
  TextColumn get refId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalHanjaPracticeEvents extends Table {
  TextColumn get id => text()();
  TextColumn get studentKey => text()();
  TextColumn get hanjaId => text()();
  TextColumn get learningDate => text()();
  TextColumn get source => text()();
  TextColumn get activityType => text()();
  TextColumn get result => text()();
  TextColumn get weaknessType => text().nullable()();
  IntColumn get scoreDelta => integer().withDefault(const Constant(0))();
  IntColumn get hintLevel => integer().nullable()();
  IntColumn get elapsedMs => integer().nullable()();
  TextColumn get confusedWithHanjaId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalHanjaWeaknesses extends Table {
  TextColumn get studentKey => text()();
  TextColumn get hanjaId => text()();
  TextColumn get weaknessType => text()();
  IntColumn get score => integer()();
  TextColumn get status => text()();
  IntColumn get mistakeCount => integer().withDefault(const Constant(0))();
  IntColumn get successStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastEventAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {studentKey, hanjaId, weaknessType};
}

class LocalGameResults extends Table {
  TextColumn get id => text()();
  TextColumn get studentKey => text()();
  TextColumn get learningDate => text()();
  IntColumn get score => integer()();
  IntColumn get correctCount => integer()();
  IntColumn get totalCount => integer()();
  IntColumn get timeSec => integer()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalQuizResults extends Table {
  TextColumn get id => text()();
  TextColumn get studentKey => text()();
  TextColumn get learningDate => text()();
  IntColumn get score => integer()();
  IntColumn get correctCount => integer()();
  IntColumn get totalCount => integer()();
  IntColumn get timeSec => integer()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalChallengeResults extends Table {
  TextColumn get id => text()();
  TextColumn get studentKey => text()();
  TextColumn get learningDate => text()();
  TextColumn get mode => text()();
  IntColumn get score => integer()();
  IntColumn get correctCount => integer()();
  IntColumn get totalCount => integer()();
  IntColumn get timeSec => integer()();
  IntColumn get flippedTileCount => integer()();
  IntColumn get earnedXp => integer()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalStudentLinks extends Table {
  TextColumn get studentKey => text()();
  TextColumn get displayName => text()();
  TextColumn get schoolName => text().nullable()();
  IntColumn get grade => integer().nullable()();
  TextColumn get relationType => text()();
  DateTimeColumn get linkedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {studentKey, relationType};
}

class LocalClasses extends Table {
  TextColumn get id => text()();
  TextColumn get className => text()();
  TextColumn get classCode => text()();
  TextColumn get schoolName => text().nullable()();
  IntColumn get grade => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalClassMembers extends Table {
  TextColumn get classId => text()();
  TextColumn get studentKey => text()();
  TextColumn get displayName => text()();
  TextColumn get schoolName => text().nullable()();
  IntColumn get grade => integer().nullable()();
  DateTimeColumn get joinedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {classId, studentKey};
}

class LocalLearningEnvironmentSettings extends Table {
  TextColumn get id => text()();
  BoolColumn get backgroundMusicEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get soundEffectsEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get strokeSoundEnabled =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalNotificationSettings extends Table {
  TextColumn get id => text()();
  BoolColumn get dailyReminderEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderHour => integer().withDefault(const Constant(18))();
  IntColumn get reminderMinute => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalPendingSyncOperations extends Table {
  TextColumn get id => text()();
  TextColumn get operationType => text()();
  TextColumn get targetTable => text()();
  TextColumn get payloadJson => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    DailyLearningProgress,
    LocalXpEvents,
    LocalHanjaPracticeEvents,
    LocalHanjaWeaknesses,
    LocalGameResults,
    LocalQuizResults,
    LocalChallengeResults,
    LocalStudentLinks,
    LocalClasses,
    LocalClassMembers,
    LocalLearningEnvironmentSettings,
    LocalNotificationSettings,
    LocalPendingSyncOperations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'hanja_soook'));

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(localXpEvents);
      }
      if (from < 3) {
        await migrator.createTable(localGameResults);
      }
      if (from < 4) {
        await migrator.createTable(localQuizResults);
      }
      if (from < 5) {
        await migrator.createTable(localStudentLinks);
      }
      if (from < 6) {
        await migrator.createTable(localClasses);
        await migrator.createTable(localClassMembers);
      }
      if (from < 7) {
        await migrator.createTable(localChallengeResults);
      }
      if (from < 8) {
        await migrator.createTable(localLearningEnvironmentSettings);
      }
      if (from < 9) {
        await migrator.createTable(localNotificationSettings);
      }
      if (from < 10) {
        await migrator.createTable(localPendingSyncOperations);
      }
      if (from < 11) {
        await migrator.createTable(localHanjaPracticeEvents);
        await migrator.createTable(localHanjaWeaknesses);
      }
    },
  );

  Future<List<DailyLearningProgressData>> getCompletedHanja({
    required String studentKey,
    required String learningDate,
  }) {
    return (select(dailyLearningProgress)
          ..where((row) => row.studentKey.equals(studentKey))
          ..where((row) => row.learningDate.equals(learningDate)))
        .get();
  }

  Future<List<DailyLearningProgressData>> getCompletedHanjaForStudent({
    required String studentKey,
  }) {
    return (select(
      dailyLearningProgress,
    )..where((row) => row.studentKey.equals(studentKey))).get();
  }

  Future<bool> markHanjaCompleted({
    required String studentKey,
    required String learningDate,
    required String hanjaId,
    required DateTime completedAt,
  }) async {
    final existing =
        await (select(dailyLearningProgress)
              ..where((row) => row.studentKey.equals(studentKey))
              ..where((row) => row.learningDate.equals(learningDate))
              ..where((row) => row.hanjaId.equals(hanjaId)))
            .getSingleOrNull();
    if (existing != null) {
      return false;
    }

    await into(dailyLearningProgress).insert(
      DailyLearningProgressCompanion.insert(
        studentKey: studentKey,
        learningDate: learningDate,
        hanjaId: hanjaId,
        completedAt: completedAt,
      ),
    );
    return true;
  }

  Future<bool> addXpEvent({
    required String id,
    required String studentKey,
    required String source,
    required int amount,
    String? refId,
    required DateTime createdAt,
  }) async {
    final existing = await (select(
      localXpEvents,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (existing != null) {
      return false;
    }

    await into(localXpEvents).insert(
      LocalXpEventsCompanion.insert(
        id: id,
        studentKey: studentKey,
        source: source,
        amount: amount,
        refId: Value(refId),
        createdAt: createdAt,
      ),
    );
    return true;
  }

  Future<void> saveHanjaPracticeEvent({
    required String id,
    required String studentKey,
    required String hanjaId,
    required String learningDate,
    required String source,
    required String activityType,
    required String result,
    required int scoreDelta,
    required DateTime createdAt,
    String? weaknessType,
    int? hintLevel,
    int? elapsedMs,
    String? confusedWithHanjaId,
  }) async {
    await into(localHanjaPracticeEvents).insert(
      LocalHanjaPracticeEventsCompanion.insert(
        id: id,
        studentKey: studentKey,
        hanjaId: hanjaId,
        learningDate: learningDate,
        source: source,
        activityType: activityType,
        result: result,
        weaknessType: Value(weaknessType),
        scoreDelta: Value(scoreDelta),
        hintLevel: Value(hintLevel),
        elapsedMs: Value(elapsedMs),
        confusedWithHanjaId: Value(confusedWithHanjaId),
        createdAt: createdAt,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<List<LocalHanjaPracticeEvent>> getHanjaPracticeEventsForHanja({
    required String studentKey,
    required String hanjaId,
  }) {
    return (select(localHanjaPracticeEvents)
          ..where((row) => row.studentKey.equals(studentKey))
          ..where((row) => row.hanjaId.equals(hanjaId))
          ..orderBy([
            (row) =>
                OrderingTerm(expression: row.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<List<LocalHanjaPracticeEvent>> getReviewCompletionEvents({
    required String studentKey,
    required String learningDate,
  }) {
    return (select(localHanjaPracticeEvents)
          ..where((row) => row.studentKey.equals(studentKey))
          ..where((row) => row.learningDate.equals(learningDate))
          ..where((row) => row.source.equals('review_session'))
          ..where((row) => row.activityType.equals('review_complete'))
          ..where((row) => row.result.equals('passed')))
        .get();
  }

  Future<LocalHanjaWeaknessesData?> getHanjaWeakness({
    required String studentKey,
    required String hanjaId,
    required String weaknessType,
  }) {
    return (select(localHanjaWeaknesses)
          ..where((row) => row.studentKey.equals(studentKey))
          ..where((row) => row.hanjaId.equals(hanjaId))
          ..where((row) => row.weaknessType.equals(weaknessType)))
        .getSingleOrNull();
  }

  Future<void> upsertHanjaWeakness({
    required String studentKey,
    required String hanjaId,
    required String weaknessType,
    required int score,
    required String status,
    required int mistakeCount,
    required int successStreak,
    required DateTime lastEventAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? resolvedAt,
  }) async {
    await into(localHanjaWeaknesses).insert(
      LocalHanjaWeaknessesCompanion.insert(
        studentKey: studentKey,
        hanjaId: hanjaId,
        weaknessType: weaknessType,
        score: score,
        status: status,
        mistakeCount: Value(mistakeCount),
        successStreak: Value(successStreak),
        lastEventAt: lastEventAt,
        resolvedAt: Value(resolvedAt),
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<LocalHanjaWeaknessesData>> getActiveHanjaWeaknesses({
    required String studentKey,
  }) {
    return (select(localHanjaWeaknesses)
          ..where((row) => row.studentKey.equals(studentKey))
          ..where((row) => row.status.equals('active'))
          ..orderBy([
            (row) =>
                OrderingTerm(expression: row.score, mode: OrderingMode.desc),
            (row) => OrderingTerm(
              expression: row.lastEventAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<LocalHanjaWeaknessesData>> getHanjaWeaknessesForHanjaIds({
    required String studentKey,
    required Set<String> hanjaIds,
  }) {
    if (hanjaIds.isEmpty) {
      return Future.value(const []);
    }
    return (select(localHanjaWeaknesses)
          ..where((row) => row.studentKey.equals(studentKey))
          ..where((row) => row.hanjaId.isIn(hanjaIds)))
        .get();
  }

  Future<void> markHanjaWeaknessResolved({
    required String studentKey,
    required String hanjaId,
    required String weaknessType,
    required DateTime resolvedAt,
  }) {
    return (update(localHanjaWeaknesses)
          ..where((row) => row.studentKey.equals(studentKey))
          ..where((row) => row.hanjaId.equals(hanjaId))
          ..where((row) => row.weaknessType.equals(weaknessType)))
        .write(
          LocalHanjaWeaknessesCompanion(
            score: const Value(0),
            status: const Value('resolved'),
            resolvedAt: Value(resolvedAt),
            updatedAt: Value(resolvedAt),
          ),
        );
  }

  Future<int> getTotalXp({required String studentKey}) async {
    final amount = localXpEvents.amount.sum();
    final row =
        await (selectOnly(localXpEvents)
              ..addColumns([amount])
              ..where(localXpEvents.studentKey.equals(studentKey)))
            .getSingle();
    return row.read(amount) ?? 0;
  }

  Future<int> getXpForRef({
    required String studentKey,
    required String source,
    required String refId,
  }) async {
    final amount = localXpEvents.amount.sum();
    final row =
        await (selectOnly(localXpEvents)
              ..addColumns([amount])
              ..where(localXpEvents.studentKey.equals(studentKey))
              ..where(localXpEvents.source.equals(source))
              ..where(localXpEvents.refId.equals(refId)))
            .getSingle();
    return row.read(amount) ?? 0;
  }

  Future<void> saveGameResult({
    required String id,
    required String studentKey,
    required String learningDate,
    required int score,
    required int correctCount,
    required int totalCount,
    required int timeSec,
    required DateTime completedAt,
  }) async {
    await into(localGameResults).insert(
      LocalGameResultsCompanion.insert(
        id: id,
        studentKey: studentKey,
        learningDate: learningDate,
        score: score,
        correctCount: correctCount,
        totalCount: totalCount,
        timeSec: timeSec,
        completedAt: completedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<LocalGameResult?> getLatestGameResult({required String studentKey}) {
    return (select(localGameResults)
          ..where((row) => row.studentKey.equals(studentKey))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.completedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> saveQuizResult({
    required String id,
    required String studentKey,
    required String learningDate,
    required int score,
    required int correctCount,
    required int totalCount,
    required int timeSec,
    required DateTime completedAt,
  }) async {
    await into(localQuizResults).insert(
      LocalQuizResultsCompanion.insert(
        id: id,
        studentKey: studentKey,
        learningDate: learningDate,
        score: score,
        correctCount: correctCount,
        totalCount: totalCount,
        timeSec: timeSec,
        completedAt: completedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<LocalQuizResult?> getLatestQuizResult({required String studentKey}) {
    return (select(localQuizResults)
          ..where((row) => row.studentKey.equals(studentKey))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.completedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> saveChallengeResult({
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
  }) async {
    await into(localChallengeResults).insert(
      LocalChallengeResultsCompanion.insert(
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
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<LocalChallengeResult?> getLatestChallengeResult({
    required String studentKey,
    String? mode,
  }) {
    final query = select(localChallengeResults)
      ..where((row) => row.studentKey.equals(studentKey));
    if (mode != null) {
      query.where((row) => row.mode.equals(mode));
    }
    query
      ..orderBy([
        (row) =>
            OrderingTerm(expression: row.completedAt, mode: OrderingMode.desc),
      ])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<LocalChallengeResult?> getChallengeResultById(String id) {
    return (select(
      localChallengeResults,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<List<LocalChallengeResult>> getChallengeResults({
    Set<String>? studentKeys,
    String? learningDate,
  }) {
    if (studentKeys != null && studentKeys.isEmpty) {
      return Future.value(const []);
    }

    final query = select(localChallengeResults);
    if (studentKeys != null) {
      query.where((row) => row.studentKey.isIn(studentKeys));
    }
    if (learningDate != null) {
      query.where((row) => row.learningDate.equals(learningDate));
    }
    query.orderBy([
      (row) =>
          OrderingTerm(expression: row.completedAt, mode: OrderingMode.desc),
    ]);
    return query.get();
  }

  Future<void> saveStudentLink({
    required String studentKey,
    required String displayName,
    String? schoolName,
    int? grade,
    required String relationType,
    required DateTime linkedAt,
  }) async {
    await into(localStudentLinks).insert(
      LocalStudentLinksCompanion.insert(
        studentKey: studentKey,
        displayName: displayName,
        schoolName: Value(schoolName),
        grade: Value(grade),
        relationType: relationType,
        linkedAt: linkedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<LocalStudentLink>> getStudentLinks({
    required String relationType,
  }) {
    return (select(localStudentLinks)
          ..where((row) => row.relationType.equals(relationType))
          ..orderBy([
            (row) =>
                OrderingTerm(expression: row.linkedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<void> saveLocalClass({
    required String id,
    required String className,
    required String classCode,
    String? schoolName,
    int? grade,
    required DateTime createdAt,
  }) async {
    await into(localClasses).insert(
      LocalClassesCompanion.insert(
        id: id,
        className: className,
        classCode: classCode,
        schoolName: Value(schoolName),
        grade: Value(grade),
        createdAt: createdAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<LocalClassesData>> getLocalClasses() {
    return (select(localClasses)..orderBy([
          (row) =>
              OrderingTerm(expression: row.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Future<void> saveLocalClassMember({
    required String classId,
    required String studentKey,
    required String displayName,
    String? schoolName,
    int? grade,
    required DateTime joinedAt,
  }) async {
    await into(localClassMembers).insert(
      LocalClassMembersCompanion.insert(
        classId: classId,
        studentKey: studentKey,
        displayName: displayName,
        schoolName: Value(schoolName),
        grade: Value(grade),
        joinedAt: joinedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<LocalClassMember>> getLocalClassMembers({
    required String classId,
  }) {
    return (select(localClassMembers)
          ..where((row) => row.classId.equals(classId))
          ..orderBy([
            (row) =>
                OrderingTerm(expression: row.joinedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<LocalLearningEnvironmentSetting?> getLearningEnvironmentSettings() {
    return (select(
      localLearningEnvironmentSettings,
    )..where((row) => row.id.equals('default'))).getSingleOrNull();
  }

  Future<void> saveLearningEnvironmentSettings({
    required bool backgroundMusicEnabled,
    required bool soundEffectsEnabled,
    required bool strokeSoundEnabled,
    required DateTime updatedAt,
  }) {
    return into(localLearningEnvironmentSettings).insert(
      LocalLearningEnvironmentSettingsCompanion.insert(
        id: 'default',
        backgroundMusicEnabled: Value(backgroundMusicEnabled),
        soundEffectsEnabled: Value(soundEffectsEnabled),
        strokeSoundEnabled: Value(strokeSoundEnabled),
        updatedAt: updatedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<LocalNotificationSetting?> getNotificationSettings() {
    return (select(
      localNotificationSettings,
    )..where((row) => row.id.equals('default'))).getSingleOrNull();
  }

  Future<void> saveNotificationSettings({
    required bool dailyReminderEnabled,
    required int reminderHour,
    required int reminderMinute,
    required DateTime updatedAt,
  }) {
    return into(localNotificationSettings).insert(
      LocalNotificationSettingsCompanion.insert(
        id: 'default',
        dailyReminderEnabled: Value(dailyReminderEnabled),
        reminderHour: Value(reminderHour),
        reminderMinute: Value(reminderMinute),
        updatedAt: updatedAt,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> enqueuePendingSyncOperation({
    required String id,
    required String operationType,
    required String targetTable,
    required String payloadJson,
    required DateTime createdAt,
  }) {
    return into(localPendingSyncOperations).insert(
      LocalPendingSyncOperationsCompanion.insert(
        id: id,
        operationType: operationType,
        targetTable: targetTable,
        payloadJson: payloadJson,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<List<LocalPendingSyncOperation>> getPendingSyncOperations({
    int limit = 50,
    String? targetTable,
  }) {
    final query = select(localPendingSyncOperations);
    if (targetTable != null) {
      query.where((row) => row.targetTable.equals(targetTable));
    }
    query
      ..orderBy([
        (row) =>
            OrderingTerm(expression: row.createdAt, mode: OrderingMode.asc),
      ])
      ..limit(limit);
    return query.get();
  }

  Future<void> markPendingSyncAttempt({
    required String id,
    required int attemptCount,
    required String lastError,
    required DateTime updatedAt,
  }) {
    return (update(
      localPendingSyncOperations,
    )..where((row) => row.id.equals(id))).write(
      LocalPendingSyncOperationsCompanion(
        attemptCount: Value(attemptCount),
        lastError: Value(lastError),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> deletePendingSyncOperation(String id) {
    return (delete(
      localPendingSyncOperations,
    )..where((row) => row.id.equals(id))).go();
  }
}
