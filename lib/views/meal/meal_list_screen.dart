import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mediassist/views/meal/add_edit_meal_screen.dart';
import '../../controllers/meal_controller.dart';
import '../../models/meal_model.dart';
import '../../core/constants/app_colors.dart';


class MealListScreen extends StatelessWidget {
  const MealListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize or retrieve the existing MealController
    final MealController controller = Get.put(MealController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Reminder'),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.meals.isEmpty) {
          return _buildEmptyState(context);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.meals.length,
          itemBuilder: (context, index) {
            final meal = controller.meals[index];
            return _buildMealCard(meal, controller, context);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddEditMealScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Add Meal'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No meals added yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first meal reminder',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(Meal meal, MealController controller, BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editMeal(meal, controller),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deleteMeal(meal.id, controller, context),
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
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.restaurant, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
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
                              meal.time.format(context),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: meal.isActive,
                    onChanged: (value) async {
                      final updated = meal.copyWith(isActive: value);
                      await controller.updateMeal(updated);
                    },
                    activeColor: AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(meal.notificationType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getNotificationIcon(meal.notificationType), size: 16, color: _getNotificationColor(meal.notificationType)),
                        const SizedBox(width: 4),
                        Text(
                          meal.notificationType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getNotificationColor(meal.notificationType),
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

  void _editMeal(Meal meal, MealController controller) {
    Get.to(() => AddEditMealScreen(meal: meal));
  }

  Future<void> _deleteMeal(String id, MealController controller, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal reminder? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await controller.deleteMeal(id);
      Get.snackbar('Deleted', 'Meal reminder removed', snackPosition: SnackPosition.BOTTOM);
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