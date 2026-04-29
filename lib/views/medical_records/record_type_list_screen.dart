// lib/views/medical_records/record_type_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mediassist/views/medical_records/add_edit_record_screen.dart';
import 'package:mediassist/views/medical_records/medical_records_screen.dart';
import '../../controllers/medical_record_controller.dart';
import '../../models/medical_record_model.dart';



class RecordTypeListScreen extends StatelessWidget {
  final RecordType recordType;

  const RecordTypeListScreen({
    super.key,
    required this.recordType,
  });

  @override
  Widget build(BuildContext context) {
    final MedicalRecordController controller = Get.put(MedicalRecordController());
    final filteredRecords = controller.records.where(
      (record) => record.type == recordType.id,
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(recordType.title),
        centerTitle: true,
        backgroundColor: recordType.color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: filteredRecords.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredRecords.length,
              itemBuilder: (context, index) {
                final record = filteredRecords[index];
                return _buildRecordCard(record, controller, context);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(
          () => AddEditRecordScreen(
            recordType: recordType,
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
        backgroundColor: recordType.color,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            recordType.icon,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${recordType.title.toLowerCase()} records yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first record',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecord record, MedicalRecordController controller, BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editRecord(record, controller),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deleteRecord(record.id, controller, context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: recordType.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(recordType.icon, color: recordType.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatResult(record),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(record.dateTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (record.notificationType != 'none')
                Icon(
                  _getNotificationIcon(record.notificationType),
                  size: 20,
                  color: _getNotificationColor(record.notificationType),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatResult(MedicalRecord record) {
    if (record.type == 'blood_pressure') {
      return record.result; // Already in "120/80" format
    }
    return '${record.result} ${recordType.unit}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} • ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _editRecord(MedicalRecord record, MedicalRecordController controller) {
    Get.to(() => AddEditRecordScreen(
          recordType: recordType,
          record: record,
        ));
  }

  Future<void> _deleteRecord(String id, MedicalRecordController controller, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await controller.deleteRecord(id);
      Get.snackbar('Deleted', 'Record removed', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'notification':
        return Colors.blue;
      case 'alarm':
        return Colors.orange;
      case 'both':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'notification':
        return Icons.notifications_active;
      case 'alarm':
        return Icons.alarm;
      case 'both':
        return Icons.notifications_active_outlined;
      default:
        return Icons.notifications_off;
    }
  }
}