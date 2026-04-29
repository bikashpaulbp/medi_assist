// lib/views/medicine/add_edit_medicine_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mediassist/views/widgets/custom_snackbar.dart';
import '../../controllers/medicine_controller.dart';
import '../../models/medicine_model.dart';
import '../../core/constants/app_colors.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  const AddEditMedicineScreen({super.key, this.medicine});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late List<TimeOfDay> _times;
  late String _notificationType;
  late bool _isActive;

  final MedicineController _controller = Get.find();

  @override
  void initState() {
    super.initState();
    final medicine = widget.medicine;
    _nameController = TextEditingController(text: medicine?.name ?? '');
    _times = medicine?.times ?? [];
    _notificationType = medicine?.notificationType ?? 'notification';
    _isActive = medicine?.isActive ?? true;
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
        title: Text(widget.medicine == null ? 'Add Medicine' : 'Edit Medicine'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildNameField(),
            const SizedBox(height: 24),
            _buildTimesSection(),
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
        labelText: 'Medicine Name',
        prefixIcon: Icon(Icons.medication),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter medicine name' : null,
    );
  }

  Widget _buildTimesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reminder Times', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _times.length,
          itemBuilder: (context, index) {
            final time = _times[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(time.format(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _times.removeAt(index)),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickTime,
          icon: const Icon(Icons.add),
          label: const Text('Add Time'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
        ),
      ],
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _times.add(picked));
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
      activeColor: AppColors.primary,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveMedicine,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Save', style: TextStyle(fontSize: 16)),
    );
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;
    if (_times.isEmpty) {
     CustomSnackbar.showError('Please add at least one reminder time');
      return;
    }

    final medicine = Medicine(
      id: widget.medicine?.id ?? '',
      name: _nameController.text.trim(),
      times: _times,
      notificationType: _notificationType,
      isActive: _isActive,
    );

    if (widget.medicine == null) {
      await _controller.addMedicine(medicine);
    CustomSnackbar.showSuccess('Medicine reminder added');
    } else {
      await _controller.updateMedicine(medicine);
     CustomSnackbar.showSuccess('Medicine reminder updated');
    }
    Get.back();
  }
}