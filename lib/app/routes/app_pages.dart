import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/medicine/bindings/medicine_binding.dart';
import '../modules/medicine/views/medicine_list_view.dart';
import '../modules/medicine/views/add_edit_medicine_view.dart';
import '../modules/meal/bindings/meal_binding.dart';
import '../modules/meal/views/meal_list_view.dart';
import '../modules/meal/views/add_edit_meal_view.dart';
import '../modules/medical_records/bindings/medical_records_binding.dart';
import '../modules/medical_records/views/medical_records_view.dart';
import '../modules/medical_records/views/medical_record_detail_view.dart';
import '../modules/medical_records/views/add_edit_medical_record_view.dart';
import '../modules/activity/bindings/activity_binding.dart';
import '../modules/activity/views/activity_list_view.dart';
import '../modules/activity/views/add_edit_activity_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.medicine,
      page: () => const MedicineListView(),
      binding: MedicineBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.addEditMedicine,
      page: () => const AddEditMedicineView(),
      binding: MedicineBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.meal,
      page: () => const MealListView(),
      binding: MealBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.addEditMeal,
      page: () => const AddEditMealView(),
      binding: MealBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.medicalRecords,
      page: () => const MedicalRecordsView(),
      binding: MedicalRecordsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.medicalRecordDetail,
      page: () => const MedicalRecordDetailView(),
      binding: MedicalRecordsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.addEditMedicalRecord,
      page: () => const AddEditMedicalRecordView(),
      binding: MedicalRecordsBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.activity,
      page: () => const ActivityListView(),
      binding: ActivityBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.addEditActivity,
      page: () => const AddEditActivityView(),
      binding: ActivityBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
} 