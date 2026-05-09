import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_colors.dart';
import '../services/notification_service.dart';

class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  // ─── Request All Permissions ─────────────────────────────────────────────────
  Future<void> requestAllPermissions() async {
    await requestNotificationPermission();
    await requestExactAlarmPermission();
    await requestBatteryOptimizationPermission();
    if (Platform.isAndroid) {
      await requestSystemAlertWindowPermission();
    }
  }

  // ─── Notification Permission ─────────────────────────────────────────────────
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ needs POST_NOTIFICATIONS
      final status = await Permission.notification.request();
      debugPrint('📣 Notification permission: $status');
      return status.isGranted;
    } else {
      final granted =
          await NotificationService.to.requestPermission();
      return granted;
    }
  }

  Future<bool> get isNotificationGranted async {
    return await Permission.notification.isGranted;
  }

  // ─── Exact Alarm Permission (Android 12+) ────────────────────────────────────
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // Check if permission is needed
      final canSchedule =
          await FlutterForegroundTask.canScheduleExactAlarms;
      if (canSchedule) return true;

      // Open settings for user to grant
      await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      return false;
    } catch (e) {
      debugPrint('⚠️ Exact alarm permission check failed: $e');
      return false;
    }
  }

  Future<bool> get canScheduleExactAlarms async {
    if (!Platform.isAndroid) return true;
    try {
      return await FlutterForegroundTask.canScheduleExactAlarms;
    } catch (e) {
      return false;
    }
  }

  // ─── Battery Optimization ────────────────────────────────────────────────────
  Future<bool> requestBatteryOptimizationPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final isIgnoring =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (isIgnoring) return true;

      // Show dialog explaining why, then open settings
      await _showBatteryOptimizationDialog();
      return false;
    } catch (e) {
      debugPrint('⚠️ Battery optimization check failed: $e');
      return false;
    }
  }

  Future<bool> get isBatteryOptimizationIgnored async {
    if (!Platform.isAndroid) return true;
    try {
      return await FlutterForegroundTask.isIgnoringBatteryOptimizations;
    } catch (e) {
      return false;
    }
  }

  Future<void> _showBatteryOptimizationDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.battery_saver_outlined,
                color: AppColors.warning,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Disable Battery Optimization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'To ensure MediAssist can deliver medicine and meal reminders on time — even when your phone is idle — please disable battery optimization for this app.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('Open Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    if (result == true) {
      await FlutterForegroundTask.openIgnoreBatteryOptimizationSettings();
    }
  }

  // ─── System Alert Window (Draw Over Apps) ────────────────────────────────────
  Future<bool> requestSystemAlertWindowPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final canDraw = await FlutterForegroundTask.canDrawOverlays;
      if (canDraw) return true;

      final status = await Permission.systemAlertWindow.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('⚠️ System alert window check failed: $e');
      return false;
    }
  }

  // ─── Check All Permissions Status ────────────────────────────────────────────
  Future<Map<String, bool>> checkAllPermissions() async {
    final notif = await Permission.notification.isGranted;
    final battery = await isBatteryOptimizationIgnored;
    final exactAlarm = await canScheduleExactAlarms;

    return {
      'notification': notif,
      'batteryOptimization': battery,
      'exactAlarm': exactAlarm,
    };
  }

  // ─── Permission Status Summary ───────────────────────────────────────────────
  Future<bool> get areAllCriticalPermissionsGranted async {
    final notif = await Permission.notification.isGranted;
    final exactAlarm = await canScheduleExactAlarms;
    return notif && exactAlarm;
  }

  // ─── Open App Settings ───────────────────────────────────────────────────────
 Future<void> openApplicationSettings() async {
  await openAppSettings();   // openAppSettings() from permission_handler package
}
}