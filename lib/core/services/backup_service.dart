import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';
import '../../models/medicine_model.dart';
import '../../models/meal_model.dart';
import '../../models/activity_model.dart';
import '../../models/medical_record_model.dart';

/// BackupService handles export and import of all user data
/// 
/// Export: Creates a JSON file with all medicines, meals, activities, and medical records
/// Import: Reads a JSON file and restores all data
class BackupService extends GetxService {
  static BackupService get to => Get.find();

  // ─── Export Data to JSON File ────────────────────────────────────────────────
  Future<bool> exportData() async {
    try {
      // Gather all data
      final data = {
        'version': AppConstants.appVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'medicines': StorageService.to.getMedicines().map((m) => m.toJson()).toList(),
        'meals': StorageService.to.getMeals().map((m) => m.toJson()).toList(),
        'activities': StorageService.to.getActivities().map((a) => a.toJson()).toList(),
        'medicalRecords': StorageService.to.getMedicalRecords().map((r) => r.toJson()).toList(),
      };

      // Convert to pretty-printed JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      // Create filename with timestamp
      final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^\w]'), '_');
      final filename = 'mediassist_backup_$timestamp.json';

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Share the file using share_plus
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'MediAssist Backup',
        text: 'Your MediAssist health data backup',
      );

      // Clean up temp file after sharing
      await file.delete();

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('❌ Export failed: $e');
      return false;
    }
  }

  // ─── Import Data from JSON File ──────────────────────────────────────────────
  Future<bool> importData() async {
    try {
      // Pick JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return false; // User cancelled
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return false;
      }

      // Read file
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Validate backup file
      if (!_isValidBackupFile(jsonData)) {
        throw Exception('Invalid backup file format');
      }

      // Show confirmation dialog
      final confirmed = await _showImportConfirmation();
      if (!confirmed) {
        return false;
      }

      // Parse and restore data
      await _restoreData(jsonData);

      return true;
    } catch (e) {
      debugPrint('❌ Import failed: $e');
      return false;
    }
  }

  // ─── Validate Backup File Format ─────────────────────────────────────────────
  bool _isValidBackupFile(Map<String, dynamic> data) {
    return data.containsKey('medicines') &&
           data.containsKey('meals') &&
           data.containsKey('activities') &&
           data.containsKey('medicalRecords');
  }

  // ─── Restore Data from JSON ──────────────────────────────────────────────────
  Future<void> _restoreData(Map<String, dynamic> data) async {
    // Parse medicines
    final medicines = (data['medicines'] as List)
        .map((m) => Medicine.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    
    // Parse meals
    final meals = (data['meals'] as List)
        .map((m) => Meal.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    
    // Parse activities
    final activities = (data['activities'] as List)
        .map((a) => Activity.fromJson(Map<String, dynamic>.from(a)))
        .toList();
    
    // Parse medical records
    final medicalRecords = (data['medicalRecords'] as List)
        .map((r) => MedicalRecord.fromJson(Map<String, dynamic>.from(r)))
        .toList();

    // Save to storage
    await StorageService.to.saveMedicines(medicines);
    await StorageService.to.saveMeals(meals);
    await StorageService.to.saveActivities(activities);
    await StorageService.to.saveMedicalRecords(medicalRecords);

    debugPrint('✅ Data restored: ${medicines.length} medicines, ${meals.length} meals, ${activities.length} activities, ${medicalRecords.length} records');
  }

  // ─── Show Import Confirmation Dialog ─────────────────────────────────────────
  Future<bool> _showImportConfirmation() async {
    return await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.file_upload_rounded, color: Color(0xFF6366F1)),
            SizedBox(width: 12),
            Text('Import Backup'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will replace all your current data with the backup.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              'Make sure you trust this backup file. Your current data will be lost.',
              style: TextStyle(fontSize: 13, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Import'),
          ),
        ],
      ),
      barrierDismissible: false,
    ) ?? false;
  }

  // ─── Get Backup Count Summary ────────────────────────────────────────────────
  Map<String, int> getBackupSummary() {
    return {
      'medicines': StorageService.to.getMedicines().length,
      'meals': StorageService.to.getMeals().length,
      'activities': StorageService.to.getActivities().length,
      'medicalRecords': StorageService.to.getMedicalRecords().length,
    };
  }
}
