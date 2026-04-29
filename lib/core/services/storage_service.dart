// lib/core/services/storage_service.dart
import 'package:get_storage/get_storage.dart';
import '../../models/medicine_model.dart';
import '../../models/meal_model.dart';
import '../../models/medical_record_model.dart';
import '../../models/activity_model.dart';

class StorageService {
  static const String medicinesKey = 'medicines';
  static const String mealsKey = 'meals';
  static const String medicalRecordsKey = 'medical_records';
  static const String activitiesKey = 'activities';

  final GetStorage _storage = GetStorage();

  // ========== Generic helpers ==========
  List<dynamic> _readList(String key) {
    return _storage.read<List<dynamic>>(key) ?? [];
  }

  void _writeList(String key, List<dynamic> list) {
    _storage.write(key, list);
  }

  // ========== Medicine CRUD ==========
  List<Medicine> getMedicines() {
    final List<dynamic> data = _readList(medicinesKey);
    return data.map((item) => Medicine.fromJson(item)).toList();
  }

  void saveMedicine(Medicine medicine) {
    final List<Medicine> medicines = getMedicines();
    final int index = medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      medicines[index] = medicine;
    } else {
      medicines.add(medicine);
    }
    _writeList(medicinesKey, medicines.map((m) => m.toJson()).toList());
  }

  void deleteMedicine(String id) {
    final List<Medicine> medicines = getMedicines();
    medicines.removeWhere((m) => m.id == id);
    _writeList(medicinesKey, medicines.map((m) => m.toJson()).toList());
  }

  // ========== Meal CRUD ==========
  List<Meal> getMeals() {
    final List<dynamic> data = _readList(mealsKey);
    return data.map((item) => Meal.fromJson(item)).toList();
  }

  void saveMeal(Meal meal) {
    final List<Meal> meals = getMeals();
    final int index = meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      meals[index] = meal;
    } else {
      meals.add(meal);
    }
    _writeList(mealsKey, meals.map((m) => m.toJson()).toList());
  }

  void deleteMeal(String id) {
    final List<Meal> meals = getMeals();
    meals.removeWhere((m) => m.id == id);
    _writeList(mealsKey, meals.map((m) => m.toJson()).toList());
  }

  // ========== Medical Record CRUD ==========
  List<MedicalRecord> getMedicalRecords() {
    final List<dynamic> data = _readList(medicalRecordsKey);
    return data.map((item) => MedicalRecord.fromJson(item)).toList();
  }

  void saveMedicalRecord(MedicalRecord record) {
    final List<MedicalRecord> records = getMedicalRecords();
    final int index = records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      records[index] = record;
    } else {
      records.add(record);
    }
    _writeList(medicalRecordsKey, records.map((r) => r.toJson()).toList());
  }

  void deleteMedicalRecord(String id) {
    final List<MedicalRecord> records = getMedicalRecords();
    records.removeWhere((r) => r.id == id);
    _writeList(medicalRecordsKey, records.map((r) => r.toJson()).toList());
  }

  // ========== Activity CRUD ==========
  List<Activity> getActivities() {
    final List<dynamic> data = _readList(activitiesKey);
    return data.map((item) => Activity.fromJson(item)).toList();
  }

  void saveActivity(Activity activity) {
    final List<Activity> activities = getActivities();
    final int index = activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      activities[index] = activity;
    } else {
      activities.add(activity);
    }
    _writeList(activitiesKey, activities.map((a) => a.toJson()).toList());
  }

  void deleteActivity(String id) {
    final List<Activity> activities = getActivities();
    activities.removeWhere((a) => a.id == id);
    _writeList(activitiesKey, activities.map((a) => a.toJson()).toList());
  }

  // ========== Utility ==========
  void clearAllData() {
    _storage.erase();
  }
}