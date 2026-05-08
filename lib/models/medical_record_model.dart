class MedicalRecord {
  final String id;
  final String type;       // 'blood_pressure', 'heart_rate', etc.
  final String? category;  // Dropdown value e.g. 'Normal', 'Fasting'
  final String result;     // Numeric or text result e.g. '120/80', '98.6'
  final DateTime dateTime;
  final String? notes;
  final DateTime createdAt;

  MedicalRecord({
    required this.id,
    required this.type,
    this.category,
    required this.result,
    required this.dateTime,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ─── Copy With ──────────────────────────────────────────────────────────────
  MedicalRecord copyWith({
    String? id,
    String? type,
    String? category,
    String? result,
    DateTime? dateTime,
    String? notes,
    DateTime? createdAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      result: result ?? this.result,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ─── JSON Serialization ─────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'result': result,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      type: json['type'] as String,
      category: json['category'] as String?,
      result: json['result'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Returns formatted date: "12 Jan 2025"
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  /// Returns formatted time: "02:30 PM"
  String get formattedTime {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = isPm ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  }

  /// Returns formatted date + time: "12 Jan 2025 • 02:30 PM"
  String get formattedDateTime => '$formattedDate • $formattedTime';

  @override
  String toString() =>
      'MedicalRecord(id: $id, type: $type, result: $result, dateTime: $dateTime)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}