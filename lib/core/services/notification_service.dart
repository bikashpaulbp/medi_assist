import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../constants/app_constants.dart';

// ─── Pending notification route key (for background taps) ────────────────────
const String _kPendingRouteKey = 'pending_notification_route';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ─── Initialize ──────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    tzdata.initializeTimeZones();

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      // ✅ Foreground tap — app is open
      onDidReceiveNotificationResponse: _onNotificationTap,
      // ✅ Background tap — app was killed, runs in separate isolate
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    if (Platform.isAndroid) {
      await _createChannels();
    }
  }

  // ─── Notification tap handler (foreground — app is open) ──────────────────
  @pragma('vm:entry-point')
  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    _handleNotificationNavigation(response.payload);
  }

  // ─── Background notification tap (app was killed) ─────────────────────────
  // Runs in a background isolate — cannot use GetX here
  // Save the route to storage, pick it up when app opens
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    debugPrint(
        '🔔 Background notification tapped: ${response.payload}');
    try {
      // Save pending route to storage — will be consumed on next app open
      final box = GetStorage();
      final route = _payloadToRoute(response.payload);
      if (route != null) {
        box.write(_kPendingRouteKey, route);
        debugPrint('📌 Pending route saved: $route');
      }
    } catch (e) {
      debugPrint('❌ Error saving pending route: $e');
    }
  }

  // ─── Navigate based on payload ────────────────────────────────────────────
  static void _handleNotificationNavigation(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final route = _payloadToRoute(payload);
    if (route != null) {
      // Small delay to ensure GetMaterialApp is ready
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.toNamed(route);
      });
    }
  }

  // ─── Convert payload to route string ─────────────────────────────────────
  static String? _payloadToRoute(String? payload) {
    if (payload == null) return null;
    if (payload.startsWith('medicine_')) return '/medicine';
    if (payload.startsWith('meal_')) return '/meal';
    if (payload.startsWith('activity_')) return '/activity';
    if (payload.startsWith('medical_')) return '/medical-records';
    return null;
  }

  // ─── Check & consume pending route (call this on app start) ──────────────
  static void consumePendingRoute() {
    try {
      final box = GetStorage();
      final route = box.read<String>(_kPendingRouteKey);
      if (route != null && route.isNotEmpty) {
        box.remove(_kPendingRouteKey);
        debugPrint('📌 Consuming pending route: $route');
        Future.delayed(const Duration(milliseconds: 800), () {
          Get.toNamed(route);
        });
      }
    } catch (e) {
      debugPrint('❌ Error consuming pending route: $e');
    }
  }

  // ─── Create notification channels (Android) ───────────────────────────────
  static Future<void> _createChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.medicineChannelId,
        AppConstants.medicineChannelName,
        description: 'Reminds you to take your medicines on time.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFF6366F1),
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.mealChannelId,
        AppConstants.mealChannelName,
        description: 'Reminds you about your meal times.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFFEC4899),
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.activityChannelId,
        AppConstants.activityChannelName,
        description: 'Reminds you about your scheduled activities.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFFF59E0B),
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.medicalChannelId,
        AppConstants.medicalChannelName,
        description: 'Medical record reminders.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Low importance — foreground service persistent notification
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.foregroundChannelId,
        AppConstants.foregroundChannelName,
        description: 'MediAssist is monitoring your reminders.',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );
  }

  // ─── Schedule daily repeating notification ────────────────────────────────
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelId,
    required String channelName,
    String? payload,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        // ✅ Shows full content in notification shade
        styleInformation: BigTextStyleInformation(body),
        category: AndroidNotificationCategory.reminder,
        // ✅ Shows on lock screen
        visibility: NotificationVisibility.public,
        autoCancel: true,
        ongoing: false,
        // ✅ Shows notification even when DND is active
        fullScreenIntent: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        // ✅ exactAllowWhileIdle — fires even when device is in Doze mode
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // ✅ Repeats daily at same time
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint(
          '✅ Notification scheduled: id=$id at $hour:$minute (payload: $payload)');
    } catch (e) {
      debugPrint('❌ Failed to schedule notification id=$id: $e');
    }
  }

  // ─── Show immediate notification ─────────────────────────────────────────
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    String? payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body),
        visibility: NotificationVisibility.public,
        autoCancel: true,
      );

      const iosDetails =
          DarwinNotificationDetails(presentAlert: true, presentSound: true);

      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload,
      );
    } catch (e) {
      debugPrint('❌ Failed to show immediate notification id=$id: $e');
    }
  }

  // ─── Cancel ───────────────────────────────────────────────────────────────
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Medicine notifications ───────────────────────────────────────────────
  Future<void> scheduleMedicineNotifications({
    required String medicineId,
    required String medicineName,
    required List<TimeOfDay> times,
    required int baseId,
  }) async {
    await cancelMedicineNotifications(
        medicineId: medicineId, times: times, baseId: baseId);

    for (int i = 0; i < times.length; i++) {
      await scheduleDailyNotification(
        id: baseId + i,
        title: '💊 Medicine Reminder',
        body: 'Time to take $medicineName',
        hour: times[i].hour,
        minute: times[i].minute,
        channelId: AppConstants.medicineChannelId,
        channelName: AppConstants.medicineChannelName,
        payload: 'medicine_$medicineId',
      );
    }
  }

  Future<void> cancelMedicineNotifications({
    required String medicineId,
    required List<TimeOfDay> times,
    required int baseId,
  }) async {
    for (int i = 0; i < times.length; i++) {
      await cancelNotification(baseId + i);
    }
  }

  // ─── Meal notifications ───────────────────────────────────────────────────
  Future<void> scheduleMealNotification({
    required String mealId,
    required String mealName,
    required TimeOfDay time,
    required int notifId,
  }) async {
    await cancelNotification(notifId);
    await scheduleDailyNotification(
      id: notifId,
      title: '🍽️ Meal Reminder',
      body: 'Time for $mealName',
      hour: time.hour,
      minute: time.minute,
      channelId: AppConstants.mealChannelId,
      channelName: AppConstants.mealChannelName,
      payload: 'meal_$mealId',
    );
  }

  // ─── Activity notifications ───────────────────────────────────────────────
  Future<void> scheduleActivityNotification({
    required String activityId,
    required String activityName,
    required TimeOfDay time,
    required int notifId,
  }) async {
    await cancelNotification(notifId);
    await scheduleDailyNotification(
      id: notifId,
      title: '🏃 Activity Reminder',
      body: 'Time for $activityName',
      hour: time.hour,
      minute: time.minute,
      channelId: AppConstants.activityChannelId,
      channelName: AppConstants.activityChannelName,
      payload: 'activity_$activityId',
    );
  }

  // ─── Request permission ───────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.requestNotificationsPermission() ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  // ─── Get pending notifications ────────────────────────────────────────────
  Future<List<PendingNotificationRequest>> getPending() async {
    return await _plugin.pendingNotificationRequests();
  }
}