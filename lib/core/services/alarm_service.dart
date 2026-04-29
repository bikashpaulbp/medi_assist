// lib/core/services/alarm_service.dart
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

class AlarmService {
  static Future<void> scheduleAlarm({
    required int id,
    required DateTime time,
    required String title,
    required String body,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: time,
      assetAudioPath: 'assets/audio/alarm_default.mp3', // Ensure asset exists
      loopAudio: true,
      vibrate: true, volumeSettings: VolumeSettings.fixed(),
      notificationSettings: NotificationSettings(title: title, body: body),

    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  static Future<void> cancelAlarm(int id) async {
    await Alarm.stop(id);
  }

  static Future<void> stopAllAlarms() async {
    await Alarm.stopAll();
  }
}