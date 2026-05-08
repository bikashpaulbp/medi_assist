import 'package:flutter/material.dart';

class TimeUtils {
  TimeUtils._();

  /// Format TimeOfDay to "08:00 AM"
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Format DateTime to "08:00 AM"
  static String formatDateTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Format DateTime to "12 Jan 2025"
  static String formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  /// Format DateTime to full: "12 Jan 2025 • 08:00 AM"
  static String formatFull(DateTime dt) {
    return '${formatDate(dt)} • ${formatDateTime(dt)}';
  }

  /// Get next occurrence of a TimeOfDay from now
  /// If the time has already passed today, returns tomorrow
  static DateTime nextOccurrence(TimeOfDay time) {
    final now = DateTime.now();
    DateTime scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now) ||
        scheduled.difference(now).inSeconds < 5) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Convert TimeOfDay to minutes since midnight for comparison
  static int toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  /// Check if current time matches a TimeOfDay (within same minute)
  static bool isNow(TimeOfDay time) {
    final now = TimeOfDay.now();
    return now.hour == time.hour && now.minute == time.minute;
  }

  /// Get greeting based on current time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  /// Format duration as "2h 30m"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}