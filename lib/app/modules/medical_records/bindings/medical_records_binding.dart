import 'package:get/get.dart';
import '../controllers/medical_records_controller.dart';

class MedicalRecordsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicalRecordsController>(() => MedicalRecordsController());
  }
}