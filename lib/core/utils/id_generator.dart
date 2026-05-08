class IdGenerator {
  IdGenerator._();

  /// Generates a unique ID based on timestamp + random suffix
  static String generate() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 99999).toString().padLeft(5, '0');
    return '${timestamp}_$random';
  }

  /// Generates a stable integer ID for notifications/alarms from string ID
  /// Maps string ID to an int within a range [base, base + 999]
  static int toIntId(String id, int base) {
    final hash = id.hashCode.abs() % 1000;
    return base + hash;
  }

  /// Generates a stable alarm int ID for medicine time slots
  /// Uses base + timeIndex to keep each time slot unique
  static int toAlarmId(String id, int base, int timeIndex) {
    final hash = id.hashCode.abs() % 100;
    return base + (hash * 10) + timeIndex;
  }
}