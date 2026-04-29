// lib/controllers/activity_controller.dart
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/activity_model.dart';
import '../core/services/storage_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/alarm_service.dart';

class ActivityController extends GetxController {
  final StorageService _storage = StorageService();
  final RxList<Activity> activities = <Activity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadActivities();
  }

  void loadActivities() {
    activities.value = _storage.getActivities();
  }

  Future<void> addActivity(Activity activity) async {
    final newActivity = activity.id.isEmpty ? activity.copyWith(id: const Uuid().v4()) : activity;
    _storage.saveActivity(newActivity);
    loadActivities();
    await scheduleReminderForActivity(newActivity);
  }

  Future<void> updateActivity(Activity activity) async {
    await cancelReminderForActivity(activity);
    _storage.saveActivity(activity);
    loadActivities();
    await scheduleReminderForActivity(activity);
  }

  Future<void> deleteActivity(String id) async {
    final activity = activities.firstWhere((a) => a.id == id);
    await cancelReminderForActivity(activity);
    _storage.deleteActivity(id);
    loadActivities();
  }

  Future<void> scheduleReminderForActivity(Activity activity) async {
    if (!activity.isActive) return;

    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year, now.month, now.day, activity.time.hour, activity.time.minute,
    );
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final uniqueId = activity.id.hashCode.abs() % 100000;

    switch (activity.notificationType) {
      case 'notification':
        await NotificationService.showNotification(
          id: uniqueId,
          title: 'Activity Reminder',
          body: 'Time to ${activity.name}',
        );
        break;
      case 'alarm':
        await AlarmService.scheduleAlarm(
          id: uniqueId,
          time: scheduledTime,
          title: 'Activity Alarm',
          body: 'Time to ${activity.name}',
        );
        break;
      case 'both':
        await NotificationService.showNotification(
          id: uniqueId,
          title: 'Activity Reminder',
          body: 'Time to ${activity.name}',
        );
        await AlarmService.scheduleAlarm(
          id: uniqueId + 1000,
          time: scheduledTime,
          title: 'Activity Alarm',
          body: 'Time to ${activity.name}',
        );
        break;
      case 'none':
      default:
        break;
    }
  }

  Future<void> cancelReminderForActivity(Activity activity) async {
    final uniqueId = activity.id.hashCode.abs() % 100000;
    await AlarmService.cancelAlarm(uniqueId);
  }
}