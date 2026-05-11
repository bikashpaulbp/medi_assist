import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/medicine_model.dart';
import '../../models/meal_model.dart';
import '../../models/medical_record_model.dart';
import '../../models/activity_model.dart';
import '../constants/app_constants.dart';

/// StorageService uses TWO separate GetStorage boxes:
///
/// [_dataBox]     — stores user data (medicines, meals, records, activities)
///                  CLEARED when user taps "Clear All Data"
///
/// [_settingsBox] — stores app settings (first launch, service state, prefs)
///                  NEVER cleared — persists forever across data clears
class StorageService extends GetxService {
  static StorageService get to => Get.find();

  // ─── Two isolated storage boxes ──────────────────────────────────────────────
  late final GetStorage _dataBox;
  late final GetStorage _settingsBox;

  @override
  void onInit() {
    super.onInit();
    _dataBox     = GetStorage();                              // default box
    _settingsBox = GetStorage(AppConstants.settingsBoxName);  // settings box
  }

  // ════════════════════════════════════════════════════════════════
  // ─── MEDICINE ────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════

  List<Medicine> getMedicines() {
    try {
      final data = _dataBox.read<List>(AppConstants.medicinesKey);
      if (data == null) return [];
      return data
          .map((e) => Medicine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMedicines(List<Medicine> medicines) async {
    await _dataBox.write(
      AppConstants.medicinesKey,
      medicines.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> addMedicine(Medicine medicine) async {
    final list = getMedicines()..add(medicine);
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
    final list = getMedicines()..removeWhere((e) => e.id == id);
    await saveMedicines(list);
  }

  // ════════════════════════════════════════════════════════════════
  // ─── MEAL ────────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════

  List<Meal> getMeals() {
    try {
      final data = _dataBox.read<List>(AppConstants.mealsKey);
      if (data == null) return [];
      return data
          .map((e) => Meal.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMeals(List<Meal> meals) async {
    await _dataBox.write(
      AppConstants.mealsKey,
      meals.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> addMeal(Meal meal) async {
    final list = getMeals()..add(meal);
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
    final list = getMeals()..removeWhere((e) => e.id == id);
    await saveMeals(list);
  }

  // ════════════════════════════════════════════════════════════════
  // ─── MEDICAL RECORDS ─────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════

  List<MedicalRecord> getMedicalRecords() {
    try {
      final data = _dataBox.read<List>(AppConstants.medicalRecordsKey);
      if (data == null) return [];
      return data
          .map((e) => MedicalRecord.fromJson(Map<String, dynamic>.from(e as Map)))
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
    await _dataBox.write(
      AppConstants.medicalRecordsKey,
      records.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> addMedicalRecord(MedicalRecord record) async {
    final list = getMedicalRecords()..add(record);
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
    final list = getMedicalRecords()..removeWhere((e) => e.id == id);
    await saveMedicalRecords(list);
  }

  // ════════════════════════════════════════════════════════════════
  // ─── ACTIVITY ────────────────────────────────────────────────────
  // ════════════════════════════════════════════════════════════════

  List<Activity> getActivities() {
    try {
      final data = _dataBox.read<List>(AppConstants.activitiesKey);
      if (data == null) return [];
      return data
          .map((e) => Activity.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveActivities(List<Activity> activities) async {
    await _dataBox.write(
      AppConstants.activitiesKey,
      activities.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> addActivity(Activity activity) async {
    final list = getActivities()..add(activity);
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
    final list = getActivities()..removeWhere((e) => e.id == id);
    await saveActivities(list);
  }

  // ════════════════════════════════════════════════════════════════
  // ─── CLEAR USER DATA ONLY (settings are preserved) ────────────────
  // ════════════════════════════════════════════════════════════════

  /// Clears ONLY user data — medicines, meals, activities, medical records.
  /// Settings (service state, preferences, first-launch flag) are preserved.
  Future<void> clearAllData() async {
    await _dataBox.remove(AppConstants.medicinesKey);
    await _dataBox.remove(AppConstants.mealsKey);
    await _dataBox.remove(AppConstants.medicalRecordsKey);
    await _dataBox.remove(AppConstants.activitiesKey);
  }

  // ════════════════════════════════════════════════════════════════
  // ─── SETTINGS (use _settingsBox — never erased) ───────────────────
  // ════════════════════════════════════════════════════════════════

  // ── First launch ──────────────────────────────────────────────────────────
  bool get isFirstLaunch {
    return _settingsBox.read<bool>(AppConstants.firstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunchDone() async {
    await _settingsBox.write(AppConstants.firstLaunchKey, false);
  }

  // ── Service enabled state ─────────────────────────────────────────────────
  /// Whether the user has intentionally enabled the background service.
  /// Defaults to true — service runs by default on first install.
  bool get isServiceEnabled {
    return _settingsBox.read<bool>(AppConstants.serviceEnabledKey) ?? true;
  }

  Future<void> setServiceEnabled(bool value) async {
    await _settingsBox.write(AppConstants.serviceEnabledKey, value);
  }

  // ── Permission asked ──────────────────────────────────────────────────────
  /// Whether we've already asked for permissions in the splash screen.
  /// Prevents re-asking on every app open.
  bool get hasPermissionBeenAsked {
    return _settingsBox.read<bool>(AppConstants.permissionAskedKey) ?? false;
  }

  Future<void> setPermissionAsked() async {
    await _settingsBox.write(AppConstants.permissionAskedKey, true);
  }

  // ── Snooze minutes ────────────────────────────────────────────────────────
  int get snoozeMinutes {
    return _settingsBox.read<int>(AppConstants.snoozeMinutesKey) ??
        AppConstants.defaultSnoozeMinutes;
  }

  Future<void> setSnoozeMinutes(int minutes) async {
    await _settingsBox.write(AppConstants.snoozeMinutesKey, minutes);
  }

  // ── Theme ─────────────────────────────────────────────────────────────────
  String get themeMode {
    return _settingsBox.read<String>(AppConstants.themeKey) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await _settingsBox.write(AppConstants.themeKey, mode);
  }

  // ── Pending notification route ────────────────────────────────────────────
  String? get pendingRoute {
    return _settingsBox.read<String>(AppConstants.pendingRouteKey);
  }

  Future<void> setPendingRoute(String route) async {
    await _settingsBox.write(AppConstants.pendingRouteKey, route);
  }

  Future<void> clearPendingRoute() async {
    await _settingsBox.remove(AppConstants.pendingRouteKey);
  }

  // ── Last reschedule date ──────────────────────────────────────────────────
  /// Tracks last time we rescheduled all reminders.
  /// Used to avoid unnecessary reschedules on every app open.
  DateTime? get lastRescheduleDate {
    final s = _settingsBox.read<String>(AppConstants.lastRescheduleDateKey);
    if (s == null) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastRescheduleDate(DateTime date) async {
    await _settingsBox.write(
      AppConstants.lastRescheduleDateKey,
      date.toIso8601String(),
    );
  }

  // ─── Generic helpers ──────────────────────────────────────────────────────
  bool getBool(String key, {bool defaultValue = false}) =>
      _settingsBox.read<bool>(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) async =>
      await _settingsBox.write(key, value);

  String getString(String key, {String defaultValue = ''}) =>
      _settingsBox.read<String>(key) ?? defaultValue;

  Future<void> setString(String key, String value) async =>
      await _settingsBox.write(key, value);

  int getInt(String key, {int defaultValue = 0}) =>
      _settingsBox.read<int>(key) ?? defaultValue;

  Future<void> setInt(String key, int value) async =>
      await _settingsBox.write(key, value);
}