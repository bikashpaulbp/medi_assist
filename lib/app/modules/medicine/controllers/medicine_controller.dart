import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/core/constants/app_constants.dart';
import 'package:medi_assist/core/services/reminder_scheduler.dart';
import 'package:medi_assist/core/services/storage_service.dart';
import 'package:medi_assist/core/utils/app_utils.dart';
import 'package:medi_assist/core/utils/id_generator.dart';
import 'package:medi_assist/models/medicine_model.dart';


class MedicineController extends GetxController {
  static MedicineController get to => Get.find();

  final RxList<Medicine> medicines = <Medicine>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  // ✅ RxInt — safe to use inside Obx
  final RxInt activeMedicinesCount = 0.obs;

  final nameController = TextEditingController();
  final RxList<TimeOfDay> selectedTimes = <TimeOfDay>[].obs;
  final RxString selectedNotifType = AppConstants.notifTypeNotification.obs;
  final RxBool isActive = true.obs;
  Medicine? editingMedicine;

  List<Medicine> get filteredMedicines {
    if (searchQuery.value.isEmpty) return medicines;
    return medicines
        .where((m) =>
            m.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadMedicines();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void _refreshCounts() {
    activeMedicinesCount.value = medicines.where((m) => m.isActive).length;
  }

  void loadMedicines() {
    isLoading.value = true;
    try {
      final data = StorageService.to.getMedicines();
      medicines.assignAll(data);
      _refreshCounts(); // ✅
    } catch (e) {
      AppUtils.showError('Failed to load medicines');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMedicine() async {
    if (!_validateForm()) return;
    isLoading.value = true;
    try {
      final medicine = Medicine(
        id: IdGenerator.generate(),
        name: nameController.text.trim(),
        times: List.from(selectedTimes),
        notificationType: selectedNotifType.value,
        isActive: isActive.value,
      );
      await StorageService.to.addMedicine(medicine);
      medicines.add(medicine);
      _refreshCounts(); // ✅
      if (medicine.isActive) await ReminderScheduler.scheduleMedicine(medicine);
      AppUtils.showSuccess('${medicine.name} reminder added', title: 'Medicine Added');
      _resetForm();
      Get.back();
    } catch (e) {
      AppUtils.showError('Failed to add medicine. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMedicine() async {
    if (editingMedicine == null || !_validateForm()) return;
    isLoading.value = true;
    try {
      await ReminderScheduler.cancelMedicine(editingMedicine!);
      final updated = editingMedicine!.copyWith(
        name: nameController.text.trim(),
        times: List.from(selectedTimes),
        notificationType: selectedNotifType.value,
        isActive: isActive.value,
      );
      await StorageService.to.updateMedicine(updated);
      final idx = medicines.indexWhere((m) => m.id == updated.id);
      if (idx != -1) medicines[idx] = updated;
      _refreshCounts(); // ✅
      if (updated.isActive) await ReminderScheduler.scheduleMedicine(updated);
      AppUtils.showSuccess('${updated.name} updated', title: 'Medicine Updated');
      _resetForm();
      Get.back();
    } catch (e) {
      AppUtils.showError('Failed to update medicine. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Delete Medicine',
      message: 'Are you sure you want to delete "${medicine.name}"?',
      confirmText: 'Delete',
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    isLoading.value = true;
    try {
      await ReminderScheduler.cancelMedicine(medicine);
      await StorageService.to.deleteMedicine(medicine.id);
      medicines.removeWhere((m) => m.id == medicine.id);
      _refreshCounts(); // ✅
      AppUtils.showSuccess('${medicine.name} deleted', title: 'Deleted');
    } catch (e) {
      AppUtils.showError('Failed to delete medicine.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleActive(Medicine medicine) async {
    try {
      final updated = medicine.copyWith(isActive: !medicine.isActive);
      await StorageService.to.updateMedicine(updated);
      final idx = medicines.indexWhere((m) => m.id == medicine.id);
      if (idx != -1) medicines[idx] = updated;
      _refreshCounts(); // ✅
      if (updated.isActive) {
        await ReminderScheduler.scheduleMedicine(updated);
        AppUtils.showInfo('${updated.name} reminders enabled');
      } else {
        await ReminderScheduler.cancelMedicine(updated);
        AppUtils.showInfo('${updated.name} reminders paused');
      }
    } catch (e) {
      AppUtils.showError('Failed to update medicine status.');
    }
  }

  void prepareForAdd() {
    editingMedicine = null;
    _resetForm();
  }

  void prepareForEdit(Medicine medicine) {
    editingMedicine = medicine;
    nameController.text = medicine.name;
    selectedTimes.assignAll(medicine.times);
    selectedNotifType.value = medicine.notificationType;
    isActive.value = medicine.isActive;
  }

  void addTime(TimeOfDay time) {
    final exists = selectedTimes.any((t) => t.hour == time.hour && t.minute == time.minute);
    if (!exists) {
      selectedTimes.add(time);
      selectedTimes.sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
    } else {
      AppUtils.showWarning('This time is already added');
    }
  }

  void removeTime(int index) {
    if (selectedTimes.length > 1) {
      selectedTimes.removeAt(index);
    } else {
      AppUtils.showWarning('At least one time is required');
    }
  }

  void setNotifType(String type) => selectedNotifType.value = type;

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      AppUtils.showError('Please enter medicine name');
      return false;
    }
    if (selectedTimes.isEmpty) {
      AppUtils.showError('Please add at least one reminder time');
      return false;
    }
    return true;
  }

  void _resetForm() {
    nameController.clear();
    selectedTimes.clear();
    selectedNotifType.value = AppConstants.notifTypeNotification;
    isActive.value = true;
    editingMedicine = null;
  }

  void setSearchQuery(String query) => searchQuery.value = query;
  void clearSearch() => searchQuery.value = '';
}