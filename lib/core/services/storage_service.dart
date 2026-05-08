import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/medicine_model.dart';
import '../../models/meal_model.dart';
import '../../models/medical_record_model.dart';
import '../../models/activity_model.dart';
import '../constants/app_constants.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  final _box = GetStorage();

  // ─── MEDICINE ────────────────────────────────────────────────────────────────

  List<Medicine> getMedicines() {
    try {
      final data = _box.read<List>(AppConstants.medicinesKey);
      if (data == null) return [];
      return data
          .map((e) => Medicine.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMedicines(List<Medicine> medicines) async {
    final data = medicines.map((e) => e.toJson()).toList();
    await _box.write(AppConstants.medicinesKey, data);
  }

  Future<void> addMedicine(Medicine medicine) async {
    final list = getMedicines();
    list.add(medicine);
    await saveMedicines(list);
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final list = getMedicines();
    final idx = list.indexWhere((e) => e.id == medicine.id);
    if (idx != -1) {
      list[idx] = medicine;
      await saveMedicines(list);
    }
  }

  Future<void> deleteMedicine(String id) async {
    final list = getMedicines();
    list.removeWhere((e) => e.id == id);
    await saveMedicines(list);
  }

  // ─── MEAL ────────────────────────────────────────────────────────────────────

  List<Meal> getMeals() {
    try {
      final data = _box.read<List>(AppConstants.mealsKey);
      if (data == null) return [];
      return data
          .map((e) => Meal.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMeals(List<Meal> meals) async {
    final data = meals.map((e) => e.toJson()).toList();
    await _box.write(AppConstants.mealsKey, data);
  }

  Future<void> addMeal(Meal meal) async {
    final list = getMeals();
    list.add(meal);
    await saveMeals(list);
  }

  Future<void> updateMeal(Meal meal) async {
    final list = getMeals();
    final idx = list.indexWhere((e) => e.id == meal.id);
    if (idx != -1) {
      list[idx] = meal;
      await saveMeals(list);
    }
  }

  Future<void> deleteMeal(String id) async {
    final list = getMeals();
    list.removeWhere((e) => e.id == id);
    await saveMeals(list);
  }

  // ─── MEDICAL RECORDS ─────────────────────────────────────────────────────────

  List<MedicalRecord> getMedicalRecords() {
    try {
      final data = _box.read<List>(AppConstants.medicalRecordsKey);
      if (data == null) return [];
      return data
          .map((e) => MedicalRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<MedicalRecord> getMedicalRecordsByType(String type) {
    return getMedicalRecords().where((e) => e.type == type).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  Future<void> saveMedicalRecords(List<MedicalRecord> records) async {
    final data = records.map((e) => e.toJson()).toList();
    await _box.write(AppConstants.medicalRecordsKey, data);
  }

  Future<void> addMedicalRecord(MedicalRecord record) async {
    final list = getMedicalRecords();
    list.add(record);
    await saveMedicalRecords(list);
  }

  Future<void> updateMedicalRecord(MedicalRecord record) async {
    final list = getMedicalRecords();
    final idx = list.indexWhere((e) => e.id == record.id);
    if (idx != -1) {
      list[idx] = record;
      await saveMedicalRecords(list);
    }
  }

  Future<void> deleteMedicalRecord(String id) async {
    final list = getMedicalRecords();
    list.removeWhere((e) => e.id == id);
    await saveMedicalRecords(list);
  }

  // ─── ACTIVITY ────────────────────────────────────────────────────────────────

  List<Activity> getActivities() {
    try {
      final data = _box.read<List>(AppConstants.activitiesKey);
      if (data == null) return [];
      return data
          .map((e) => Activity.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveActivities(List<Activity> activities) async {
    final data = activities.map((e) => e.toJson()).toList();
    await _box.write(AppConstants.activitiesKey, data);
  }

  Future<void> addActivity(Activity activity) async {
    final list = getActivities();
    list.add(activity);
    await saveActivities(list);
  }

  Future<void> updateActivity(Activity activity) async {
    final list = getActivities();
    final idx = list.indexWhere((e) => e.id == activity.id);
    if (idx != -1) {
      list[idx] = activity;
      await saveActivities(list);
    }
  }

  Future<void> deleteActivity(String id) async {
    final list = getActivities();
    list.removeWhere((e) => e.id == id);
    await saveActivities(list);
  }

  // ─── GENERIC HELPERS ─────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _box.erase();
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _box.read<bool>(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    await _box.write(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return _box.read<String>(key) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    await _box.write(key, value);
  }
}