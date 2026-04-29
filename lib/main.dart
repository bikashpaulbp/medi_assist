import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:alarm/alarm.dart';
import 'package:mediassist/views/home_screen.dart';
import 'core/services/notification_service.dart';
import 'core/services/permission_service.dart';
import 'core/services/foreground_service.dart';
import 'core/constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Alarm.init();
  await NotificationService.initialize();
  await PermissionService.requestAllPermissions();
  ForegroundService.startService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MediAssist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      home: const HomeScreen(),
    );
  }
}
