import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

class AppUtils {
  AppUtils._();

  // ─── Snackbars ───────────────────────────────────────────────────────────────

  static void showSuccess(String message, {String title = 'Success'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.secondary,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  static void showError(String message, {String title = 'Error'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      icon: const Icon(Icons.error_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  static void showWarning(String message, {String title = 'Warning'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      icon: const Icon(Icons.warning_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  static void showInfo(String message, {String title = 'Info'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      icon: const Icon(Icons.info_rounded, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────────

  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    Color confirmColor = AppColors.danger,
    IconData icon = Icons.delete_outline_rounded,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: confirmColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: confirmColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  // ─── Notification Type Helpers ───────────────────────────────────────────────

  static String notifTypeLabel(String type) {
    switch (type) {
      case 'notification':
        return 'Notification';
      case 'alarm':
        return 'Alarm';
      case 'both':
        return 'Notification + Alarm';
      case 'none':
        return 'None';
      default:
        return 'Notification';
    }
  }

  static IconData notifTypeIcon(String type) {
    switch (type) {
      case 'notification':
        return Icons.notifications_outlined;
      case 'alarm':
        return Icons.alarm_outlined;
      case 'both':
        return Icons.notifications_active_outlined;
      case 'none':
        return Icons.notifications_off_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  static Color notifTypeColor(String type) {
    switch (type) {
      case 'notification':
        return AppColors.primary;
      case 'alarm':
        return AppColors.warning;
      case 'both':
        return AppColors.secondary;
      case 'none':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  // ─── Module Color/Icon Helpers ───────────────────────────────────────────────

  static Color moduleColor(String module) {
    switch (module) {
      case 'medicine':
        return AppColors.medicineColor;
      case 'meal':
        return AppColors.mealColor;
      case 'medical':
        return AppColors.medicalColor;
      case 'activity':
        return AppColors.activityColor;
      default:
        return AppColors.primary;
    }
  }
}