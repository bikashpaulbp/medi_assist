import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // ─── App Info ───────────────────────────────────────────────────────────────
  static const String appName = 'MediAssist';
  static const String appVersion = '1.0.0';

  // ─── Storage Keys ───────────────────────────────────────────────────────────
  static const String medicinesKey = 'medicines';
  static const String mealsKey = 'meals';
  static const String medicalRecordsKey = 'medical_records';
  static const String activitiesKey = 'activities';
  static const String onboardingDoneKey = 'onboarding_done';
  static const String themeKey = 'theme_mode';

  // ─── Notification Channels ──────────────────────────────────────────────────
  static const String medicineChannelId = 'mediassist_medicine_channel';
  static const String medicineChannelName = 'Medicine Reminders';

  static const String mealChannelId = 'mediassist_meal_channel';
  static const String mealChannelName = 'Meal Reminders';

  static const String activityChannelId = 'mediassist_activity_channel';
  static const String activityChannelName = 'Activity Reminders';

  static const String medicalChannelId = 'mediassist_medical_channel';
  static const String medicalChannelName = 'Medical Record Reminders';

  static const String foregroundChannelId = 'mediassist_foreground_channel';
  static const String foregroundChannelName = 'MediAssist Service';

  // ─── Notification ID Ranges ─────────────────────────────────────────────────
  // Medicine: 1000–1999, Meal: 2000–2999, Activity: 3000–3999, Medical: 4000–4999
  static const int medicineNotifBase = 1000;
  static const int mealNotifBase = 2000;
  static const int activityNotifBase = 3000;
  static const int medicalNotifBase = 4000;

  // ─── Alarm ID Ranges ────────────────────────────────────────────────────────
  // Medicine: 5000–5999, Meal: 6000–6999, Activity: 7000–7999, Medical: 8000–8999
  static const int medicineAlarmBase = 5000;
  static const int mealAlarmBase = 6000;
  static const int activityAlarmBase = 7000;
  static const int medicalAlarmBase = 8000;

  // ─── Notification Types ─────────────────────────────────────────────────────
  static const String notifTypeNotification = 'notification';
  static const String notifTypeAlarm = 'alarm';
  static const String notifTypeBoth = 'both';
  static const String notifTypeNone = 'none';

  // ─── Medical Record Types ───────────────────────────────────────────────────
  static const String recordBloodPressure = 'blood_pressure';
  static const String recordHeartRate = 'heart_rate';
  static const String recordOxygenLevel = 'oxygen_level';
  static const String recordDiabetesLevel = 'diabetes_level';
  static const String recordTemperature = 'temperature';
  static const String recordWeight = 'weight';

  static const List<String> medicalRecordTypes = [
    recordBloodPressure,
    recordHeartRate,
    recordOxygenLevel,
    recordDiabetesLevel,
    recordTemperature,
    recordWeight,
  ];

  static const Map<String, String> medicalRecordLabels = {
    recordBloodPressure: 'Blood Pressure',
    recordHeartRate: 'Heart Rate',
    recordOxygenLevel: 'Oxygen Level',
    recordDiabetesLevel: 'Diabetes Level',
    recordTemperature: 'Temperature',
    recordWeight: 'Weight',
  };

  static const Map<String, String> medicalRecordUnits = {
    recordBloodPressure: 'mmHg',
    recordHeartRate: 'bpm',
    recordOxygenLevel: '%',
    recordDiabetesLevel: 'mg/dL',
    recordTemperature: '°C',
    recordWeight: 'kg',
  };

  static const Map<String, IconData> medicalRecordIcons = {
    recordBloodPressure: Icons.monitor_heart_outlined,
    recordHeartRate: Icons.favorite_outline,
    recordOxygenLevel: Icons.air_outlined,
    recordDiabetesLevel: Icons.water_drop_outlined,
    recordTemperature: Icons.thermostat_outlined,
    recordWeight: Icons.fitness_center_outlined,
  };

  // Blood pressure dropdowns
  static const List<String> bloodPressureCategories = [
    'Normal',
    'Elevated',
    'High Stage 1',
    'High Stage 2',
    'Hypertensive Crisis',
    'Low',
  ];

  static const List<String> heartRateCategories = [
    'Normal (60–100 bpm)',
    'Bradycardia (<60 bpm)',
    'Tachycardia (>100 bpm)',
  ];

  static const List<String> oxygenCategories = [
    'Normal (95–100%)',
    'Acceptable (90–94%)',
    'Low (<90%)',
  ];

  static const List<String> diabetesCategories = [
    'Fasting',
    'Post-meal (2hr)',
    'Random',
    'HbA1c',
  ];

  static const List<String> temperatureCategories = [
    'Normal',
    'Low-grade Fever',
    'Moderate Fever',
    'High Fever',
    'Hypothermia',
  ];

  static const List<String> weightCategories = [
    'Morning Weight',
    'Evening Weight',
    'After Workout',
    'After Meal',
  ];

  // ─── Asset Paths ────────────────────────────────────────────────────────────
  static const String alarmAudioPath = 'assets/audio/alarm.mp3';
  static const String emptyMedicineAnim = 'assets/animations/empty_medicine.json';
  static const String emptyMealAnim = 'assets/animations/empty_meal.json';
  static const String emptyActivityAnim = 'assets/animations/empty_activity.json';
  static const String emptyRecordAnim = 'assets/animations/empty_record.json';
  static const String successAnim = 'assets/animations/success.json';
}