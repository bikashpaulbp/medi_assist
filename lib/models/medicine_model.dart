// lib/models/medicine_model.dart
import 'package:flutter/material.dart';

class Medicine {
  final String id;
  final String name;
  final List<TimeOfDay> times;
  final String notificationType; // 'notification', 'alarm', 'both', 'none'
  final bool isActive;

  Medicine({
    required this.id,
    required this.name,
    required this.times,
    required this.notificationType,
    this.isActive = true,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'times': times.map((time) => _timeOfDayToString(time)).toList(),
      'notificationType': notificationType,
      'isActive': isActive,
    };
  }

  // Create from JSON
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      times: (json['times'] as List)
          .map((timeStr) => _stringToTimeOfDay(timeStr))
          .toList(),
      notificationType: json['notificationType'],
      isActive: json['isActive'] ?? true,
    );
  }

  // Helper: TimeOfDay -> String (HH:mm)
  static String _timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Helper: String -> TimeOfDay
  static TimeOfDay _stringToTimeOfDay(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Create a copy with updated fields
  Medicine copyWith({
    String? id,
    String? name,
    List<TimeOfDay>? times,
    String? notificationType,
    bool? isActive,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      times: times ?? this.times,
      notificationType: notificationType ?? this.notificationType,
      isActive: isActive ?? this.isActive,
    );
  }
}