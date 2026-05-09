import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/app/modules/home/views/widgets/home_header.dart';
import 'package:medi_assist/app/modules/home/views/widgets/module_card.dart';
import 'package:medi_assist/app/modules/home/views/widgets/permission_banner.dart';
import 'package:medi_assist/app/modules/home/views/widgets/service_status_card.dart';
import 'package:medi_assist/app/modules/home/views/widgets/today_summary_card.dart';
import 'package:medi_assist/core/constants/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshGreeting(); // already calls refreshCounts() internally
          await controller.checkServiceStatus();
          await controller.checkPermissions();
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Gradient Header ──
            SliverToBoxAdapter(child: HomeHeader(controller: controller)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Permission Banner ──
                    Obx(() {
                      if (!controller.showPermissionBanner.value) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PermissionBanner(
                          onTap: controller.requestPermissions,
                        ),
                      );
                    }),

                    // ── Today's Summary ──
                    TodaySummaryCard(controller: controller),

                    const SizedBox(height: 24),

                    // ── Section title ──
                    const Text(
                      'Health Modules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to manage your health reminders',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Module Cards Grid ──
                    _buildModuleGrid(context),

                    const SizedBox(height: 24),

                    // ── Service Status Card ──
                    ServiceStatusCard(controller: controller),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    final modules = [
      _ModuleData(
        title: 'Medicine\nReminder',
        subtitle: 'Track your medications',
        icon: Icons.medication_rounded,
        gradient: AppColors.medicineGradient,
        lightColor: AppColors.medicineColorLight,
        route: Routes.medicine,
        emoji: '💊',
        tag: 'medicine',
      ),
      _ModuleData(
        title: 'Meal\nReminder',
        subtitle: 'Never miss a meal',
        icon: Icons.restaurant_rounded,
        gradient: AppColors.mealGradient,
        lightColor: AppColors.mealColorLight,
        route: Routes.meal,
        emoji: '🍽️',
        tag: 'meal',
      ),
      _ModuleData(
        title: 'Medical\nRecords',
        subtitle: 'Log health metrics',
        icon: Icons.monitor_heart_rounded,
        gradient: AppColors.medicalGradient,
        lightColor: AppColors.medicalColorLight,
        route: Routes.medicalRecords,
        emoji: '📋',
        tag: 'medical',
      ),
      _ModuleData(
        title: 'Activity\nReminder',
        subtitle: 'Stay active daily',
        icon: Icons.directions_run_rounded,
        gradient: AppColors.activityGradient,
        lightColor: AppColors.activityColorLight,
        route: Routes.activity,
        emoji: '🏃',
        tag: 'activity',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return ModuleCard(
          title: module.title,
          subtitle: module.subtitle,
          icon: module.icon,
          gradient: module.gradient,
          lightColor: module.lightColor,
          route: module.route,
          emoji: module.emoji,
          tag: module.tag,
          animationDelay: Duration(milliseconds: 100 * index),
        );
      },
    );
  }
}

class _ModuleData {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final Color lightColor;
  final String route;
  final String emoji;
  final String tag;

  _ModuleData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.lightColor,
    required this.route,
    required this.emoji,
    required this.tag,
  });
}
