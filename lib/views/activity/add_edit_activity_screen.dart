// lib/views/activity/add_edit_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/activity_controller.dart';
import '../../models/activity_model.dart';
import '../../core/constants/app_colors.dart';

class AddEditActivityScreen extends StatefulWidget {
  final Activity? activity;
  const AddEditActivityScreen({super.key, this.activity});

  @override
  State<AddEditActivityScreen> createState() => _AddEditActivityScreenState();
}

class _AddEditActivityScreenState extends State<AddEditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TimeOfDay _selectedTime;
  late String _notificationType;
  late bool _isActive;

  final ActivityController _controller = Get.find();

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;
    _nameController = TextEditingController(text: activity?.name ?? '');
    _selectedTime = activity?.time ?? TimeOfDay.now();
    _notificationType = activity?.notificationType ?? 'notification';
    _isActive = activity?.isActive ?? true;
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
        title: Text(widget.activity == null ? 'Add Activity' : 'Edit Activity'),
        centerTitle: true,
        backgroundColor: AppColors.accent,
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
        labelText: 'Activity Name',
        prefixIcon: Icon(Icons.fitness_center),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter activity name' : null,
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
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.accent),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
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
        activeColor: AppColors.accent,
      ),
    );
  }

  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: const Text('Active'),
      subtitle: const Text('Enable/disable this reminder'),
      value: _isActive,
      onChanged: (val) => setState(() => _isActive = val),
      activeColor: AppColors.accent,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveActivity,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Save', style: TextStyle(fontSize: 16)),
    );
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    final activity = Activity(
      id: widget.activity?.id ?? '',
      name: _nameController.text.trim(),
      time: _selectedTime,
      notificationType: _notificationType,
      isActive: _isActive,
    );

    if (widget.activity == null) {
      await _controller.addActivity(activity);
      Get.snackbar('Success', 'Activity reminder added', snackPosition: SnackPosition.BOTTOM);
    } else {
      await _controller.updateActivity(activity);
      Get.snackbar('Success', 'Activity reminder updated', snackPosition: SnackPosition.BOTTOM);
    }
    Get.back();
  }
}