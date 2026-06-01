package com.hanjasoook.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class DailyReminderBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            DailyReminderScheduler.rescheduleIfEnabled(context)
        }
    }
}
