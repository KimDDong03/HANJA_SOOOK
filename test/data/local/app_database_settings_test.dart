import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanja_soook/data/local/app_database.dart';

void main() {
  group('AppDatabase settings', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('saves and reads notification settings', () async {
      await database.saveNotificationSettings(
        dailyReminderEnabled: true,
        reminderHour: 8,
        reminderMinute: 30,
        updatedAt: DateTime(2026, 6, 1),
      );

      final settings = await database.getNotificationSettings();

      expect(settings, isNotNull);
      expect(settings!.dailyReminderEnabled, isTrue);
      expect(settings.reminderHour, 8);
      expect(settings.reminderMinute, 30);
    });
  });
}
