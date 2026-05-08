import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/core/constants/app_colors.dart';
import '../../controllers/home_controller.dart';

class ServiceStatusCard extends StatelessWidget {
  final HomeController controller;
  const ServiceStatusCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final isRunning = controller.isServiceRunning.value;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRunning
                ? AppColors.secondary.withOpacity(0.3)
                : AppColors.danger.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isRunning
                      ? AppColors.secondary.withOpacity(0.1)
                      : AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isRunning
                      ? Icons.shield_rounded
                      : Icons.shield_outlined,
                  color: isRunning ? AppColors.secondary : AppColors.danger,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRunning
                          ? 'Background Service Active'
                          : 'Background Service Inactive',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isRunning
                          ? 'Monitoring reminders 24/7'
                          : 'Tap to start for reliable reminders',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle button
              GestureDetector(
                onTap: controller.toggleService,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isRunning
                        ? AppColors.secondary
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isRunning ? 'Stop' : 'Start',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}