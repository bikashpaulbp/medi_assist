// lib/views/medicine/medicine_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mediassist/views/medicine/add_edit_medicine_screen.dart';
import 'package:mediassist/views/widgets/custom_snackbar.dart';
import 'package:mediassist/views/widgets/empty_state_widget.dart';
import '../../../controllers/medicine_controller.dart';
import '../../../models/medicine_model.dart';
import '../../../core/constants/app_colors.dart';


class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MedicineController controller = Get.put(MedicineController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminder'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.medicines.isEmpty) {
          return _buildEmptyState(context);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.medicines.length,
          itemBuilder: (context, index) {
            final medicine = controller.medicines[index];
            return _buildMedicineCard(medicine, controller, context);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => AddEditMedicineScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

 Widget _buildEmptyState(BuildContext context) {
  return EmptyStateWidget(
    title: 'No medicines added yet',
    message: 'Tap the + button to add your first medicine reminder',
    icon: Icons.medication_outlined,
    onAction: () => Get.to(() => AddEditMedicineScreen()),
    actionLabel: 'Add Medicine',
  );
}

  Widget _buildMedicineCard(Medicine medicine, MedicineController controller, BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editMedicine(medicine, controller),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deleteMedicine(medicine.id, controller, context),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.medication, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              medicine.times.map((t) => t.format(context)).join(', '),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: medicine.isActive,
                    onChanged: (value) async {
                      final updated = medicine.copyWith(isActive: value);
                      await controller.updateMedicine(updated);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(medicine.notificationType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getNotificationIcon(medicine.notificationType), size: 16, color: _getNotificationColor(medicine.notificationType)),
                        const SizedBox(width: 4),
                        Text(
                          medicine.notificationType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getNotificationColor(medicine.notificationType),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editMedicine(Medicine medicine, MedicineController controller) {
    Get.to(() => AddEditMedicineScreen(medicine: medicine));
  }

  Future<void> _deleteMedicine(String id, MedicineController controller, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: const Text('Are you sure you want to delete this medicine? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await controller.deleteMedicine(id);
      CustomSnackbar.showSuccess('Medicine reminder removed');
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'notification': return Colors.blue;
      case 'alarm': return Colors.orange;
      case 'both': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'notification': return Icons.notifications_active;
      case 'alarm': return Icons.alarm;
      case 'both': return Icons.notifications_active_outlined;
      default: return Icons.notifications_off;
    }
  }
}