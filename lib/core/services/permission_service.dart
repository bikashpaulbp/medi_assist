// lib/core/services/permission_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

class PermissionService {
  // Called on app start
  static Future<void> requestAllPermissions() async {
    final List<Permission> permissions = [];

    // Notification permission is required on both platforms.
    permissions.add(Permission.notification);

    if (Platform.isAndroid) {
      // These are Android specific permissions.
      permissions.add(Permission.ignoreBatteryOptimizations);
      permissions.add(Permission.scheduleExactAlarm);
      // Note: RECEIVE_BOOT_COMPLETED and FOREGROUND_SERVICE are set in the manifest only.
    }

    // Request all required permissions at once.
    final Map<Permission, PermissionStatus> statuses = await permissions.request();

    for (final Permission permission in permissions) {
      final PermissionStatus status = statuses[permission]!;
      if (!status.isGranted && permission == Permission.ignoreBatteryOptimizations) {
        // Fallback to showing a manual dialog for battery optimisation.
        await requestBatteryOptimization();
      }
    }
  }

  // Check status for a single permission
  static Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  // Check if a specific permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  // Request single permission with rationale
  static Future<bool> requestPermission(Permission permission, {String? rationale}) async {
    if (rationale != null && Platform.isAndroid) {
      final status = await permission.status;
      if (status.isDenied) {
        // Show a custom rationale dialog before requesting.
        final shouldRequest = await _showRationaleDialog(rationale);
        if (!shouldRequest) return false;
      }
    }
    final status = await permission.request();
    return status.isGranted;
  }

  static Future<bool> _showRationaleDialog(String message) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Permission Needed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Comprehensive Battery Optimization Handling using battery_optimization_helper
  static Future<void> requestBatteryOptimization() async {
    if (!Platform.isAndroid) return;

    final outcome = await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed(
      openSettingsIfDirectRequestNotPossible: true,
    );

    switch (outcome.status) {
      case OptimizationOutcomeStatus.alreadyDisabled:
        debugPrint('Battery optimization already disabled.');
        break;
      case OptimizationOutcomeStatus.disabledAfterPrompt:
        debugPrint('User disabled battery optimization.');
        break;
      case OptimizationOutcomeStatus.settingsOpened:
        Get.snackbar(
          'Battery Settings Opened',
          'Please disable battery optimization for MediAssist to ensure reliable reminders.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        break;
      case OptimizationOutcomeStatus.unsupported:
      case OptimizationOutcomeStatus.failed:
        debugPrint('Could not disable battery optimization.');
        // Secondary attempt: Open generic battery settings
        await BatteryOptimizationHelper.openBatteryOptimizationSettings();
        break;
    }
  }

  // Open manufacturer-specific auto-start settings (Xiaomi, Oppo, etc.)
  static Future<void> openAutoStartSettings() async {
    if (!Platform.isAndroid) return;
    final opened = await BatteryOptimizationHelper.openAutoStartSettings();
    if (!opened) {
      Get.snackbar(
        'Manual Setup Required',
        'Please manually add MediAssist to your device\'s Auto-start or Protected Apps list in Settings.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
    }
  }

  // Generic method to open alarm settings using open_settings package
  // static Future<void> openAlarmSettings() async {
  //   if (!Platform.isAndroid) return;
  //   await OpenSettings.openAlarmSetting();
  // }

  static Future<void> checkAndRequestAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;
  if (!status.isGranted) {
    await Permission.scheduleExactAlarm.request();
  }
}

  // Generic method to open notification settings using open_settings package
  static Future<void> openNotificationSettings() async {
    if (!Platform.isAndroid) return;
    await OpenSettings.openNotificationSetting();
  }

  // Generic method to open date settings using open_settings package
  static Future<void> openDateSettings() async {
    if (!Platform.isAndroid) return;
    await OpenSettings.openDateSetting();
  }

  // Open the main app settings page (where user can grant permissions)
  static Future<void> openAppSettings() async {
    await permission_handler.openAppSettings(); // This is a top-level function from permission_handler
  }

  // Get a diagnostic snapshot of battery restrictions
  static Future<BatteryRestrictionSnapshot?> getBatteryRestrictionSnapshot() async {
    if (!Platform.isAndroid) return null;
    return await BatteryOptimizationHelper.getBatteryRestrictionSnapshot();
  }
}