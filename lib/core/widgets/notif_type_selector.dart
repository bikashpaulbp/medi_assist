import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Reusable notification type selector used in medicine, meal & activity forms.
/// Uses Wrap (eager) instead of GridView.builder (lazy) to fix GetX Obx tracking.
class NotifTypeSelector extends StatelessWidget {
  final RxString selectedNotifType;
  final Function(String) onChanged;
  final bool isDark;

  const NotifTypeSelector({
    super.key,
    required this.selectedNotifType,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Define types as a local list — computed once
    const types = [
      (
        AppConstants.notifTypeNotification,
        'Notification',
        'Silent push alert',
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
      // ✅ Extract Rx value HERE in direct Obx scope
      // This ensures GetX registers the dependency before any lazy widget
      final selected = selectedNotifType.value;

      // ✅ Use Wrap with .map().toList() — EAGER evaluation, not lazy
      // GridView.builder was the bug: itemBuilder runs AFTER Obx tracking closes
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: types.map((type) {
          final isSelected = selected == type.$1;
          return GestureDetector(
            onTap: () => onChanged(type.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: (MediaQuery.of(Get.context!).size.width - 52) / 2,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      mainAxisSize: MainAxisSize.min,
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
          );
        }).toList(), // ✅ .toList() forces eager evaluation immediately
      );
    });
  }
}