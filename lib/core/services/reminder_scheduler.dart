import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
import '../../models/meal_model.dart';
import '../../models/activity_model.dart';
import '../constants/app_constants.dart';
import '../utils/id_generator.dart';
import 'alarm_service.dart';
import 'notification_service.dart';

/// Central scheduler that handles both notifications and alarms
/// based on the notificationType setting of each item.
class ReminderScheduler {
  ReminderScheduler._();

  // ─── MEDICINE ────────────────────────────────────────────────────────────────

  static Future<void> scheduleMedicine(Medicine medicine) async {
    await cancelMedicine(medicine);

    if (!medicine.isActive) return;
    if (medicine.notificationType == AppConstants.notifTypeNone) return;

    final notifBaseId = AppConstants.medicineNotifBase +
        (medicine.id.hashCode.abs() % 100) * 10;
    final alarmBaseId = AppConstants.medicineAlarmBase +
        (medicine.id.hashCode.abs() % 100) * 10;

    final type = medicine.notificationType;

    // Schedule notification
    if (type == AppConstants.notifTypeNotification ||
        type == AppConstants.notifTypeBoth) {
      await NotificationService.to.scheduleMedicineNotifications(
        medicineId: medicine.id,
        medicineName: medicine.name,
        times: medicine.times,
        baseId: notifBaseId,
      );
    }

    // Schedule alarm
    if (type == AppConstants.notifTypeAlarm ||
        type == AppConstants.notifTypeBoth) {
      await AlarmService.to.scheduleMedicineAlarms(
        medicineId: medicine.id,
        medicineName: medicine.name,
        times: medicine.times,
        baseAlarmId: alarmBaseId,
      );
    }
  }

  static Future<void> cancelMedicine(Medicine medicine) async {
    final notifBaseId = AppConstants.medicineNotifBase +
        (medicine.id.hashCode.abs() % 100) * 10;
    final alarmBaseId = AppConstants.medicineAlarmBase +
        (medicine.id.hashCode.abs() % 100) * 10;

    await NotificationService.to.cancelMedicineNotifications(
      medicineId: medicine.id,
      times: medicine.times,
      baseId: notifBaseId,
    );
    await AlarmService.to.cancelMedicineAlarms(
      times: medicine.times,
      baseAlarmId: alarmBaseId,
    );
  }

  // ─── MEAL ────────────────────────────────────────────────────────────────────

  static Future<void> scheduleMeal(Meal meal) async {
    await cancelMeal(meal);

    if (!meal.isActive) return;
    if (meal.notificationType == AppConstants.notifTypeNone) return;

    final notifId =
        AppConstants.mealNotifBase + (meal.id.hashCode.abs() % 1000);
    final alarmId =
        AppConstants.mealAlarmBase + (meal.id.hashCode.abs() % 1000);

    final type = meal.notificationType;

    if (type == AppConstants.notifTypeNotification ||
        type == AppConstants.notifTypeBoth) {
      await NotificationService.to.scheduleMealNotification(
        mealId: meal.id,
        mealName: meal.name,
        time: meal.time,
        notifId: notifId,
      );
    }

    if (type == AppConstants.notifTypeAlarm ||
        type == AppConstants.notifTypeBoth) {
      await AlarmService.to.scheduleMealAlarm(
        mealId: meal.id,
        mealName: meal.name,
        time: meal.time,
        alarmId: alarmId,
      );
    }
  }

  static Future<void> cancelMeal(Meal meal) async {
    final notifId =
        AppConstants.mealNotifBase + (meal.id.hashCode.abs() % 1000);
    final alarmId =
        AppConstants.mealAlarmBase + (meal.id.hashCode.abs() % 1000);

    await NotificationService.to.cancelNotification(notifId);
    await AlarmService.to.cancelAlarm(alarmId);
  }

  // ─── ACTIVITY ────────────────────────────────────────────────────────────────

  static Future<void> scheduleActivity(Activity activity) async {
    await cancelActivity(activity);

    if (!activity.isActive) return;
    if (activity.notificationType == AppConstants.notifTypeNone) return;

    final notifId =
        AppConstants.activityNotifBase + (activity.id.hashCode.abs() % 1000);
    final alarmId =
        AppConstants.activityAlarmBase + (activity.id.hashCode.abs() % 1000);

    final type = activity.notificationType;

    if (type == AppConstants.notifTypeNotification ||
        type == AppConstants.notifTypeBoth) {
      await NotificationService.to.scheduleActivityNotification(
        activityId: activity.id,
        activityName: activity.name,
        time: activity.time,
        notifId: notifId,
      );
    }

    if (type == AppConstants.notifTypeAlarm ||
        type == AppConstants.notifTypeBoth) {
      await AlarmService.to.scheduleActivityAlarm(
        activityId: activity.id,
        activityName: activity.name,
        time: activity.time,
        alarmId: alarmId,
      );
    }
  }

  static Future<void> cancelActivity(Activity activity) async {
    final notifId =
        AppConstants.activityNotifBase + (activity.id.hashCode.abs() % 1000);
    final alarmId =
        AppConstants.activityAlarmBase + (activity.id.hashCode.abs() % 1000);

    await NotificationService.to.cancelNotification(notifId);
    await AlarmService.to.cancelAlarm(alarmId);
  }

  // ─── Reschedule Everything ───────────────────────────────────────────────────
  static Future<void> rescheduleAll({
    required List<Medicine> medicines,
    required List<Meal> meals,
    required List<Activity> activities,
  }) async {
    debugPrint('🔄 Rescheduling all reminders...');

    for (final m in medicines) {
      await scheduleMedicine(m);
    }
    for (final m in meals) {
      await scheduleMeal(m);
    }
    for (final a in activities) {
      await scheduleActivity(a);
    }

    debugPrint('✅ All reminders rescheduled');
  }
}