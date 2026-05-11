import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/core/services/storage_service.dart';

// ✅ FIXED: Use relative imports, NOT package:medi_assist/
import 'app/routes/app_pages.dart';
import 'core/bindings/initial_binding.dart';
import 'core/services/foreground_service.dart';
import 'core/services/notification_service.dart';
import 'core/themes/app_theme.dart';

class MediAssistApp extends StatefulWidget {
  const MediAssistApp({super.key});

  @override
  State<MediAssistApp> createState() => _MediAssistAppState();
}

class _MediAssistAppState extends State<MediAssistApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ── Start foreground service (safe — won't restart if already running) ──
     MediAssistForegroundService.initService();
final serviceEnabled = StorageService.to.isServiceEnabled;
if (serviceEnabled) {
  await MediAssistForegroundService.startService();
} else {
  debugPrint('ℹ️ Service disabled by user — not auto-starting');
}

      // ── Handle notification tap that launched the app from killed state ──
      NotificationService.consumePendingRoute();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground — check for pending notification routes
        // (handles case where user tapped notification while app was in background)
        NotificationService.consumePendingRoute();
        break;

      case AppLifecycleState.paused:
        // App went to background — update service notification text
       MediAssistForegroundService.updateNotificationText(
    'Running in background — reminders active',
  );
        break;

      case AppLifecycleState.detached:
        // App is being closed — service stays alive due to stopWithTask="false"
        break;

      default:
        break;
    }
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
      // ✅ Handle notification tap when app is launched from notification
      // (covers case where app was completely killed)
      builder: (context, child) {
        return child!;
      },
    );
  }
}