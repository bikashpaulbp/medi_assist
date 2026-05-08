import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../constants/app_constants.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ─── Initialize ─────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
    );

    // Create all notification channels (Android)
    if (Platform.isAndroid) {
      await _createChannels();
    }
  }

  // ─── Create Channels ────────────────────────────────────────────────────────
  static Future<void> _createChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Medicine channel
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

    // Meal channel
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

    // Activity channel
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

    // Medical channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.medicalChannelId,
        AppConstants.medicalChannelName,
        description: 'Reminders for medical record checkups.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Foreground service channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.foregroundChannelId,
        AppConstants.foregroundChannelName,
        description: 'MediAssist is running in the background.',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );
  }

  // ─── Notification Tap Handler ────────────────────────────────────────────────
  @pragma('vm:entry-point')
  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap — navigate if needed
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ─── Schedule Daily Notification ─────────────────────────────────────────────
  /// Schedules a daily repeating notification at [hour]:[minute]
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
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If time already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        fullScreenIntent: false,
        styleInformation: BigTextStyleInformation(body),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        autoCancel: true,
        ongoing: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      debugPrint(
          '✅ Notification scheduled: id=$id, title=$title, at $hour:$minute');
    } catch (e) {
      debugPrint('❌ Failed to schedule notification: $e');
    }
  }

  // ─── Show Immediate Notification ─────────────────────────────────────────────
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
        autoCancel: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      );

      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload,
      );
    } catch (e) {
      debugPrint('❌ Failed to show notification: $e');
    }
  }

  // ─── Cancel ──────────────────────────────────────────────────────────────────
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    debugPrint('🗑️ Notification cancelled: id=$id');
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('🗑️ All notifications cancelled');
  }

  // ─── Medicine Notifications ──────────────────────────────────────────────────
  Future<void> scheduleMedicineNotifications({
    required String medicineId,
    required String medicineName,
    required List<TimeOfDay> times,
    required int baseId,
  }) async {
    // Cancel existing first
    await cancelMedicineNotifications(medicineId: medicineId, times: times, baseId: baseId);

    for (int i = 0; i < times.length; i++) {
      final notifId = baseId + i;
      await scheduleDailyNotification(
        id: notifId,
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

  // ─── Meal Notifications ──────────────────────────────────────────────────────
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

  // ─── Activity Notifications ──────────────────────────────────────────────────
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

  // ─── Request Permission ──────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidPlugin?.requestNotificationsPermission() ?? false;
      return granted;
    } else if (Platform.isIOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return granted;
    }
    return true;
  }

  // ─── Get Pending Notifications ───────────────────────────────────────────────
  Future<List<PendingNotificationRequest>> getPending() async {
    return await _plugin.pendingNotificationRequests();
  }
}