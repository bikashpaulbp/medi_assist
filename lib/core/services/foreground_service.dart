import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medi_assist/main.dart';
// ✅ FIXED: use relative import, NOT package:medi_assist/
import '../services/notification_service.dart';
import '../../models/medicine_model.dart';
import '../../models/meal_model.dart';
import '../../models/activity_model.dart';
import '../constants/app_constants.dart';

// ─── Task Handler (runs in BACKGROUND ISOLATE — no GetX services available) ──
class MediAssistTaskHandler extends TaskHandler {
  DateTime? _lastChecked;
  bool _isFirstStart = true;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('🟢 MediAssist foreground service started: $starter');
    _lastChecked = null;

    // ── Initialize storage in background isolate ──
    await GetStorage.init();

    // ── On boot/restart: reschedule all alarms ──
    // starter == TaskStarter.boot means device was rebooted
if (starter.name == 'boot' || _isFirstStart) {
      _isFirstStart = false;
      await _rescheduleAllAlarmsAfterBoot();
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _checkAndTriggerNotifications();
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('🔴 MediAssist foreground service destroyed');
  }

  // ─── Reschedule all alarms after device reboot ────────────────────────────
  Future<void> _rescheduleAllAlarmsAfterBoot() async {
    debugPrint('🔄 Rescheduling all alarms after boot/restart...');
    final box = GetStorage();

    try {
      // ── Reschedule medicine alarms ──
      final medicinesData = box.read<List>(AppConstants.medicinesKey);
      if (medicinesData != null) {
        for (final data in medicinesData) {
          try {
            final medicine =
                Medicine.fromJson(Map<String, dynamic>.from(data as Map));
            if (!medicine.isActive) continue;
            final notifType = medicine.notificationType;
            if (notifType != AppConstants.notifTypeAlarm &&
                notifType != AppConstants.notifTypeBoth) continue;

            final baseId = AppConstants.medicineAlarmBase +
                (medicine.id.hashCode.abs() % 100) * 10;

            for (int i = 0; i < medicine.times.length; i++) {
              final time = medicine.times[i];
              final alarmId = baseId + i;
              await _scheduleAlarmForNextOccurrence(
                alarmId: alarmId,
                hour: time.hour,
                minute: time.minute,
                title: '💊 Medicine Alarm',
                body: 'Time to take ${medicine.name}',
                loopAudio: true,
              );
            }
          } catch (e) {
            debugPrint('Error rescheduling medicine alarm: $e');
          }
        }
      }

      // ── Reschedule meal alarms ──
      final mealsData = box.read<List>(AppConstants.mealsKey);
      if (mealsData != null) {
        for (final data in mealsData) {
          try {
            final meal =
                Meal.fromJson(Map<String, dynamic>.from(data as Map));
            if (!meal.isActive) continue;
            final notifType = meal.notificationType;
            if (notifType != AppConstants.notifTypeAlarm &&
                notifType != AppConstants.notifTypeBoth) continue;

            final alarmId =
                AppConstants.mealAlarmBase + (meal.id.hashCode.abs() % 1000);
            await _scheduleAlarmForNextOccurrence(
              alarmId: alarmId,
              hour: meal.time.hour,
              minute: meal.time.minute,
              title: '🍽️ Meal Alarm',
              body: 'Time for ${meal.name}',
              loopAudio: false,
            );
          } catch (e) {
            debugPrint('Error rescheduling meal alarm: $e');
          }
        }
      }

      // ── Reschedule activity alarms ──
      final activitiesData = box.read<List>(AppConstants.activitiesKey);
      if (activitiesData != null) {
        for (final data in activitiesData) {
          try {
            final activity =
                Activity.fromJson(Map<String, dynamic>.from(data as Map));
            if (!activity.isActive) continue;
            final notifType = activity.notificationType;
            if (notifType != AppConstants.notifTypeAlarm &&
                notifType != AppConstants.notifTypeBoth) continue;

            final alarmId = AppConstants.activityAlarmBase +
                (activity.id.hashCode.abs() % 1000);
            await _scheduleAlarmForNextOccurrence(
              alarmId: alarmId,
              hour: activity.time.hour,
              minute: activity.time.minute,
              title: '🏃 Activity Alarm',
              body: 'Time for ${activity.name}',
              loopAudio: false,
            );
          } catch (e) {
            debugPrint('Error rescheduling activity alarm: $e');
          }
        }
      }

      debugPrint('✅ All alarms rescheduled after boot');
    } catch (e) {
      debugPrint('❌ Boot reschedule failed: $e');
    }
  }

  // ─── Schedule alarm for next occurrence from isolate ─────────────────────
  Future<void> _scheduleAlarmForNextOccurrence({
    required int alarmId,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required bool loopAudio,
  }) async {
    try {
      final now = DateTime.now();
      DateTime scheduled = DateTime(
        now.year, now.month, now.day, hour, minute, 0,
      );
      if (scheduled.isBefore(now) ||
          scheduled.difference(now).inSeconds < 30) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await Alarm.set(
        alarmSettings: AlarmSettings(
          id: alarmId,
          dateTime: scheduled,
          assetAudioPath: AppConstants.alarmAudioPath,
          loopAudio: loopAudio,
          vibrate: true,
          volumeSettings: VolumeSettings.fade(
            volume: 1.0,
            fadeDuration: const Duration(seconds: 3),
          ),
          warningNotificationOnKill: true,
          androidFullScreenIntent: true,
          notificationSettings: NotificationSettings(
            title: title,
            body: body,
            stopButton: 'Stop Alarm',
            icon: 'notification_icon',
          ),
        ),
      );
      debugPrint('✅ Boot-reschedule alarm $alarmId at $hour:$minute → $scheduled');
    } catch (e) {
      debugPrint('❌ Boot-reschedule alarm $alarmId failed: $e');
    }
  }

  // ─── Check & trigger NOTIFICATIONS (not alarms — alarm pkg handles those) ─
  void _checkAndTriggerNotifications() {
    final now = DateTime.now();

    // ── Prevent duplicate triggers within same minute ──
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

    // ── Medicines ──
    try {
      final medicinesData = box.read<List>(AppConstants.medicinesKey);
      if (medicinesData != null) {
        for (final data in medicinesData) {
          final medicine =
              Medicine.fromJson(Map<String, dynamic>.from(data as Map));
          if (!medicine.isActive) continue;
          // Only fire notification-type; alarm type is handled by alarm package
          if (medicine.notificationType == AppConstants.notifTypeNone) continue;
          if (medicine.notificationType == AppConstants.notifTypeAlarm) continue;

          for (final time in medicine.times) {
            if (time.hour == currentHour && time.minute == currentMinute) {
              _sendToMainIsolate(
                id: AppConstants.medicineNotifBase +
                    medicine.id.hashCode.abs() % 1000,
                title: '💊 Medicine Reminder',
                body: 'Time to take ${medicine.name}',
                channelId: AppConstants.medicineChannelId,
                channelName: AppConstants.medicineChannelName,
                payload: 'medicine_${medicine.id}',
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking medicines: $e');
    }

    // ── Meals ──
    try {
      final mealsData = box.read<List>(AppConstants.mealsKey);
      if (mealsData != null) {
        for (final data in mealsData) {
          final meal =
              Meal.fromJson(Map<String, dynamic>.from(data as Map));
          if (!meal.isActive) continue;
          if (meal.notificationType == AppConstants.notifTypeNone) continue;
          if (meal.notificationType == AppConstants.notifTypeAlarm) continue;

          if (meal.time.hour == currentHour &&
              meal.time.minute == currentMinute) {
            _sendToMainIsolate(
              id: AppConstants.mealNotifBase + meal.id.hashCode.abs() % 1000,
              title: '🍽️ Meal Reminder',
              body: 'Time for ${meal.name}',
              channelId: AppConstants.mealChannelId,
              channelName: AppConstants.mealChannelName,
              payload: 'meal_${meal.id}',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking meals: $e');
    }

    // ── Activities ──
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
            _sendToMainIsolate(
              id: AppConstants.activityNotifBase +
                  activity.id.hashCode.abs() % 1000,
              title: '🏃 Activity Reminder',
              body: 'Time for ${activity.name}',
              channelId: AppConstants.activityChannelId,
              channelName: AppConstants.activityChannelName,
              payload: 'activity_${activity.id}',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking activities: $e');
    }
  }

  void _sendToMainIsolate({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String payload,
  }) {
    FlutterForegroundTask.sendDataToMain({
      'type': 'reminder',
      'id': id,
      'title': title,
      'body': body,
      'channelId': channelId,
      'channelName': channelName,
      'payload': payload,
    });
  }
}

// ─── Foreground Service Manager ───────────────────────────────────────────────
class MediAssistForegroundService {
  MediAssistForegroundService._();

  static bool _isInitialized = false;
  static bool _callbackRegistered = false;

  // ─── Initialize (call once, at app start) ────────────────────────────────
  static void initService() {
    // ✅ Only initialize once — prevents config reset on every app open
    if (_isInitialized) return;
    _isInitialized = true;

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
        eventAction: ForegroundTaskEventAction.repeat(60000), // every 60s
        autoRunOnBoot: true,       // ✅ auto start after reboot
        autoRunOnMyPackageReplaced: true, // ✅ auto start after app update
        allowWakeLock: true,       // ✅ keep CPU awake for timely reminders
        allowWifiLock: false,
      ),
    );
  }

  // ─── Start Service ────────────────────────────────────────────────────────
  static Future<void> startService() async {
    try {
      // ✅ Register callback only once
      if (!_callbackRegistered) {
        FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
        _callbackRegistered = true;
      }

      final isRunning = await FlutterForegroundTask.isRunningService;

      if (isRunning) {
        // ✅ Already running — do NOT restart. Just update text.
        await FlutterForegroundTask.updateService( 
          notificationTitle: 'MediAssist Active',
          notificationText: 'Your health reminders are monitored 24/7',
        );
        debugPrint('ℹ️ Foreground service already running');
      } else {
        await FlutterForegroundTask.startService(
          serviceId: 2025,
          notificationTitle: 'MediAssist Active',
          notificationText: 'Your health reminders are monitored 24/7',
          notificationIcon: null,
          callback: startCallback,
        );
        debugPrint('🟢 Foreground service started');
      }
    } catch (e) {
      debugPrint('❌ Failed to start foreground service: $e');
    }
  }

  // ─── Stop Service ─────────────────────────────────────────────────────────
  static Future<void> stopService() async {
    if (_callbackRegistered) {
      FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
      _callbackRegistered = false;
    }
    await FlutterForegroundTask.stopService();
    debugPrint('🔴 Foreground service stopped');
  }


// ─── Update notification text ─────────────────────────────────────────────
static Future<void> updateNotificationText(String text) async {
  try {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.updateService(
        notificationTitle: 'MediAssist Active',
        notificationText: text,
      );
    }
  } catch (e) {
    debugPrint('❌ Failed to update notification text: $e');
  }
}
  // ─── Receive data from background isolate ────────────────────────────────
  static void _onReceiveTaskData(Object data) {
    if (data is! Map<String, dynamic>) return;
    final type = data['type'] as String?;
    if (type == 'reminder') {
      _showNotificationFromMainIsolate(data);
    }
  }

  static Future<void> _showNotificationFromMainIsolate(
      Map<String, dynamic> data) async {
    try {
      await NotificationService.to.showImmediateNotification(
        id: data['id'] as int,
        title: data['title'] as String,
        body: data['body'] as String,
        channelId: data['channelId'] as String,
        channelName: data['channelName'] as String,
        payload: data['payload'] as String?,
      );
    } catch (e) {
      debugPrint('❌ Error showing notification from main isolate: $e');
    }
  }

  // ─── Status ───────────────────────────────────────────────────────────────
  static Future<bool> get isRunning async {
    return await FlutterForegroundTask.isRunningService;
  }
}

// ✅ startCallback is defined ONLY in main.dart
// Do NOT define it here — that was the duplicate causing issues