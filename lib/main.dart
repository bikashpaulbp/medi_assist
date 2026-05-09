import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/foreground_service.dart';

// ─── Top-level callback required by flutter_foreground_task ───────────────────
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MediAssistTaskHandler());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize local notifications
  await NotificationService.initialize();

  // Initialize alarm package
  await Alarm.init();

  // Initialize foreground task communication port
  FlutterForegroundTask.initCommunicationPort();

  runApp(const MediAssistApp());
}