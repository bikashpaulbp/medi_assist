import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/core/constants/app_colors.dart';
import 'package:medi_assist/core/constants/app_constants.dart';
import 'package:medi_assist/core/utils/time_utils.dart';
import '../controllers/medicine_controller.dart';

class AddEditMedicineView extends StatelessWidget {
  const AddEditMedicineView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicineController>();
    final isEditing = controller.editingMedicine != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isEditing, isDark),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Card ──
              _buildHeaderCard(isEditing, isDark),
              const SizedBox(height: 24),

              // ── Medicine Name ──
              _buildSectionLabel('Medicine Name', Icons.medication_rounded),
              const SizedBox(height: 10),
              _buildNameField(controller, isDark),
              const SizedBox(height: 24),

              // ── Reminder Times ──
              _buildSectionLabel(
                  'Reminder Times', Icons.access_time_rounded),
              const SizedBox(height: 4),
              Text(
                'Add one or more daily reminder times',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 12),
              _buildTimesSection(controller, context, isDark),
              const SizedBox(height: 24),

              // ── Notification Type ──
              _buildSectionLabel(
                  'Reminder Type', Icons.notifications_rounded),
              const SizedBox(height: 4),
              Text(
                'How would you like to be reminded?',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 12),
              _buildNotifTypeSelector(controller, isDark),
              const SizedBox(height: 24),

              // ── Active Toggle ──
              _buildActiveToggle(controller, isDark),
              const SizedBox(height: 32),

              // ── Save Button ──
              _buildSaveButton(controller, isEditing),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, bool isEditing, bool isDark) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: const Icon(Icons.close_rounded, size: 20),
        ),
      ),
      title: Text(
        isEditing ? 'Edit Medicine' : 'Add Medicine',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  // ─── Header Card ─────────────────────────────────────────────────────────────
  Widget _buildHeaderCard(bool isEditing, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.medicineGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.medication_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Update Medicine' : 'New Medicine Reminder',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isEditing
                      ? 'Modify details and save'
                      : 'Set up your daily medicine schedule',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Label ────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.medicineColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ─── Name Field ───────────────────────────────────────────────────────────────
  Widget _buildNameField(MedicineController controller, bool isDark) {
    return TextField(
      controller: controller.nameController,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'e.g. Paracetamol 500mg',
        prefixIcon: const Icon(
          Icons.medication_outlined,
          color: AppColors.medicineColor,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.medicineColor, width: 1.8),
        ),
      ),
    );
  }

  // ─── Times Section ────────────────────────────────────────────────────────────
  Widget _buildTimesSection(
      MedicineController controller, BuildContext context, bool isDark) {
    return Obx(() {
      return Column(
        children: [
          // Existing time chips
          if (controller.selectedTimes.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  controller.selectedTimes.length,
                  (i) {
                    final t = controller.selectedTimes[i];
                    return AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.medicineGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.medicineColor.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              TimeUtils.formatTimeOfDay(t),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => controller.removeTime(i),
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Add time button
          GestureDetector(
            onTap: () => _pickTime(controller, context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.medicineColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.medicineColor.withOpacity(0.3),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.medicineColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    controller.selectedTimes.isEmpty
                        ? 'Add Reminder Time'
                        : 'Add Another Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.medicineColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _pickTime(
      MedicineController controller, BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: AppColors.medicineColor,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.addTime(picked);
    }
  }

  // ─── Notification Type Selector ───────────────────────────────────────────────
  Widget _buildNotifTypeSelector(MedicineController controller, bool isDark) {
    final types = [
      (
        AppConstants.notifTypeNotification,
        'Notification',
        'Silent push notification',
        Icons.notifications_outlined,
        AppColors.primary,
      ),
      (
        AppConstants.notifTypeAlarm,
        'Alarm',
        'Loud alarm with sound',
        Icons.alarm_rounded,
        AppColors.warning,
      ),
      (
        AppConstants.notifTypeBoth,
        'Both',
        'Notification + Alarm',
        Icons.notifications_active_rounded,
        AppColors.secondary,
      ),
      (
        AppConstants.notifTypeNone,
        'None',
        'No reminder',
        Icons.notifications_off_outlined,
        Colors.grey,
      ),
    ];

    return Obx(() {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.4,
        ),
        itemCount: types.length,
        itemBuilder: (ctx, i) {
          final type = types[i];
          final isSelected = controller.selectedNotifType.value == type.$1;

          return GestureDetector(
            onTap: () => controller.setNotifType(type.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? type.$5.withOpacity(0.1)
                    : (isDark ? AppColors.darkCard : AppColors.lightCard),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? type.$5
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 1.8 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      type.$4,
                      color: isSelected ? type.$5 : Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            type.$2,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? type.$5 : null,
                            ),
                          ),
                          Text(
                            type.$3,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: type.$5,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // ─── Active Toggle ────────────────────────────────────────────────────────────
  Widget _buildActiveToggle(MedicineController controller, bool isDark) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: controller.isActive.value
                    ? AppColors.secondary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                controller.isActive.value
                    ? Icons.check_circle_outline_rounded
                    : Icons.pause_circle_outline_rounded,
                color: controller.isActive.value
                    ? AppColors.secondary
                    : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enable Reminders',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    controller.isActive.value
                        ? 'Reminders are active'
                        : 'Reminders are paused',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: controller.isActive.value,
              onChanged: (v) => controller.isActive.value = v,
              activeColor: AppColors.secondary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      );
    });
  }

  // ─── Save Button ──────────────────────────────────────────────────────────────
  Widget _buildSaveButton(MedicineController controller, bool isEditing) {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () {
                  if (isEditing) {
                    controller.updateMedicine();
                  } else {
                    controller.addMedicine();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.medicineColor,
            disabledBackgroundColor:
                AppColors.medicineColor.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEditing
                          ? Icons.save_rounded
                          : Icons.add_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEditing ? 'Save Changes' : 'Add Medicine',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}