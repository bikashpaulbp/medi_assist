import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../constants/app_colors.dart';
import '../services/notification_service.dart';

class PermissionService extends GetxService {
  static PermissionService get to => Get.find();

  // ─── Request all permissions at once ─────────────────────────────────────────
  Future<void> requestAllPermissions() async {
    await requestNotificationPermission();
    await requestExactAlarmPermission();
    await requestBatteryOptimizationPermission();
    if (Platform.isAndroid) {
      await requestSystemAlertWindowPermission();
    }
  }

  // ─── Notification permission ──────────────────────────────────────────────────
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await ph.Permission.notification.request();
      debugPrint('📣 Notification permission: $status');
      return status.isGranted;
    }
    return await NotificationService.to.requestPermission();
  }

  Future<bool> get isNotificationGranted async {
    return await ph.Permission.notification.isGranted;
  }

  // ─── Exact alarm permission (Android 12+) ────────────────────────────────────
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final canSchedule = await FlutterForegroundTask.canScheduleExactAlarms;
      if (canSchedule) return true;
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
    } catch (_) {
      return false;
    }
  }

  // ─── Battery optimization ─────────────────────────────────────────────────────
  Future<bool> requestBatteryOptimizationPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final isIgnoring =
          await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      if (isIgnoring) return true;
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
    } catch (_) {
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
              'For MediAssist to deliver reminders on time — even when your phone is idle — please disable battery optimization for this app.',
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

  // ─── System alert window ──────────────────────────────────────────────────────
  Future<bool> requestSystemAlertWindowPermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final canDraw = await FlutterForegroundTask.canDrawOverlays;
      if (canDraw) return true;
      final status = await ph.Permission.systemAlertWindow.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('⚠️ System alert window check failed: $e');
      return false;
    }
  }

  // ─── Check all permissions ────────────────────────────────────────────────────
  Future<Map<String, bool>> checkAllPermissions() async {
    final results = await Future.wait([
      ph.Permission.notification.isGranted,
      isBatteryOptimizationIgnored,
      canScheduleExactAlarms,
    ]);
    return {
      'notification':        results[0],
      'batteryOptimization': results[1],
      'exactAlarm':          results[2],
    };
  }

  Future<bool> get areAllCriticalPermissionsGranted async {
    final notif      = await ph.Permission.notification.isGranted;
    final exactAlarm = await canScheduleExactAlarms;
    return notif && exactAlarm;
  }

  // ✅ FIXED: Renamed to avoid recursive call
  // Calls ph.openAppSettings() from permission_handler package
  Future<void> openApplicationSettings() async {
    await ph.openAppSettings();
  }
}