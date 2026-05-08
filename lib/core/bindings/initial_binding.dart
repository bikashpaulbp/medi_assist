import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/alarm_service.dart';
import '../services/permission_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    Get.put<AlarmService>(AlarmService(), permanent: true);
    Get.put<PermissionService>(PermissionService(), permanent: true);
  }
}