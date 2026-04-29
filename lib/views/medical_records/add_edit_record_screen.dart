// lib/views/medical_records/add_edit_record_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mediassist/views/medical_records/medical_records_screen.dart';
import '../../controllers/medical_record_controller.dart';
import '../../models/medical_record_model.dart';
import '../../core/constants/app_colors.dart';

class AddEditRecordScreen extends StatefulWidget {
  final RecordType recordType;
  final MedicalRecord? record;

  const AddEditRecordScreen({
    super.key,
    required this.recordType,
    this.record,
  });

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _valueController;
  late String _dropdownValue;
  late DateTime _selectedDateTime;
  late String _notificationType;
  late bool _isActive;

  final MedicalRecordController _controller = Get.find();

  // Diabetes timing options
  final List<String> _diabetesOptions = [
    'Fasting',
    'After Meal',
    'Random',
  ];

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _valueController = TextEditingController(text: record?.result ?? '');
    _dropdownValue = record?.dropdown ?? (_diabetesOptions.first);
    _selectedDateTime = record?.dateTime ?? DateTime.now();
    _notificationType = record?.notificationType ?? 'none';
    _isActive = record?.isActive ?? true;
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record == null ? 'Add ${widget.recordType.title}' : 'Edit ${widget.recordType.title}'),
        centerTitle: true,
        backgroundColor: widget.recordType.color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildValueField(),
            if (widget.recordType.id == 'diabetes_level') _buildDropdownField(),
            const SizedBox(height: 24),
            _buildDateTimePicker(),
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

  Widget _buildValueField() {
    String label;
    String hint;
    TextInputType keyboardType;

    switch (widget.recordType.id) {
      case 'blood_pressure':
        label = 'Blood Pressure (Systolic/Diastolic)';
        hint = 'e.g., 120/80';
        keyboardType = TextInputType.text;
        break;
      case 'heart_rate':
        label = 'Heart Rate';
        hint = 'e.g., 72';
        keyboardType = TextInputType.number;
        break;
      case 'oxygen_level':
        label = 'Oxygen Level';
        hint = 'e.g., 98';
        keyboardType = TextInputType.number;
        break;
      case 'diabetes_level':
        label = 'Blood Sugar Level';
        hint = 'e.g., 110';
        keyboardType = TextInputType.number;
        break;
      case 'temperature':
        label = 'Temperature';
        hint = 'e.g., 36.6';
        keyboardType = const TextInputType.numberWithOptions(decimal: true);
        break;
      case 'weight':
        label = 'Weight';
        hint = 'e.g., 70.5';
        keyboardType = const TextInputType.numberWithOptions(decimal: true);
        break;
      default:
        label = 'Value';
        hint = 'Enter value';
        keyboardType = TextInputType.text;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _valueController,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: widget.recordType.unit,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter a value';
            if (widget.recordType.id == 'blood_pressure') {
              final pattern = RegExp(r'^\d{2,3}/\d{2,3}$');
              if (!pattern.hasMatch(value)) return 'Enter as systolic/diastolic, e.g., 120/80';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Test Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _dropdownValue,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: _diabetesOptions.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: (value) => setState(() => _dropdownValue = value!),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date & Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.accent),
                const SizedBox(width: 12),
                Text(
                  _formatDateTime(_selectedDateTime),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} • ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildNotificationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Checkup Reminder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildChoiceChip('None', 'none'),
            _buildChoiceChip('Notification', 'notification'),
            _buildChoiceChip('Alarm', 'alarm'),
            _buildChoiceChip('Both', 'both'),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _notificationType == value,
      onSelected: (selected) {
        if (selected) setState(() => _notificationType = value);
      },
      selectedColor: widget.recordType.color,
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: const Text('Active'),
      subtitle: const Text('Enable/disable this reminder'),
      value: _isActive,
      onChanged: (val) => setState(() => _isActive = val),
      activeColor: widget.recordType.color,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveRecord,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.recordType.color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Save', style: TextStyle(fontSize: 16)),
    );
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    final record = MedicalRecord(
      id: widget.record?.id ?? '',
      type: widget.recordType.id,
      dropdown: widget.recordType.id == 'diabetes_level' ? _dropdownValue : null,
      result: _valueController.text.trim(),
      dateTime: _selectedDateTime,
      notificationType: _notificationType,
      isActive: _isActive,
    );

    if (widget.record == null) {
      await _controller.addRecord(record);
      Get.snackbar('Success', '${widget.recordType.title} record added', snackPosition: SnackPosition.BOTTOM);
    } else {
      await _controller.updateRecord(record);
      Get.snackbar('Success', '${widget.recordType.title} record updated', snackPosition: SnackPosition.BOTTOM);
    }
    Get.back();
  }
}