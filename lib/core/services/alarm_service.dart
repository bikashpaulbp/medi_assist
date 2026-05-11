import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';

class AlarmService extends GetxService {
  static AlarmService get to => Get.find();

  // ─── Core schedule method ─────────────────────────────────────────────────
  Future<void> scheduleAlarm({
    required int alarmId,
    required String title,
    required String body,
    required int hour,
    required int minute,
    bool loopAudio = true,
    bool vibrate = true,
  }) async {
    try {
      final now = DateTime.now();
      DateTime scheduledTime = DateTime(
        now.year, now.month, now.day, hour, minute, 0,
      );

      // If time already passed today (or within 10 seconds), schedule tomorrow
      if (scheduledTime.isBefore(now) ||
          scheduledTime.difference(now).inSeconds < 10) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: scheduledTime,
        assetAudioPath: AppConstants.alarmAudioPath,
        loopAudio: loopAudio,
        vibrate: vibrate,
        volumeSettings: VolumeSettings.fade(
          volume: 1.0,
          fadeDuration: const Duration(seconds: 3),
        ),
        // ✅ Show warning notification if app is killed before alarm fires
        warningNotificationOnKill: true,
        // ✅ Full screen intent — shows over lock screen
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: title,
          body: body,
          // ✅ Stop button in notification bar — user can stop without opening app
          stopButton: 'Stop Alarm',
          icon: 'notification_icon',
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);
      debugPrint('✅ Alarm set: id=$alarmId at $hour:$minute → $scheduledTime');
    } catch (e) {
      debugPrint('❌ Failed to set alarm id=$alarmId: $e');
    }
  }

  // ─── Cancel ───────────────────────────────────────────────────────────────
  Future<void> cancelAlarm(int alarmId) async {
    try {
      await Alarm.stop(alarmId);
      debugPrint('🗑️ Alarm cancelled: id=$alarmId');
    } catch (e) {
      debugPrint('❌ Failed to cancel alarm id=$alarmId: $e');
    }
  }

  Future<void> cancelAlarms(List<int> alarmIds) async {
    for (final id in alarmIds) {
      await cancelAlarm(id);
    }
  }

  // ─── Query ────────────────────────────────────────────────────────────────
  Future<List<AlarmSettings>> getActiveAlarms() async {
    return await Alarm.getAlarms();
  }

  Future<bool> isAlarmActive(int alarmId) async {
    final alarms = await Alarm.getAlarms();
    return alarms.any((a) => a.id == alarmId);
  }

  // ─── Medicine alarms ──────────────────────────────────────────────────────
  Future<void> scheduleMedicineAlarms({
    required String medicineId,
    required String medicineName,
    required List<TimeOfDay> times,
    required int baseAlarmId,
  }) async {
    await cancelMedicineAlarms(times: times, baseAlarmId: baseAlarmId);

    for (int i = 0; i < times.length; i++) {
      await scheduleAlarm(
        alarmId: baseAlarmId + i,
        title: '💊 Medicine Alarm',
        body: 'Time to take $medicineName',
        hour: times[i].hour,
        minute: times[i].minute,
        loopAudio: true,
        vibrate: true,
      );
    }
  }

  Future<void> cancelMedicineAlarms({
    required List<TimeOfDay> times,
    required int baseAlarmId,
  }) async {
    for (int i = 0; i < times.length; i++) {
      await cancelAlarm(baseAlarmId + i);
    }
  }

  // ─── Meal alarms ──────────────────────────────────────────────────────────
  Future<void> scheduleMealAlarm({
    required String mealId,
    required String mealName,
    required TimeOfDay time,
    required int alarmId,
  }) async {
    await cancelAlarm(alarmId);
    await scheduleAlarm(
      alarmId: alarmId,
      title: '🍽️ Meal Alarm',
      body: 'Time for $mealName',
      hour: time.hour,
      minute: time.minute,
      loopAudio: false,
      vibrate: true,
    );
  }

  // ─── Activity alarms ──────────────────────────────────────────────────────
  Future<void> scheduleActivityAlarm({
    required String activityId,
    required String activityName,
    required TimeOfDay time,
    required int alarmId,
  }) async {
    await cancelAlarm(alarmId);
    await scheduleAlarm(
      alarmId: alarmId,
      title: '🏃 Activity Alarm',
      body: 'Time for $activityName',
      hour: time.hour,
      minute: time.minute,
      loopAudio: false,
      vibrate: true,
    );
  }

  // ─── Reschedule all (called from settings or after permissions granted) ───
  Future<void> rescheduleAll({
    required List<dynamic> medicines,
    required List<dynamic> meals,
    required List<dynamic> activities,
  }) async {
    debugPrint('🔄 Rescheduling all alarms...');

    for (final medicine in medicines) {
      if (!medicine.isActive) continue;
      final notifType = medicine.notificationType as String;
      if (notifType != AppConstants.notifTypeAlarm &&
          notifType != AppConstants.notifTypeBoth) continue;

      final baseId = AppConstants.medicineAlarmBase +
          (medicine.id.hashCode.abs() % 100) * 10;
      await scheduleMedicineAlarms(
        medicineId: medicine.id,
        medicineName: medicine.name,
        times: medicine.times,
        baseAlarmId: baseId,
      );
    }

    for (final meal in meals) {
      if (!meal.isActive) continue;
      final notifType = meal.notificationType as String;
      if (notifType != AppConstants.notifTypeAlarm &&
          notifType != AppConstants.notifTypeBoth) continue;

      final alarmId =
          AppConstants.mealAlarmBase + (meal.id.hashCode.abs() % 1000);
      await scheduleMealAlarm(
        mealId: meal.id,
        mealName: meal.name,
        time: meal.time,
        alarmId: alarmId,
      );
    }

    for (final activity in activities) {
      if (!activity.isActive) continue;
      final notifType = activity.notificationType as String;
      if (notifType != AppConstants.notifTypeAlarm &&
          notifType != AppConstants.notifTypeBoth) continue;

      final alarmId =
          AppConstants.activityAlarmBase + (activity.id.hashCode.abs() % 1000);
      await scheduleActivityAlarm(
        activityId: activity.id,
        activityName: activity.name,
        time: activity.time,
        alarmId: alarmId,
      );
    }

    debugPrint('✅ All alarms rescheduled');
  }
}