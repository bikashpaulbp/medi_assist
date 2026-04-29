// lib/views/medical_records/medical_records_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mediassist/views/medical_records/record_type_list_screen.dart';
import '../../core/constants/app_colors.dart';


class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  final List<RecordType> recordTypes = const [
    RecordType(
      id: 'blood_pressure',
      title: 'Blood Pressure',
      icon: Icons.favorite,
      color: Colors.red,
      unit: 'mmHg',
    ),
    RecordType(
      id: 'heart_rate',
      title: 'Heart Rate',
      icon: Icons.favorite_border,
      color: Colors.pink,
      unit: 'bpm',
    ),
    RecordType(
      id: 'oxygen_level',
      title: 'Oxygen Level',
      icon: Icons.air,
      color: Colors.blue,
      unit: '%',
    ),
    RecordType(
      id: 'diabetes_level',
      title: 'Diabetes Level',
      icon: Icons.bloodtype,
      color: Colors.orange,
      unit: 'mg/dL',
    ),
    RecordType(
      id: 'temperature',
      title: 'Temperature',
      icon: Icons.thermostat,
      color: Colors.deepOrange,
      unit: '°C',
    ),
    RecordType(
      id: 'weight',
      title: 'Weight',
      icon: Icons.monitor_weight,
      color: Colors.teal,
      unit: 'kg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        centerTitle: true,
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: recordTypes.length,
        itemBuilder: (context, index) {
          final type = recordTypes[index];
          return _buildRecordTypeCard(context, type);
        },
      ),
    );
  }

  Widget _buildRecordTypeCard(BuildContext context, RecordType type) {
    return InkWell(
      onTap: () => Get.to(() => RecordTypeListScreen(recordType: type)),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: type.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                type.icon,
                size: 48,
                color: type.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              type.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type.unit,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordType {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final String unit;

  const RecordType({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.unit,
  });
}