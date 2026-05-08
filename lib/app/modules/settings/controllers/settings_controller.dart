import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/core/services/foreground_service.dart';
import 'package:medi_assist/core/services/notification_service.dart';
import 'package:medi_assist/core/services/permission_service.dart';
import 'package:medi_assist/core/services/reminder_scheduler.dart';
import 'package:medi_assist/core/services/storage_service.dart';
import 'package:medi_assist/core/utils/app_utils.dart';


class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  // ─── State ───────────────────────────────────────────────────────────────────
  final RxBool isServiceRunning = false.obs;
  final RxBool isLoadingPermissions = false.obs;
  final RxMap<String, bool> permissionStatus = <String, bool>{}.obs;
  final RxInt pendingNotifCount = 0.obs;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    isServiceRunning.value = await MediAssistForegroundService.isRunning;
    await refreshPermissions();
    await loadPendingNotifications();
  }

  // ─── Foreground Service ──────────────────────────────────────────────────────
  Future<void> toggleForegroundService() async {
    if (isServiceRunning.value) {
      await MediAssistForegroundService.stopService();
      AppUtils.showInfo('Background service stopped');
    } else {
      await MediAssistForegroundService.startService();
      AppUtils.showSuccess('Background service started');
    }
    isServiceRunning.value = await MediAssistForegroundService.isRunning;
  }

  // ─── Permissions ─────────────────────────────────────────────────────────────
  Future<void> refreshPermissions() async {
    isLoadingPermissions.value = true;
    try {
      final status = await PermissionService.to.checkAllPermissions();
      permissionStatus.assignAll(status);
    } finally {
      isLoadingPermissions.value = false;
    }
  }

  Future<void> requestAllPermissions() async {
    await PermissionService.to.requestAllPermissions();
    await refreshPermissions();
  }

  Future<void> openBatterySettings() async {
    await PermissionService.to.requestBatteryOptimizationPermission();
    await refreshPermissions();
  }

  Future<void> openAlarmSettings() async {
    await PermissionService.to.requestExactAlarmPermission();
    await refreshPermissions();
  }

  // ─── Test Notifications ──────────────────────────────────────────────────────
  Future<void> sendTestNotification() async {
    await NotificationService.to.showImmediateNotification(
      id: 9999,
      title: '🔔 Test Notification',
      body: 'MediAssist notifications are working correctly!',
      channelId: 'mediassist_medicine_channel',
      channelName: 'Medicine Reminders',
    );
    AppUtils.showSuccess('Test notification sent!');
  }

  // ─── Load Pending Notifications ──────────────────────────────────────────────
  Future<void> loadPendingNotifications() async {
    final pending = await NotificationService.to.getPending();
    pendingNotifCount.value = pending.length;
  }

  // ─── Reschedule All ──────────────────────────────────────────────────────────
  Future<void> rescheduleAll() async {
    try {
      final medicines = StorageService.to.getMedicines();
      final meals = StorageService.to.getMeals();
      final activities = StorageService.to.getActivities();

      await ReminderScheduler.rescheduleAll(
        medicines: medicines,
        meals: meals,
        activities: activities,
      );

      await loadPendingNotifications();
      AppUtils.showSuccess('All reminders rescheduled successfully');
    } catch (e) {
      AppUtils.showError('Failed to reschedule reminders');
    }
  }

  // ─── Clear All Data ──────────────────────────────────────────────────────────
  Future<void> clearAllData() async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Clear All Data',
      message:
          'This will delete ALL medicines, meals, activities and medical records. This cannot be undone.',
      confirmText: 'Clear All',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      icon: Icons.warning_amber_rounded,
    );

    if (!confirmed) return;

    try {
      await NotificationService.to.cancelAll();
      await StorageService.to.clearAll();
      AppUtils.showSuccess('All data cleared');
    } catch (e) {
      AppUtils.showError('Failed to clear data');
    }
  }
}