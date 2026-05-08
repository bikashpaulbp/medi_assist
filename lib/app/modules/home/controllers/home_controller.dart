import 'package:get/get.dart';
import 'package:medi_assist/core/services/foreground_service.dart';
import 'package:medi_assist/core/services/permission_service.dart';
import 'package:medi_assist/core/services/storage_service.dart';
import 'package:medi_assist/core/utils/time_utils.dart';


class HomeController extends GetxController {
  static HomeController get to => Get.find();

  // ─── State ───────────────────────────────────────────────────────────────────
  final RxBool isServiceRunning = false.obs;
  final RxString greeting = ''.obs;
  final RxMap<String, bool> permissionStatus = <String, bool>{}.obs;
  final RxBool showPermissionBanner = false.obs;

  // ─── Summary counts ───────────────────────────────────────────────────────────
  RxInt get medicineCount =>
      StorageService.to.getMedicines().length.obs;

  int get activeMedicineCount =>
      StorageService.to.getMedicines().where((m) => m.isActive).length;

  int get activeMealCount =>
      StorageService.to.getMeals().where((m) => m.isActive).length;

  int get activeActivityCount =>
      StorageService.to.getActivities().where((a) => a.isActive).length;

  int get totalRecordsCount =>
      StorageService.to.getMedicalRecords().length;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    greeting.value = TimeUtils.getGreeting();
    await checkServiceStatus();
    await checkPermissions();
  }

  // ─── Service Status ──────────────────────────────────────────────────────────
  Future<void> checkServiceStatus() async {
    isServiceRunning.value = await MediAssistForegroundService.isRunning;
  }

  Future<void> toggleService() async {
    if (isServiceRunning.value) {
      await MediAssistForegroundService.stopService();
    } else {
      await MediAssistForegroundService.startService();
    }
    await checkServiceStatus();
  }

  // ─── Permissions ─────────────────────────────────────────────────────────────
  Future<void> checkPermissions() async {
    final status = await PermissionService.to.checkAllPermissions();
    permissionStatus.assignAll(status);

    // Show banner if critical permissions are missing
    final allGranted = status.values.every((v) => v);
    showPermissionBanner.value = !allGranted;
  }

  Future<void> requestPermissions() async {
    await PermissionService.to.requestAllPermissions();
    await checkPermissions();
  }

  // ─── Refresh greeting ────────────────────────────────────────────────────────
  void refreshGreeting() {
    greeting.value = TimeUtils.getGreeting();
  }
}