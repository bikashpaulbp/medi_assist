import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/core/constants/app_constants.dart';
import 'package:medi_assist/core/services/reminder_scheduler.dart';
import 'package:medi_assist/core/services/storage_service.dart';
import 'package:medi_assist/core/utils/app_utils.dart';
import 'package:medi_assist/core/utils/id_generator.dart';
import 'package:medi_assist/models/meal_model.dart';


class MealController extends GetxController {
  static MealController get to => Get.find();

  final RxList<Meal> meals = <Meal>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  // ✅ RxInt — safe inside Obx
  final RxInt activeMealsCount = 0.obs;

  final nameController = TextEditingController();
  final Rx<TimeOfDay> selectedTime = const TimeOfDay(hour: 8, minute: 0).obs;
  final RxString selectedNotifType = AppConstants.notifTypeNotification.obs;
  final RxBool isActive = true.obs;
  Meal? editingMeal;

  List<Meal> get filteredMeals {
    if (searchQuery.value.isEmpty) return meals;
    return meals
        .where((m) =>
            m.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadMeals();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void _refreshCounts() {
    activeMealsCount.value = meals.where((m) => m.isActive).length;
  }

  void loadMeals() {
    isLoading.value = true;
    try {
      final data = StorageService.to.getMeals();
      meals.assignAll(data);
      _refreshCounts();
    } catch (e) {
      AppUtils.showError('Failed to load meals');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMeal() async {
    if (!_validateForm()) return;
    isLoading.value = true;
    try {
      final meal = Meal(
        id: IdGenerator.generate(),
        name: nameController.text.trim(),
        time: selectedTime.value,
        notificationType: selectedNotifType.value,
        isActive: isActive.value,
      );
      await StorageService.to.addMeal(meal);
      meals.add(meal);
      _refreshCounts();
      if (meal.isActive) await ReminderScheduler.scheduleMeal(meal);
      AppUtils.showSuccess('${meal.name} reminder added', title: 'Meal Added');
      _resetForm();
      Get.back();
    } catch (e) {
      AppUtils.showError('Failed to add meal. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMeal() async {
    if (editingMeal == null || !_validateForm()) return;
    isLoading.value = true;
    try {
      await ReminderScheduler.cancelMeal(editingMeal!);
      final updated = editingMeal!.copyWith(
        name: nameController.text.trim(),
        time: selectedTime.value,
        notificationType: selectedNotifType.value,
        isActive: isActive.value,
      );
      await StorageService.to.updateMeal(updated);
      final idx = meals.indexWhere((m) => m.id == updated.id);
      if (idx != -1) meals[idx] = updated;
      _refreshCounts();
      if (updated.isActive) await ReminderScheduler.scheduleMeal(updated);
      AppUtils.showSuccess('${updated.name} updated', title: 'Meal Updated');
      _resetForm();
      Get.back();
    } catch (e) {
      AppUtils.showError('Failed to update meal. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMeal(Meal meal) async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Delete Meal',
      message: 'Are you sure you want to delete "${meal.name}"?',
      confirmText: 'Delete',
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    isLoading.value = true;
    try {
      await ReminderScheduler.cancelMeal(meal);
      await StorageService.to.deleteMeal(meal.id);
      meals.removeWhere((m) => m.id == meal.id);
      _refreshCounts();
      AppUtils.showSuccess('${meal.name} deleted', title: 'Deleted');
    } catch (e) {
      AppUtils.showError('Failed to delete meal.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleActive(Meal meal) async {
    try {
      final updated = meal.copyWith(isActive: !meal.isActive);
      await StorageService.to.updateMeal(updated);
      final idx = meals.indexWhere((m) => m.id == meal.id);
      if (idx != -1) meals[idx] = updated;
      _refreshCounts();
      if (updated.isActive) {
        await ReminderScheduler.scheduleMeal(updated);
        AppUtils.showInfo('${updated.name} reminders enabled');
      } else {
        await ReminderScheduler.cancelMeal(updated);
        AppUtils.showInfo('${updated.name} reminders paused');
      }
    } catch (e) {
      AppUtils.showError('Failed to update meal status.');
    }
  }

  void prepareForAdd() {
    editingMeal = null;
    _resetForm();
  }

  void prepareForEdit(Meal meal) {
    editingMeal = meal;
    nameController.text = meal.name;
    selectedTime.value = meal.time;
    selectedNotifType.value = meal.notificationType;
    isActive.value = meal.isActive;
  }

  void setTime(TimeOfDay time) => selectedTime.value = time;
  void setNotifType(String type) => selectedNotifType.value = type;

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      AppUtils.showError('Please enter meal name');
      return false;
    }
    if (nameController.text.trim().length < 2) {
      AppUtils.showError('Meal name must be at least 2 characters');
      return false;
    }
    return true;
  }

  void _resetForm() {
    nameController.clear();
    selectedTime.value = const TimeOfDay(hour: 8, minute: 0);
    selectedNotifType.value = AppConstants.notifTypeNotification;
    isActive.value = true;
    editingMeal = null;
  }

  void setSearchQuery(String query) => searchQuery.value = query;
  void clearSearch() => searchQuery.value = '';
}