import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/meal_controller.dart';
import '../../models/meal_model.dart';
import '../../core/constants/app_colors.dart';

class AddEditMealScreen extends StatefulWidget {
  final Meal? meal;
  const AddEditMealScreen({super.key, this.meal});

  @override
  State<AddEditMealScreen> createState() => _AddEditMealScreenState();
}

class _AddEditMealScreenState extends State<AddEditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TimeOfDay _selectedTime;
  late String _notificationType;
  late bool _isActive;

  final MealController _controller = Get.find();

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;
    _nameController = TextEditingController(text: meal?.name ?? '');
    _selectedTime = meal?.time ?? TimeOfDay.now();
    _notificationType = meal?.notificationType ?? 'notification';
    _isActive = meal?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal == null ? 'Add Meal' : 'Edit Meal'),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildNameField(),
            const SizedBox(height: 24),
            _buildTimePicker(),
            const SizedBox(height: 24),
            _buildNotificationTypeSelector(),
            const SizedBox(height: 24),
            _buildActiveSwitch(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Meal Name',
        prefixIcon: Icon(Icons.restaurant),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter meal name' : null,
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reminder Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectTime,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.secondary),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildNotificationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notification Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRadio('Notification Only', 'notification', Icons.notifications_active),
            const SizedBox(width: 16),
            _buildRadio('Alarm Only', 'alarm', Icons.alarm),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRadio('Both', 'both', Icons.notifications_active_outlined),
            const SizedBox(width: 16),
            _buildRadio('None', 'none', Icons.notifications_off),
          ],
        ),
      ],
    );
  }

  Widget _buildRadio(String label, String value, IconData icon) {
    return Expanded(
      child: RadioListTile<String>(
        title: Row(
          children: [Icon(icon, size: 18), const SizedBox(width: 4), Text(label)],
        ),
        value: value,
        groupValue: _notificationType,
        onChanged: (val) => setState(() => _notificationType = val!),
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: const Text('Active'),
      subtitle: const Text('Enable/disable this reminder'),
      value: _isActive,
      onChanged: (val) => setState(() => _isActive = val),
      activeColor: AppColors.secondary,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveMeal,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Save', style: TextStyle(fontSize: 16)),
    );
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    final meal = Meal(
      id: widget.meal?.id ?? '',
      name: _nameController.text.trim(),
      time: _selectedTime,
      notificationType: _notificationType,
      isActive: _isActive,
    );

    if (widget.meal == null) {
      await _controller.addMeal(meal);
      Get.snackbar('Success', 'Meal reminder added', snackPosition: SnackPosition.BOTTOM);
    } else {
      await _controller.updateMeal(meal);
      Get.snackbar('Success', 'Meal reminder updated', snackPosition: SnackPosition.BOTTOM);
    }
    Get.back();
  }
}