import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'core/services/foreground_service.dart';
import 'core/services/notification_service.dart';

// ─── Top-level callback — defined ONLY here ───────────────────────────────────
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MediAssistTaskHandler());
}

// ─── Alarm stream subscription (top-level — survives navigation) ─────────────
StreamSubscription<AlarmSet>? _alarmRingingSubscription;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Init BOTH storage boxes (data + settings) ──────────────────────────────
  await GetStorage.init();
  await GetStorage.init(AppConstants.settingsBoxName); // ✅ NEW — settings box

  // ── Timezone ────────────────────────────────────────────────────────────────
  tzdata.initializeTimeZones();

  // ── Notifications ────────────────────────────────────────────────────────────
  await NotificationService.initialize();

  // ── Alarm package ────────────────────────────────────────────────────────────
  await Alarm.init();

  // ── Alarm ringing listener ───────────────────────────────────────────────────
  _setupAlarmRingingListener();

  // ── Foreground task communication port ────────────────────────────────────────
  FlutterForegroundTask.initCommunicationPort();

  runApp(const MediAssistApp());
}

// ─── Alarm ringing listener ───────────────────────────────────────────────────
void _setupAlarmRingingListener() {
  _alarmRingingSubscription?.cancel();
  _alarmRingingSubscription = Alarm.ringing.listen((AlarmSet alarmSet) {
    debugPrint(
        '🔔 Alarm(s) ringing: ${alarmSet.alarms.map((a) => a.id).toList()}');
    for (final alarmSettings in alarmSet.alarms) {
      // Reschedule for next day immediately when alarm fires
      _rescheduleAlarmForNextDay(alarmSettings);
      // Show in-app alarm screen if app is open
      _showAlarmRingingScreen(alarmSettings);
    }
  });
}

// ─── Reschedule for next day ──────────────────────────────────────────────────
Future<void> _rescheduleAlarmForNextDay(AlarmSettings fired) async {
  try {
    final nextTime = fired.dateTime.add(const Duration(days: 1));
    if (nextTime.isBefore(DateTime.now())) return;

    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: fired.id,
        dateTime: nextTime,
        assetAudioPath: fired.assetAudioPath,
        loopAudio: fired.loopAudio,
        vibrate: fired.vibrate,
        volumeSettings: VolumeSettings.fade(
          volume: 1.0,
          fadeDuration: const Duration(seconds: 3),
        ),
        warningNotificationOnKill: fired.warningNotificationOnKill,
        androidFullScreenIntent: fired.androidFullScreenIntent,
        notificationSettings: fired.notificationSettings,
      ),
    );
    debugPrint('✅ Alarm ${fired.id} rescheduled → $nextTime');
  } catch (e) {
    debugPrint('❌ Failed to reschedule alarm ${fired.id}: $e');
  }
}

// ─── In-app alarm screen ──────────────────────────────────────────────────────
void _showAlarmRingingScreen(AlarmSettings alarm) {
  if (Get.isDialogOpen == true) return;

  // Read persisted snooze setting
  final snoozeBox = GetStorage(AppConstants.settingsBoxName);
  final snoozeMinutes =
      snoozeBox.read<int>(AppConstants.snoozeMinutesKey) ??
          AppConstants.defaultSnoozeMinutes;

  Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E293B),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated alarm icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1.15),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alarm_rounded,
                  color: Color(0xFF6366F1),
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              alarm.notificationSettings.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              alarm.notificationSettings.body,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            // Stop button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Alarm.stop(alarm.id);
                  if (Get.isDialogOpen == true) Get.back();
                },
                icon: const Icon(Icons.alarm_off_rounded),
                label: const Text(
                  'Stop Alarm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Snooze button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Alarm.stop(alarm.id);
                  // Schedule snooze using user's saved preference
                  final snoozeTime = DateTime.now()
                      .add(Duration(minutes: snoozeMinutes));
                  await Alarm.set(
                    alarmSettings: AlarmSettings(
                      id: alarm.id,
                      dateTime: snoozeTime,
                      assetAudioPath: alarm.assetAudioPath,
                      loopAudio: false, // don't loop on snooze
                      vibrate: alarm.vibrate,
                      volumeSettings: VolumeSettings.fade(
                        volume: 0.7,
                        fadeDuration: const Duration(seconds: 2),
                      ),
                      warningNotificationOnKill:
                          alarm.warningNotificationOnKill,
                      androidFullScreenIntent: false,
                      notificationSettings: NotificationSettings(
                        title: '⏱️ Snoozed — ${alarm.notificationSettings.title}',
                        body: 'Reminder in $snoozeMinutes minutes',
                        stopButton: 'Cancel Snooze',
                        icon: 'notification_icon',
                      ),
                    ),
                  );
                  if (Get.isDialogOpen == true) Get.back();
                  debugPrint(
                      '⏱️ Alarm ${alarm.id} snoozed $snoozeMinutes minutes');
                },
                icon: const Icon(Icons.snooze_rounded),
                label: Text(
                  'Snooze $snoozeMinutes min',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white60,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
    barrierColor: Colors.black87,
  );
}