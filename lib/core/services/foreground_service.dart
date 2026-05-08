import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medi_assist/core/services/notification_service.dart';
import '../../models/medicine_model.dart';
import '../../models/meal_model.dart';
import '../../models/activity_model.dart';
import '../constants/app_constants.dart';


// ─── Task Handler (runs in background isolate) ────────────────────────────────
class MediAssistTaskHandler extends TaskHandler {
  Timer? _minuteTimer;
  DateTime? _lastChecked;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('🟢 MediAssist foreground service started: $starter');
    _lastChecked = DateTime.now();
    // Initialize storage in background isolate
    await GetStorage.init();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _checkAndTriggerReminders();
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('🔴 MediAssist foreground service destroyed');
    _minuteTimer?.cancel();
  }

  // ─── Core reminder check logic ───────────────────────────────────────────────
  void _checkAndTriggerReminders() {
    final now = DateTime.now();

    // Prevent duplicate triggers within same minute
    if (_lastChecked != null &&
        _lastChecked!.hour == now.hour &&
        _lastChecked!.minute == now.minute &&
        _lastChecked!.day == now.day) {
      return;
    }

    _lastChecked = now;
    final currentHour = now.hour;
    final currentMinute = now.minute;

    final box = GetStorage();

    // ── Check medicines ──
    try {
      final medicinesData = box.read<List>(AppConstants.medicinesKey);
      if (medicinesData != null) {
        for (final data in medicinesData) {
          final medicine =
              Medicine.fromJson(Map<String, dynamic>.from(data as Map));
          if (!medicine.isActive) continue;
          if (medicine.notificationType == AppConstants.notifTypeNone) continue;
          if (medicine.notificationType == AppConstants.notifTypeAlarm) {
            continue; // alarm package handles this
          }

          for (final time in medicine.times) {
            if (time.hour == currentHour && time.minute == currentMinute) {
              _showReminderNotification(
                id: AppConstants.medicineNotifBase +
                    medicine.id.hashCode.abs() % 1000,
                title: '💊 Medicine Reminder',
                body: 'Time to take ${medicine.name}',
                channelId: AppConstants.medicineChannelId,
                channelName: AppConstants.medicineChannelName,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking medicines: $e');
    }

    // ── Check meals ──
    try {
      final mealsData = box.read<List>(AppConstants.mealsKey);
      if (mealsData != null) {
        for (final data in mealsData) {
          final meal = Meal.fromJson(Map<String, dynamic>.from(data as Map));
          if (!meal.isActive) continue;
          if (meal.notificationType == AppConstants.notifTypeNone) continue;
          if (meal.notificationType == AppConstants.notifTypeAlarm) continue;

          if (meal.time.hour == currentHour &&
              meal.time.minute == currentMinute) {
            _showReminderNotification(
              id: AppConstants.mealNotifBase + meal.id.hashCode.abs() % 1000,
              title: '🍽️ Meal Reminder',
              body: 'Time for ${meal.name}',
              channelId: AppConstants.mealChannelId,
              channelName: AppConstants.mealChannelName,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking meals: $e');
    }

    // ── Check activities ──
    try {
      final activitiesData = box.read<List>(AppConstants.activitiesKey);
      if (activitiesData != null) {
        for (final data in activitiesData) {
          final activity =
              Activity.fromJson(Map<String, dynamic>.from(data as Map));
          if (!activity.isActive) continue;
          if (activity.notificationType == AppConstants.notifTypeNone) continue;
          if (activity.notificationType == AppConstants.notifTypeAlarm) continue;

          if (activity.time.hour == currentHour &&
              activity.time.minute == currentMinute) {
            _showReminderNotification(
              id: AppConstants.activityNotifBase +
                  activity.id.hashCode.abs() % 1000,
              title: '🏃 Activity Reminder',
              body: 'Time for ${activity.name}',
              channelId: AppConstants.activityChannelId,
              channelName: AppConstants.activityChannelName,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking activities: $e');
    }
  }

  // ─── Show notification from background isolate ───────────────────────────────
  void _showReminderNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) {
    // Send data to main isolate to show notification
    FlutterForegroundTask.sendDataToMain({
      'type': 'reminder',
      'id': id,
      'title': title,
      'body': body,
      'channelId': channelId,
      'channelName': channelName,
    });
    debugPrint('📣 Reminder triggered: $title — $body');
  }
}

// ─── Foreground Service Manager ───────────────────────────────────────────────
class MediAssistForegroundService {
  MediAssistForegroundService._();

  // ─── Initialize ─────────────────────────────────────────────────────────────
  static void initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: AppConstants.foregroundChannelId,
        channelName: AppConstants.foregroundChannelName,
        channelDescription:
            'MediAssist is running to deliver your reminders on time.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // Check every 60 seconds
        eventAction: ForegroundTaskEventAction.repeat(60000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  // ─── Start Service ───────────────────────────────────────────────────────────
  static Future<void> startService() async {
    try {
      // Register data receiver from background isolate
      FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.restartService();
        debugPrint('🔄 Foreground service restarted');
      } else {
        await FlutterForegroundTask.startService(
          serviceId: 2025,
          notificationTitle: 'MediAssist',
          notificationText: 'Monitoring your health reminders 24/7',
          notificationIcon: null,
          callback: startCallback,
        );
        debugPrint('🟢 Foreground service started');
      }
    } catch (e) {
      debugPrint('❌ Failed to start foreground service: $e');
    }
  }

  // ─── Stop Service ────────────────────────────────────────────────────────────
  static Future<void> stopService() async {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    await FlutterForegroundTask.stopService();
    debugPrint('🔴 Foreground service stopped');
  }

  // ─── Receive Data from Background Isolate ────────────────────────────────────
  static void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      final type = data['type'] as String?;
      if (type == 'reminder') {
        // Show notification from main isolate
        _showNotificationFromMainIsolate(data);
      }
    }
  }

  static void _showNotificationFromMainIsolate(
      Map<String, dynamic> data) async {
    try {
      await NotificationService.to.showImmediateNotification(
        id: data['id'] as int,
        title: data['title'] as String,
        body: data['body'] as String,
        channelId: data['channelId'] as String,
        channelName: data['channelName'] as String,
      );
    } catch (e) {
      debugPrint('❌ Error showing notification from main isolate: $e');
    }
  }

  // ─── Check Status ────────────────────────────────────────────────────────────
  static Future<bool> get isRunning async {
    return await FlutterForegroundTask.isRunningService;
  }

  // ─── Update Notification Text ────────────────────────────────────────────────
  static Future<void> updateNotificationText(String text) async {
    await FlutterForegroundTask.updateService(
      notificationTitle: 'MediAssist',
      notificationText: text,
    );
  }
}

// ─── Top-level callback — MUST be defined in main.dart too ───────────────────
// This is referenced from main.dart's startCallback()
// The actual definition is in main.dart:
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MediAssistTaskHandler());
}