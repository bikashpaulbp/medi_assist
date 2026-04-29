// lib/models/activity_model.dart
import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String name;
  final TimeOfDay time;
  final String notificationType; // 'notification', 'alarm', 'both', 'none'
  final bool isActive;

  Activity({
    required this.id,
    required this.name,
    required this.time,
    required this.notificationType,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'notificationType': notificationType,
      'isActive': isActive,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    final timeStr = json['time'];
    final parts = timeStr.split(':');
    final time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    return Activity(
      id: json['id'],
      name: json['name'],
      time: time,
      notificationType: json['notificationType'],
      isActive: json['isActive'] ?? true,
    );
  }

  Activity copyWith({
    String? id,
    String? name,
    TimeOfDay? time,
    String? notificationType,
    bool? isActive,
  }) {
    return Activity(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      notificationType: notificationType ?? this.notificationType,
      isActive: isActive ?? this.isActive,
    );
  }
}