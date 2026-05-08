import 'package:flutter/material.dart';

class Meal {
  final String id;
  final String name;
  final TimeOfDay time;
  final String notificationType; // 'notification', 'alarm', 'both', 'none'
  final bool isActive;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.name,
    required this.time,
    required this.notificationType,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ─── Copy With ──────────────────────────────────────────────────────────────
  Meal copyWith({
    String? id,
    String? name,
    TimeOfDay? time,
    String? notificationType,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
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
      'time': {'hour': time.hour, 'minute': time.minute},
      'notificationType': notificationType,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    final timeMap = json['time'] as Map;
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      time: TimeOfDay(
        hour: timeMap['hour'] as int,
        minute: timeMap['minute'] as int,
      ),
      notificationType: json['notificationType'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  String get formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  String toString() => 'Meal(id: $id, name: $name, time: $formattedTime)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}