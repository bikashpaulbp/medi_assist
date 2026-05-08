import 'package:flutter/material.dart';

class Medicine {
  final String id;
  final String name;
  final List<TimeOfDay> times;
  final String notificationType; // 'notification', 'alarm', 'both', 'none'
  final bool isActive;
  final DateTime createdAt;

  Medicine({
    required this.id,
    required this.name,
    required this.times,
    required this.notificationType,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ─── Copy With ──────────────────────────────────────────────────────────────
  Medicine copyWith({
    String? id,
    String? name,
    List<TimeOfDay>? times,
    String? notificationType,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      times: times ?? this.times,
      notificationType: notificationType ?? this.notificationType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ─── JSON Serialization ─────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'times': times
          .map((t) => {'hour': t.hour, 'minute': t.minute})
          .toList(),
      'notificationType': notificationType,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String,
      name: json['name'] as String,
      times: (json['times'] as List)
          .map((t) => TimeOfDay(
                hour: (t as Map)['hour'] as int,
                minute: t['minute'] as int,
              ))
          .toList(),
      notificationType: json['notificationType'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Returns formatted times as "08:00 AM, 02:00 PM"
  String get formattedTimes {
    return times.map((t) => _formatTime(t)).join(', ');
  }

  /// Returns first time for display
  String get firstTimeFormatted {
    if (times.isEmpty) return '--';
    return _formatTime(times.first);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Generates unique notification IDs for each time slot
  /// Base: medicineNotifBase (1000) + index
  List<int> getNotificationIds(int baseId) {
    return List.generate(times.length, (i) => baseId + i);
  }

  @override
  String toString() => 'Medicine(id: $id, name: $name, times: $formattedTimes)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Medicine && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}