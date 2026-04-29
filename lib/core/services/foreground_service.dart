// lib/core/services/foreground_service.dart
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mediassist/models/activity_model.dart';
import 'package:mediassist/models/meal_model.dart';
import 'package:mediassist/models/medical_record_model.dart';
import 'package:mediassist/models/medicine_model.dart';
import 'notification_service.dart';
import 'alarm_service.dart';

class ForegroundService {
  static void startService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service_channel',
        channelName: 'MediAssist Reminder Service',
        channelDescription: 'This service ensures you never miss a health reminder.',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        allowAutoRestart: true,
        eventAction: ForegroundTaskEventAction.repeat(60000), // 1 minute
        autoRunOnBoot: true,
        allowWakeLock: true,
      ),
    );

    FlutterForegroundTask.startService(
      notificationTitle: 'MediAssist is active',
      notificationText: 'Monitoring your reminders...',
      notificationIcon: null,
      callback: startCallback,
    );
  }

  static void stopService() {
    FlutterForegroundTask.stopService();
  }

  static Future<bool> isRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  final GetStorage _storage = GetStorage();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('[ForegroundService] Started at: $timestamp, starter: $starter');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    debugPrint('[ForegroundService] Checking reminders at: $timestamp');
    _checkAndTriggerReminders(timestamp);
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    debugPrint('[ForegroundService] Destroyed at: $timestamp');
  }

  @override
  void onNotificationButtonPressed(String id) {
    debugPrint('[ForegroundService] Notification button pressed: $id');
  }

  @override
  void onNotificationPressed() {
    debugPrint('[ForegroundService] Notification pressed');
    FlutterForegroundTask.launchApp();
  }

  void _checkAndTriggerReminders(DateTime now) {
    final medicines = _getMedicines();
    final meals = _getMeals();
    final activities = _getActivities();
    final medicalRecords = _getMedicalRecords();

    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    for (var medicineJson in medicines) {
      final medicine = Medicine.fromJson(medicineJson);
      if (!medicine.isActive) continue;
      for (var time in medicine.times) {
        if (_isTimeMatch(currentTime, time)) {
          _triggerNotification(medicine.name, 'Medicine', medicine.notificationType);
        }
      }
    }

    for (var mealJson in meals) {
      final meal = Meal.fromJson(mealJson);
      if (!meal.isActive) continue;
      if (_isTimeMatch(currentTime, meal.time)) {
        _triggerNotification(meal.name, 'Meal', meal.notificationType);
      }
    }

    for (var activityJson in activities) {
      final activity = Activity.fromJson(activityJson);
      if (!activity.isActive) continue;
      if (_isTimeMatch(currentTime, activity.time)) {
        _triggerNotification(activity.name, 'Activity', activity.notificationType);
      }
    }

    final lastMedicalReminderDate = _storage.read<int>('last_medical_reminder_date');
    const medicalReminderHour = 9;
    const medicalReminderMinute = 0;

    if (now.hour == medicalReminderHour && now.minute == medicalReminderMinute) {
      if (lastMedicalReminderDate != now.day) {
        for (var recordJson in medicalRecords) {
          final record = MedicalRecord.fromJson(recordJson);
          if (!record.isActive) continue;
          if (record.notificationType != 'none') {
            _triggerNotification(record.type, 'Medical Checkup', record.notificationType);
          }
        }
        _storage.write('last_medical_reminder_date', now.day);
      }
    }
  }

  bool _isTimeMatch(TimeOfDay current, TimeOfDay scheduled) {
    return current.hour == scheduled.hour && current.minute == scheduled.minute;
  }

  void _triggerNotification(String name, String type, String notificationType) {
    final title = '$type Reminder';
    final body = 'Time to $name';
    final id = '$name-$type-${DateTime.now().millisecondsSinceEpoch}'.hashCode.abs();

    switch (notificationType) {
      case 'notification':
        NotificationService.showNotification(
          id: id,
          title: title,
          body: body,
        );
        break;
      case 'alarm':
        final alarmTime = DateTime.now().add(const Duration(seconds: 30));
        AlarmService.scheduleAlarm(
          id: id,
          time: alarmTime,
          title: title,
          body: body,
        );
        break;
      case 'both':
        NotificationService.showNotification(
          id: id,
          title: title,
          body: body,
        );
        final alarmTime = DateTime.now().add(const Duration(seconds: 30));
        AlarmService.scheduleAlarm(
          id: id + 1,
          time: alarmTime,
          title: title,
          body: body,
        );
        break;
      default:
        break;
    }
  }

  List<dynamic> _getMedicines() => _storage.read<List<dynamic>>('medicines') ?? [];
  List<dynamic> _getMeals() => _storage.read<List<dynamic>>('meals') ?? [];
  List<dynamic> _getActivities() => _storage.read<List<dynamic>>('activities') ?? [];
  List<dynamic> _getMedicalRecords() => _storage.read<List<dynamic>>('medical_records') ?? [];
}