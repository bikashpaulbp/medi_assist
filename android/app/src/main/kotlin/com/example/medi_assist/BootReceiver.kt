package com.example.medi_assist

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.pravera.flutter_foreground_task.service.ForegroundService

/**
 * MediAssist Boot Receiver
 *
 * Fires on device boot, device restart, and app update.
 * The flutter_foreground_task plugin handles the actual Flutter engine restart
 * via its own internal boot mechanism (autoRunOnBoot = true).
 *
 * This receiver serves as an ADDITIONAL safety trigger to ensure
 * MediAssist's foreground service starts after reboot on all Android versions,
 * including MIUI (Xiaomi) which has aggressive background restrictions.
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "MediAssist_BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return

        Log.d(TAG, "Boot broadcast received: $action")

        when (action) {
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.LOCKED_BOOT_COMPLETED",
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON",
            "com.miui.home.launcher.action.RESTART" -> {
                Log.d(TAG, "Starting MediAssist foreground service after boot...")
                startForegroundService(context)
            }
            else -> {
                Log.d(TAG, "Unhandled action: $action")
            }
        }
    }

    private fun startForegroundService(context: Context) {
        try {
            val serviceIntent = Intent(context, ForegroundService::class.java).apply {
                // Pass a flag so the service knows it started from boot
                putExtra("startedFromBoot", true)
                action = "START_FOREGROUND_SERVICE"
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // Android 8+ requires startForegroundService for background starts
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }

            Log.d(TAG, "✅ Foreground service start requested successfully")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to start foreground service: ${e.message}")
            // Service will be started by flutter_foreground_task's own boot mechanism
        }
    }
}