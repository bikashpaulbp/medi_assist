import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/app/routes/app_pages.dart';
import 'core/themes/app_theme.dart';
import 'core/services/foreground_service.dart';
import 'core/bindings/initial_binding.dart';

class MediAssistApp extends StatefulWidget {
  const MediAssistApp({super.key});

  @override
  State<MediAssistApp> createState() => _MediAssistAppState();
}

class _MediAssistAppState extends State<MediAssistApp> {
  @override
  void initState() {
    super.initState();
    // Start foreground service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MediAssistForegroundService.initService();
      MediAssistForegroundService.startService();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MediAssist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}