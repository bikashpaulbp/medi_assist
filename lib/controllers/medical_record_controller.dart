// lib/controllers/medical_record_controller.dart
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/medical_record_model.dart';
import '../core/services/storage_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/alarm_service.dart';

class MedicalRecordController extends GetxController {
  final StorageService _storage = StorageService();
  final RxList<MedicalRecord> records = <MedicalRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  void loadRecords() {
    records.value = _storage.getMedicalRecords();
  }

  Future<void> addRecord(MedicalRecord record) async {
    final newRecord = record.id.isEmpty ? record.copyWith(id: const Uuid().v4()) : record;
    _storage.saveMedicalRecord(newRecord);
    loadRecords();
    await scheduleReminderForRecord(newRecord);
  }

  Future<void> updateRecord(MedicalRecord record) async {
    await cancelReminderForRecord(record);
    _storage.saveMedicalRecord(record);
    loadRecords();
    await scheduleReminderForRecord(record);
  }

  Future<void> deleteRecord(String id) async {
    final record = records.firstWhere((r) => r.id == id);
    await cancelReminderForRecord(record);
    _storage.deleteMedicalRecord(id);
    loadRecords();
  }

  Future<void> scheduleReminderForRecord(MedicalRecord record) async {
    if (!record.isActive) return;

    final now = DateTime.now();
    // For medical checkup reminders, we assume a typical reminder time (e.g., 9:00 AM on the same day)
    // In a more advanced version, you would store the reminder time separately.
    final reminderTime = DateTime(now.year, now.month, now.day, 9, 0);
    if (reminderTime.isBefore(now)) {
      // Skip if already passed today
      return;
    }

    final uniqueId = record.id.hashCode.abs() % 100000;

    switch (record.notificationType) {
      case 'notification':
        await NotificationService.showNotification(
          id: uniqueId,
          title: 'Medical Checkup Reminder',
          body: 'Time to check your ${record.type}',
        );
        break;
      case 'alarm':
        await AlarmService.scheduleAlarm(
          id: uniqueId,
          time: reminderTime,
          title: 'Medical Alarm',
          body: 'Check your ${record.type} now',
        );
        break;
      case 'both':
        await NotificationService.showNotification(
          id: uniqueId,
          title: 'Medical Checkup Reminder',
          body: 'Time to check your ${record.type}',
        );
        await AlarmService.scheduleAlarm(
          id: uniqueId + 1000,
          time: reminderTime,
          title: 'Medical Alarm',
          body: 'Check your ${record.type} now',
        );
        break;
      case 'none':
      default:
        break;
    }
  }

  Future<void> cancelReminderForRecord(MedicalRecord record) async {
    final uniqueId = record.id.hashCode.abs() % 100000;
    await AlarmService.cancelAlarm(uniqueId);
  }
}