// lib/models/medical_record_model.dart
import 'package:flutter/material.dart';

class MedicalRecord {
  final String id;
  final String type; // 'blood_pressure', 'heart_rate', 'oxygen_level', 'diabetes_level', 'temperature', 'weight'
  final String? dropdown; // e.g., for blood pressure: 'Systolic/Diastolic' structure
  final String result;
  final DateTime dateTime;
  final String notificationType; // 'notification', 'alarm', 'both', 'none' (for checkup reminders)
  final bool isActive;

  MedicalRecord({
    required this.id,
    required this.type,
    this.dropdown,
    required this.result,
    required this.dateTime,
    required this.notificationType,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'dropdown': dropdown,
      'result': result,
      'dateTime': dateTime.toIso8601String(),
      'notificationType': notificationType,
      'isActive': isActive,
    };
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      type: json['type'],
      dropdown: json['dropdown'],
      result: json['result'],
      dateTime: DateTime.parse(json['dateTime']),
      notificationType: json['notificationType'],
      isActive: json['isActive'] ?? true,
    );
  }

  MedicalRecord copyWith({
    String? id,
    String? type,
    String? dropdown,
    String? result,
    DateTime? dateTime,
    String? notificationType,
    bool? isActive,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      dropdown: dropdown ?? this.dropdown,
      result: result ?? this.result,
      dateTime: dateTime ?? this.dateTime,
      notificationType: notificationType ?? this.notificationType,
      isActive: isActive ?? this.isActive,
    );
  }
}