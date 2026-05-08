import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/core/constants/app_constants.dart';
import 'package:medi_assist/core/services/storage_service.dart';
import 'package:medi_assist/core/utils/app_utils.dart';
import 'package:medi_assist/core/utils/id_generator.dart';
import 'package:medi_assist/models/medical_record_model.dart';


class MedicalRecordsController extends GetxController {
  static MedicalRecordsController get to => Get.find();

  // ─── State ───────────────────────────────────────────────────────────────────
  final RxList<MedicalRecord> allRecords = <MedicalRecord>[].obs;
  final RxList<MedicalRecord> filteredRecords = <MedicalRecord>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentType = ''.obs;

  // ─── Form State ──────────────────────────────────────────────────────────────
  final resultController = TextEditingController();
  final notesController = TextEditingController();
  final RxString selectedCategory = ''.obs;
  final Rx<DateTime> selectedDateTime = DateTime.now().obs;
  MedicalRecord? editingRecord;

  // ─── Summary Stats per type ──────────────────────────────────────────────────
  Map<String, int> get recordCountByType {
    final map = <String, int>{};
    for (final type in AppConstants.medicalRecordTypes) {
      map[type] = allRecords.where((r) => r.type == type).length;
    }
    return map;
  }

  MedicalRecord? latestRecordOfType(String type) {
    final records = allRecords.where((r) => r.type == type).toList();
    if (records.isEmpty) return null;
    records.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return records.first;
  }

  // ─── Category options based on type ──────────────────────────────────────────
  List<String> getCategoriesForType(String type) {
    switch (type) {
      case AppConstants.recordBloodPressure:
        return AppConstants.bloodPressureCategories;
      case AppConstants.recordHeartRate:
        return AppConstants.heartRateCategories;
      case AppConstants.recordOxygenLevel:
        return AppConstants.oxygenCategories;
      case AppConstants.recordDiabetesLevel:
        return AppConstants.diabetesCategories;
      case AppConstants.recordTemperature:
        return AppConstants.temperatureCategories;
      case AppConstants.recordWeight:
        return AppConstants.weightCategories;
      default:
        return [];
    }
  }

  String getUnitForType(String type) {
    return AppConstants.medicalRecordUnits[type] ?? '';
  }

  String getLabelForType(String type) {
    return AppConstants.medicalRecordLabels[type] ?? type;
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    loadAllRecords();
  }

  @override
  void onClose() {
    resultController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // ─── Load ────────────────────────────────────────────────────────────────────
  void loadAllRecords() {
    isLoading.value = true;
    try {
      final data = StorageService.to.getMedicalRecords();
      allRecords.assignAll(data);
      if (currentType.value.isNotEmpty) {
        _filterByCurrentType();
      }
    } catch (e) {
      AppUtils.showError('Failed to load medical records');
    } finally {
      isLoading.value = false;
    }
  }

  void loadRecordsByType(String type) {
    currentType.value = type;
    _filterByCurrentType();
  }

  void _filterByCurrentType() {
    final records = allRecords
        .where((r) => r.type == currentType.value)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    filteredRecords.assignAll(records);
  }

  // ─── Add Record ──────────────────────────────────────────────────────────────
  Future<void> addRecord(String type) async {
    if (!_validateForm(type)) return;

    isLoading.value = true;
    try {
      final record = MedicalRecord(
        id: IdGenerator.generate(),
        type: type,
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        result: resultController.text.trim(),
        dateTime: selectedDateTime.value,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      await StorageService.to.addMedicalRecord(record);
      allRecords.add(record);
      _filterByCurrentType();

      AppUtils.showSuccess(
        'Record saved successfully',
        title: '${getLabelForType(type)} Added',
      );
      _resetForm();
      Get.back();
    } catch (e) {
      AppUtils.showError('Failed to save record. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Update Record ───────────────────────────────────────────────────────────
  Future<void> updateRecord(String type) async {
    if (editingRecord == null) return;
    if (!_validateForm(type)) return;

    isLoading.value = true;
    try {
      final updated = editingRecord!.copyWith(
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        result: resultController.text.trim(),
        dateTime: selectedDateTime.value,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      await StorageService.to.updateMedicalRecord(updated);
      final idx = allRecords.indexWhere((r) => r.id == updated.id);
      if (idx != -1) allRecords[idx] = updated;
      _filterByCurrentType();

      AppUtils.showSuccess('Record updated', title: 'Updated');
      _resetForm();
      Get.back();
    } catch (e) {
      AppUtils.showError('Failed to update record. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Delete Record ───────────────────────────────────────────────────────────
  Future<void> deleteRecord(MedicalRecord record) async {
    final confirmed = await AppUtils.showConfirmDialog(
      title: 'Delete Record',
      message: 'Are you sure you want to delete this record?',
      confirmText: 'Delete',
      icon: Icons.delete_outline_rounded,
    );

    if (!confirmed) return;

    isLoading.value = true;
    try {
      await StorageService.to.deleteMedicalRecord(record.id);
      allRecords.removeWhere((r) => r.id == record.id);
      _filterByCurrentType();
      AppUtils.showSuccess('Record deleted', title: 'Deleted');
    } catch (e) {
      AppUtils.showError('Failed to delete record.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Form Helpers ─────────────────────────────────────────────────────────────
  void prepareForAdd(String type) {
    editingRecord = null;
    _resetForm();
    currentType.value = type;
    // Set default category
    final categories = getCategoriesForType(type);
    if (categories.isNotEmpty) {
      selectedCategory.value = categories.first;
    }
  }

  void prepareForEdit(MedicalRecord record) {
    editingRecord = record;
    currentType.value = record.type;
    resultController.text = record.result;
    notesController.text = record.notes ?? '';
    selectedCategory.value = record.category ?? '';
    selectedDateTime.value = record.dateTime;
  }

  void setCategory(String category) => selectedCategory.value = category;

  void setDateTime(DateTime dt) => selectedDateTime.value = dt;

  bool _validateForm(String type) {
    if (resultController.text.trim().isEmpty) {
      AppUtils.showError('Please enter the result value');
      return false;
    }
    return true;
  }

  void _resetForm() {
    resultController.clear();
    notesController.clear();
    selectedCategory.value = '';
    selectedDateTime.value = DateTime.now();
    editingRecord = null;
  }
}