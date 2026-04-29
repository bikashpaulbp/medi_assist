// lib/controllers/meal_controller.dart
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/meal_model.dart';
import '../core/services/storage_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/alarm_service.dart';

class MealController extends GetxController {
  final StorageService _storage = StorageService();
  final RxList<Meal> meals = <Meal>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMeals();
  }

  void loadMeals() {
    meals.value = _storage.getMeals();
  }

  Future<void> addMeal(Meal meal) async {
    final newMeal = meal.id.isEmpty ? meal.copyWith(id: const Uuid().v4()) : meal;
    _storage.saveMeal(newMeal);
    loadMeals();
    await scheduleReminderForMeal(newMeal, isNew: true);
  }

  Future<void> updateMeal(Meal meal) async {
    await cancelReminderForMeal(meal);
    _storage.saveMeal(meal);
    loadMeals();
    await scheduleReminderForMeal(meal);
  }

  Future<void> deleteMeal(String id) async {
    final meal = meals.firstWhere((m) => m.id == id);
    await cancelReminderForMeal(meal);
    _storage.deleteMeal(id);
    loadMeals();
  }

  Future<void> scheduleReminderForMeal(Meal meal, {bool isNew = false}) async {
    if (!meal.isActive) return;

    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year, now.month, now.day, meal.time.hour, meal.time.minute,
    );
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final uniqueId = meal.id.hashCode.abs() % 100000;

    switch (meal.notificationType) {
      case 'notification':
        await NotificationService.showNotification(
          id: uniqueId,
          title: 'Meal Reminder',
          body: 'Time for ${meal.name}',
        );
        break;
      case 'alarm':
        await AlarmService.scheduleAlarm(
          id: uniqueId,
          time: scheduledTime,
          title: 'Meal Alarm',
          body: 'Time for ${meal.name}',
        );
        break;
      case 'both':
        await NotificationService.showNotification(
          id: uniqueId,
          title: 'Meal Reminder',
          body: 'Time for ${meal.name}',
        );
        await AlarmService.scheduleAlarm(
          id: uniqueId + 1000,
          time: scheduledTime,
          title: 'Meal Alarm',
          body: 'Time for ${meal.name}',
        );
        break;
      case 'none':
      default:
        break;
    }
  }

  Future<void> cancelReminderForMeal(Meal meal) async {
    final uniqueId = meal.id.hashCode.abs() % 100000;
    await AlarmService.cancelAlarm(uniqueId);
  }
}