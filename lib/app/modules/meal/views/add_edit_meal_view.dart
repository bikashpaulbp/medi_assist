import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/core/constants/app_colors.dart';
import 'package:medi_assist/core/constants/app_constants.dart';
import 'package:medi_assist/core/utils/time_utils.dart';
import '../controllers/meal_controller.dart';

class AddEditMealView extends StatelessWidget {
  const AddEditMealView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MealController>();
    final isEditing = controller.editingMeal != null;
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
              _buildHeaderCard(isEditing),
              const SizedBox(height: 24),

              // ── Meal Name ──
              _buildSectionLabel('Meal Name', Icons.restaurant_rounded),
              const SizedBox(height: 10),
              _buildNameField(controller, isDark),
              const SizedBox(height: 24),

              // ── Meal Time ──
              _buildSectionLabel('Meal Time', Icons.access_time_rounded),
              const SizedBox(height: 4),
              Text(
                'Set your daily meal reminder time',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 12),
              _buildTimePickerCard(controller, context, isDark),
              const SizedBox(height: 24),

              // ── Quick Time Presets ──
              _buildSectionLabel(
                  'Quick Presets', Icons.bolt_rounded),
              const SizedBox(height: 10),
              _buildQuickPresets(controller),
              const SizedBox(height: 24),

              // ── Notification Type ──
              _buildSectionLabel(
                  'Reminder Type', Icons.notifications_rounded),
              const SizedBox(height: 4),
              Text(
                'How would you like to be reminded?',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
        isEditing ? 'Edit Meal' : 'Add Meal',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  // ─── Header Card ─────────────────────────────────────────────────────────────
  Widget _buildHeaderCard(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.mealGradient,
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
            child: const Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Update Meal' : 'New Meal Reminder',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isEditing
                      ? 'Modify meal details and save'
                      : 'Never miss your meals again',
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
        Icon(icon, size: 18, color: AppColors.mealColor),
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
  Widget _buildNameField(MealController controller, bool isDark) {
    return TextField(
      controller: controller.nameController,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'e.g. Breakfast, Lunch, Dinner...',
        prefixIcon: const Icon(
          Icons.restaurant_outlined,
          color: AppColors.mealColor,
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
              const BorderSide(color: AppColors.mealColor, width: 1.8),
        ),
      ),
    );
  }

  // ─── Time Picker Card ─────────────────────────────────────────────────────────
  Widget _buildTimePickerCard(
      MealController controller, BuildContext context, bool isDark) {
    return Obx(() {
      return GestureDetector(
        onTap: () => _pickTime(controller, context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.mealColor.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.mealColor.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Clock display
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.mealGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _padZero(controller.selectedTime.value.hourOfPeriod == 0
                          ? 12
                          : controller.selectedTime.value.hourOfPeriod),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      _padZero(controller.selectedTime.value.minute),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TimeUtils.formatTimeOfDay(
                          controller.selectedTime.value),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMealSuggestion(
                          controller.selectedTime.value.hour),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.mealColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.mealColor,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _padZero(int value) =>
      value.toString().padLeft(2, '0');

  String _getMealSuggestion(int hour) {
    if (hour >= 5 && hour < 11) return '🌅 Good time for breakfast';
    if (hour >= 11 && hour < 15) return '☀️ Lunchtime window';
    if (hour >= 15 && hour < 18) return '☕ Afternoon snack time';
    if (hour >= 18 && hour < 22) return '🌙 Dinner time';
    return '🍽️ Meal reminder';
  }

  Future<void> _pickTime(
      MealController controller, BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: controller.selectedTime.value,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: AppColors.mealColor,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.setTime(picked);
    }
  }

  // ─── Quick Presets ────────────────────────────────────────────────────────────
  Widget _buildQuickPresets(MealController controller) {
    final presets = [
      ('🌅', 'Breakfast', const TimeOfDay(hour: 8, minute: 0)),
      ('☀️', 'Lunch', const TimeOfDay(hour: 13, minute: 0)),
      ('☕', 'Snack', const TimeOfDay(hour: 16, minute: 0)),
      ('🌙', 'Dinner', const TimeOfDay(hour: 19, minute: 30)),
    ];

    return Obx(() {
      return Row(
        children: presets.map((preset) {
          final isSelected =
              controller.selectedTime.value.hour == preset.$3.hour &&
                  controller.selectedTime.value.minute == preset.$3.minute;

          return Expanded(
            child: GestureDetector(
              onTap: () => controller.setTime(preset.$3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.mealColor.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.mealColor
                        : Colors.grey.withOpacity(0.25),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(preset.$1,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 3),
                    Text(
                      preset.$2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.mealColor
                            : Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      TimeUtils.formatTimeOfDay(preset.$3),
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? AppColors.mealColor
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // ─── Notification Type Selector ───────────────────────────────────────────────
  Widget _buildNotifTypeSelector(MealController controller, bool isDark) {
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
          final isSelected =
              controller.selectedNotifType.value == type.$1;

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
                      : (isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                  width: isSelected ? 1.8 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      type.$4,
                      color:
                          isSelected ? type.$5 : Colors.grey.shade400,
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
  Widget _buildActiveToggle(MealController controller, bool isDark) {
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
                        ? 'Meal reminders are active'
                        : 'Meal reminders are paused',
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
  Widget _buildSaveButton(MealController controller, bool isEditing) {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () =>
                  isEditing ? controller.updateMeal() : controller.addMeal(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mealColor,
            disabledBackgroundColor: AppColors.mealColor.withOpacity(0.5),
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
                      isEditing ? 'Save Changes' : 'Add Meal',
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