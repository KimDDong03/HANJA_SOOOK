class NotificationSettings {
  const NotificationSettings({
    this.dailyReminderEnabled = false,
    this.reminderHour = 18,
    this.reminderMinute = 0,
  });

  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  String get displayTime {
    final period = reminderHour < 12 ? '오전' : '오후';
    final displayHour = reminderHour % 12 == 0 ? 12 : reminderHour % 12;
    final minuteText = reminderMinute.toString().padLeft(2, '0');
    return '$period $displayHour:$minuteText';
  }

  NotificationSettings copyWith({
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return NotificationSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}
