import 'package:flutter/foundation.dart';
import '../../models/medicine_model.dart';
import '../../models/meal_model.dart';
import '../../models/activity_model.dart';
import '../constants/app_constants.dart';
import 'alarm_service.dart';
import 'notification_service.dart';

/// Central scheduler — single entry point for all reminder scheduling.
/// Routes each item to notification/alarm/both based on notificationType.
/// All methods are safe to call multiple times (cancel-before-reschedule pattern).
class ReminderScheduler {
  ReminderScheduler._();

  // ════════════════════════════════════════════════════════════════
  // ─── MEDICINE ────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════

  static Future<void> scheduleMedicine(Medicine medicine) async {
    // Always cancel existing first — prevents duplicate reminders
    await cancelMedicine(medicine);

    if (!medicine.isActive) return;
    if (medicine.notificationType == AppConstants.notifTypeNone) return;
    if (medicine.times.isEmpty) return;

    final notifBaseId = _medicineNotifBase(medicine.id);
    final alarmBaseId = _medicineAlarmBase(medicine.id);
    final type = medicine.notificationType;

    try {
      if (type == AppConstants.notifTypeNotification ||
          type == AppConstants.notifTypeBoth) {
        await NotificationService.to.scheduleMedicineNotifications(
          medicineId: medicine.id,
          medicineName: medicine.name,
          times: medicine.times,
          baseId: notifBaseId,
        );
      }

      if (type == AppConstants.notifTypeAlarm ||
          type == AppConstants.notifTypeBoth) {
        await AlarmService.to.scheduleMedicineAlarms(
          medicineId: medicine.id,
          medicineName: medicine.name,
          times: medicine.times,
          baseAlarmId: alarmBaseId,
        );
      }

      debugPrint(
          '✅ Medicine "${medicine.name}" scheduled ($type, ${medicine.times.length} time(s))');
    } catch (e) {
      debugPrint('❌ Failed to schedule medicine "${medicine.name}": $e');
    }
  }

  static Future<void> cancelMedicine(Medicine medicine) async {
    try {
      await NotificationService.to.cancelMedicineNotifications(
        medicineId: medicine.id,
        times: medicine.times,
        baseId: _medicineNotifBase(medicine.id),
      );
      await AlarmService.to.cancelMedicineAlarms(
        times: medicine.times,
        baseAlarmId: _medicineAlarmBase(medicine.id),
      );
    } catch (e) {
      debugPrint('⚠️ Cancel medicine warning: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ─── MEAL ────────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════

  static Future<void> scheduleMeal(Meal meal) async {
    await cancelMeal(meal);

    if (!meal.isActive) return;
    if (meal.notificationType == AppConstants.notifTypeNone) return;

    final notifId = _mealNotifId(meal.id);
    final alarmId = _mealAlarmId(meal.id);
    final type = meal.notificationType;

    try {
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

      debugPrint('✅ Meal "${meal.name}" scheduled ($type)');
    } catch (e) {
      debugPrint('❌ Failed to schedule meal "${meal.name}": $e');
    }
  }

  static Future<void> cancelMeal(Meal meal) async {
    try {
      await NotificationService.to.cancelNotification(_mealNotifId(meal.id));
      await AlarmService.to.cancelAlarm(_mealAlarmId(meal.id));
    } catch (e) {
      debugPrint('⚠️ Cancel meal warning: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ─── ACTIVITY ────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════

  static Future<void> scheduleActivity(Activity activity) async {
    await cancelActivity(activity);

    if (!activity.isActive) return;
    if (activity.notificationType == AppConstants.notifTypeNone) return;

    final notifId = _activityNotifId(activity.id);
    final alarmId = _activityAlarmId(activity.id);
    final type = activity.notificationType;

    try {
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

      debugPrint('✅ Activity "${activity.name}" scheduled ($type)');
    } catch (e) {
      debugPrint('❌ Failed to schedule activity "${activity.name}": $e');
    }
  }

  static Future<void> cancelActivity(Activity activity) async {
    try {
      await NotificationService.to
          .cancelNotification(_activityNotifId(activity.id));
      await AlarmService.to.cancelAlarm(_activityAlarmId(activity.id));
    } catch (e) {
      debugPrint('⚠️ Cancel activity warning: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ─── RESCHEDULE ALL ──────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════

  static Future<void> rescheduleAll({
    required List<Medicine> medicines,
    required List<Meal> meals,
    required List<Activity> activities,
  }) async {
    debugPrint(
        '🔄 Rescheduling all — medicines:${medicines.length} meals:${meals.length} activities:${activities.length}');

    int successCount = 0;
    int failCount = 0;

    for (final m in medicines) {
      try {
        await scheduleMedicine(m);
        successCount++;
      } catch (_) {
        failCount++;
      }
    }
    for (final m in meals) {
      try {
        await scheduleMeal(m);
        successCount++;
      } catch (_) {
        failCount++;
      }
    }
    for (final a in activities) {
      try {
        await scheduleActivity(a);
        successCount++;
      } catch (_) {
        failCount++;
      }
    }

    debugPrint(
        '✅ Reschedule complete — $successCount succeeded, $failCount failed');
  }

  // ════════════════════════════════════════════════════════════════
  // ─── ID HELPERS — consistent across scheduler & foreground service ──
  // ════════════════════════════════════════════════════════════════

  static int _medicineNotifBase(String id) =>
      AppConstants.medicineNotifBase + (id.hashCode.abs() % 100) * 10;

  static int _medicineAlarmBase(String id) =>
      AppConstants.medicineAlarmBase + (id.hashCode.abs() % 100) * 10;

  static int _mealNotifId(String id) =>
      AppConstants.mealNotifBase + (id.hashCode.abs() % 1000);

  static int _mealAlarmId(String id) =>
      AppConstants.mealAlarmBase + (id.hashCode.abs() % 1000);

  static int _activityNotifId(String id) =>
      AppConstants.activityNotifBase + (id.hashCode.abs() % 1000);

  static int _activityAlarmId(String id) =>
      AppConstants.activityAlarmBase + (id.hashCode.abs() % 1000);
}