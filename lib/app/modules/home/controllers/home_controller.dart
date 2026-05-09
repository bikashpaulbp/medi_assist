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

  // ─── Reactive summary counts ──────────────────────────────────────────────────
  final RxInt activeMedicineCount = 0.obs;
  final RxInt activeMealCount = 0.obs;
  final RxInt activeActivityCount = 0.obs;
  final RxInt totalRecordsCount = 0.obs;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    greeting.value = TimeUtils.getGreeting();
    refreshCounts();
    await checkServiceStatus();
    await checkPermissions();
  }

  // ─── Refresh counts from storage ─────────────────────────────────────────────
  void refreshCounts() {
    activeMedicineCount.value =
        StorageService.to.getMedicines().where((m) => m.isActive).length;
    activeMealCount.value =
        StorageService.to.getMeals().where((m) => m.isActive).length;
    activeActivityCount.value =
        StorageService.to.getActivities().where((a) => a.isActive).length;
    totalRecordsCount.value =
        StorageService.to.getMedicalRecords().length;
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
    showPermissionBanner.value = !status.values.every((v) => v);
  }

  Future<void> requestPermissions() async {
    await PermissionService.to.requestAllPermissions();
    await checkPermissions();
  }

  // ─── Refresh greeting ────────────────────────────────────────────────────────
  void refreshGreeting() {
    greeting.value = TimeUtils.getGreeting();
    refreshCounts();
  }
}