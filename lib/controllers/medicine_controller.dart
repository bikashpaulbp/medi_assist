// lib/controllers/medicine_controller.dart
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine_model.dart';
import '../core/services/storage_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/alarm_service.dart';

class MedicineController extends GetxController {
  final StorageService _storage = StorageService();
  final RxList<Medicine> medicines = <Medicine>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMedicines();
  }

  void loadMedicines() {
    medicines.value = _storage.getMedicines();
  }

  Future<void> addMedicine(Medicine medicine) async {
    final newMedicine = medicine.id.isEmpty
        ? medicine.copyWith(id: const Uuid().v4())
        : medicine;
    _storage.saveMedicine(newMedicine);
    loadMedicines();
    await scheduleRemindersForMedicine(newMedicine, isNew: true);
  }

  Future<void> updateMedicine(Medicine medicine) async {
    // Cancel old reminders before updating
    await cancelRemindersForMedicine(medicine);
    _storage.saveMedicine(medicine);
    loadMedicines();
    await scheduleRemindersForMedicine(medicine);
  }

  Future<void> deleteMedicine(String id) async {
    final medicine = medicines.firstWhere((m) => m.id == id);
    await cancelRemindersForMedicine(medicine);
    _storage.deleteMedicine(id);
    loadMedicines();
  }

  Future<void> scheduleRemindersForMedicine(Medicine medicine, {bool isNew = false}) async {
    if (!medicine.isActive) return;

    for (int i = 0; i < medicine.times.length; i++) {
      final time = medicine.times[i];
      final now = DateTime.now();
      DateTime scheduledTime = DateTime(
        now.year, now.month, now.day, time.hour, time.minute,
      );
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final uniqueId = int.parse('${medicine.id.hashCode}$i'.substring(0, 5)); // simple unique id

      switch (medicine.notificationType) {
        case 'notification':
          await NotificationService.showNotification(
            id: uniqueId,
            title: 'Medicine Reminder',
            body: 'Time to take ${medicine.name}',
          );
          break;
        case 'alarm':
          await AlarmService.scheduleAlarm(
            id: uniqueId,
            time: scheduledTime,
            title: 'Medicine Alarm',
            body: 'Take ${medicine.name} now',
          );
          break;
        case 'both':
          await NotificationService.showNotification(
            id: uniqueId,
            title: 'Medicine Reminder',
            body: 'Time to take ${medicine.name}',
          );
          await AlarmService.scheduleAlarm(
            id: uniqueId + 1000,
            time: scheduledTime,
            title: 'Medicine Alarm',
            body: 'Take ${medicine.name} now',
          );
          break;
        case 'none':
        default:
          break;
      }
    }
  }

  Future<void> cancelRemindersForMedicine(Medicine medicine) async {
    for (int i = 0; i < medicine.times.length; i++) {
      final uniqueId = int.parse('${medicine.id.hashCode}$i'.substring(0, 5));
      await AlarmService.cancelAlarm(uniqueId);
      // Notifications cannot be cancelled individually by ID with flutter_local_notifications easily,
      // but we can rely on the fact that they are one-time. For simplicity, we just reschedule.
    }
  }
}