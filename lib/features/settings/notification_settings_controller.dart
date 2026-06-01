import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/app_notification_controller.dart';
import '../../data/local/app_database_provider.dart';
import '../../domain/models/notification_settings.dart';

final notificationSettingsControllerProvider =
    AsyncNotifierProvider<NotificationSettingsController, NotificationSettings>(
      NotificationSettingsController.new,
    );

class NotificationSettingsController
    extends AsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() async {
    final row = await ref.watch(appDatabaseProvider).getNotificationSettings();
    final settings = row == null
        ? const NotificationSettings()
        : NotificationSettings(
            dailyReminderEnabled: row.dailyReminderEnabled,
            reminderHour: row.reminderHour,
            reminderMinute: row.reminderMinute,
          );
    if (settings.dailyReminderEnabled) {
      final scheduled = await ref
          .read(appNotificationControllerProvider)
          .scheduleDailyReminder(
            hour: settings.reminderHour,
            minute: settings.reminderMinute,
          );
      if (!scheduled) {
        final disabled = settings.copyWith(dailyReminderEnabled: false);
        await _save(disabled);
        return disabled;
      }
    }
    return settings;
  }

  Future<bool> setDailyReminderEnabled(bool value) async {
    final next = _current.copyWith(dailyReminderEnabled: value);
    if (value) {
      final scheduled = await ref
          .read(appNotificationControllerProvider)
          .scheduleDailyReminder(
            hour: next.reminderHour,
            minute: next.reminderMinute,
          );
      if (!scheduled) {
        await _save(next.copyWith(dailyReminderEnabled: false));
        return false;
      }
    } else {
      await ref.read(appNotificationControllerProvider).cancelDailyReminder();
    }

    await _save(next);
    return true;
  }

  Future<bool> setReminderTime({required int hour, required int minute}) async {
    final next = _current.copyWith(reminderHour: hour, reminderMinute: minute);
    if (next.dailyReminderEnabled) {
      final scheduled = await ref
          .read(appNotificationControllerProvider)
          .scheduleDailyReminder(hour: hour, minute: minute);
      if (!scheduled) {
        await _save(next.copyWith(dailyReminderEnabled: false));
        return false;
      }
    }

    await _save(next);
    return true;
  }

  NotificationSettings get _current {
    return state.asData?.value ?? const NotificationSettings();
  }

  Future<void> _save(NotificationSettings next) async {
    state = AsyncData(next);
    await ref
        .read(appDatabaseProvider)
        .saveNotificationSettings(
          dailyReminderEnabled: next.dailyReminderEnabled,
          reminderHour: next.reminderHour,
          reminderMinute: next.reminderMinute,
          updatedAt: DateTime.now(),
        );
  }
}
