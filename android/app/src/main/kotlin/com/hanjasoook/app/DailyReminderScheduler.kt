package com.hanjasoook.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import java.util.Calendar

object DailyReminderScheduler {
    private const val prefsName = "hanjasoook_notifications"
    private const val requestCode = 4201
    private const val keyEnabled = "daily_enabled"
    private const val keyHour = "daily_hour"
    private const val keyMinute = "daily_minute"

    fun schedule(context: Context, hour: Int, minute: Int) {
        context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(keyEnabled, true)
            .putInt(keyHour, hour)
            .putInt(keyMinute, minute)
            .apply()

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setInexactRepeating(
            AlarmManager.RTC_WAKEUP,
            nextTriggerAtMillis(hour, minute),
            AlarmManager.INTERVAL_DAY,
            pendingIntent(context)
        )
    }

    fun cancel(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent(context))
        context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(keyEnabled, false)
            .apply()
    }

    fun rescheduleIfEnabled(context: Context) {
        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        if (!prefs.getBoolean(keyEnabled, false)) {
            return
        }
        schedule(
            context = context,
            hour = prefs.getInt(keyHour, 18),
            minute = prefs.getInt(keyMinute, 0)
        )
    }

    fun isEnabled(context: Context): Boolean {
        return context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .getBoolean(keyEnabled, false)
    }

    private fun pendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, DailyReminderReceiver::class.java)
            .setAction("com.hanjasoook.app.DAILY_REMINDER")
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun nextTriggerAtMillis(hour: Int, minute: Int): Long {
        val now = Calendar.getInstance()
        val trigger = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (!after(now)) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }
        return trigger.timeInMillis
    }
}
