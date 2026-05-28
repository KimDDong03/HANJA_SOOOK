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

@DriftDatabase(
  tables: [
    DailyLearningProgress,
    LocalXpEvents,
    LocalGameResults,
    LocalQuizResults,
    LocalStudentLinks,
    LocalClasses,
    LocalClassMembers,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'hanja_soook'));

  @override
  int get schemaVersion => 6;

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
}
