import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_assist/core/constants/app_colors.dart';
import 'package:medi_assist/core/constants/app_constants.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── App Info Header ──
          _buildAppInfoCard(isDark),
          const SizedBox(height: 24),

          // ── Background Service ──
          _buildSectionTitle('Background Service'),
          const SizedBox(height: 10),
          _buildServiceCard(controller, isDark),
          const SizedBox(height: 24),

          // ── Permissions ──
          _buildSectionTitle('Permissions'),
          const SizedBox(height: 10),
          _buildPermissionsCard(controller, isDark),
          const SizedBox(height: 24),

          // ── Reminders ──
          _buildSectionTitle('Reminders'),
          const SizedBox(height: 10),
          _buildRemindersCard(controller, isDark),
          const SizedBox(height: 24),

          // ── Diagnostics ──
          _buildSectionTitle('Diagnostics'),
          const SizedBox(height: 10),
          _buildDiagnosticsCard(controller, isDark),
          const SizedBox(height: 24),

          // ── Data ──
          _buildSectionTitle('Data Management'),
          const SizedBox(height: 10),
          _buildDataCard(controller, isDark),
          const SizedBox(height: 24),

          // ── About ──
          _buildAboutCard(isDark),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
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
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ),
      title: const Text(
        'Settings',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }

  // ─── Section Title ────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 0.8,
      ),
    );
  }

  // ─── App Info Card ────────────────────────────────────────────────────────────
  Widget _buildAppInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MediAssist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Your Personal Health Companion',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Service Card ─────────────────────────────────────────────────────────────
  Widget _buildServiceCard(SettingsController controller, bool isDark) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        Obx(() {
          final isRunning = controller.isServiceRunning.value;
          return _SettingsTile(
            isDark: isDark,
            icon: isRunning ? Icons.shield_rounded : Icons.shield_outlined,
            iconColor: isRunning ? AppColors.secondary : AppColors.danger,
            title: 'Background Service',
            subtitle: isRunning
                ? 'Running 24/7 — reminders are reliable'
                : 'Stopped — reminders may be delayed',
            trailing: Switch(
              value: isRunning,
              onChanged: (_) => controller.toggleForegroundService(),
              activeColor: AppColors.secondary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            showDivider: false,
          );
        }),
      ],
    );
  }

  // ─── Permissions Card ─────────────────────────────────────────────────────────
  Widget _buildPermissionsCard(
      SettingsController controller, bool isDark) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        Obx(() {
          final status = controller.permissionStatus;

          return Column(
            children: [
              // Notification permission
              _PermissionTile(
                isDark: isDark,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Required for reminder alerts',
                isGranted: status['notification'] ?? false,
                onTap: controller.requestAllPermissions,
                showDivider: true,
              ),

              // Exact alarm permission
              _PermissionTile(
                isDark: isDark,
                icon: Icons.alarm_outlined,
                title: 'Exact Alarms',
                subtitle: 'Required for precise alarm timing',
                isGranted: status['exactAlarm'] ?? false,
                onTap: controller.openAlarmSettings,
                showDivider: true,
              ),

              // Battery optimization
              _PermissionTile(
                isDark: isDark,
                icon: Icons.battery_saver_outlined,
                title: 'Battery Optimization',
                subtitle: 'Disable to keep reminders running',
                isGranted: status['batteryOptimization'] ?? false,
                onTap: controller.openBatterySettings,
                showDivider: false,
              ),
            ],
          );
        }),

        // Refresh permissions button
        const SizedBox(height: 4),
        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
        _SettingsTile(
          isDark: isDark,
          icon: Icons.refresh_rounded,
          iconColor: AppColors.primary,
          title: 'Refresh Permission Status',
          subtitle: 'Check current permission states',
          onTap: controller.refreshPermissions,
          showDivider: false,
        ),
      ],
    );
  }

  // ─── Reminders Card ───────────────────────────────────────────────────────────
  Widget _buildRemindersCard(
      SettingsController controller, bool isDark) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        _SettingsTile(
          isDark: isDark,
          icon: Icons.restart_alt_rounded,
          iconColor: AppColors.primary,
          title: 'Reschedule All Reminders',
          subtitle: 'Fix reminders if they stopped working',
          onTap: controller.rescheduleAll,
          showDivider: true,
        ),
        _SettingsTile(
          isDark: isDark,
          icon: Icons.notifications_active_rounded,
          iconColor: AppColors.secondary,
          title: 'Send Test Notification',
          subtitle: 'Verify notifications are working',
          onTap: controller.sendTestNotification,
          showDivider: false,
        ),
      ],
    );
  }

  // ─── Diagnostics Card ─────────────────────────────────────────────────────────
  Widget _buildDiagnosticsCard(
      SettingsController controller, bool isDark) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        Obx(() {
          return _SettingsTile(
            isDark: isDark,
            icon: Icons.pending_outlined,
            iconColor: AppColors.primary,
            title: 'Pending Notifications',
            subtitle:
                '${controller.pendingNotifCount.value} scheduled notification${controller.pendingNotifCount.value != 1 ? 's' : ''}',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.pendingNotifCount.value.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            onTap: controller.loadPendingNotifications,
            showDivider: false,
          );
        }),
      ],
    );
  }

  // ─── Data Card ────────────────────────────────────────────────────────────────
  Widget _buildDataCard(SettingsController controller, bool isDark) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        _SettingsTile(
          isDark: isDark,
          icon: Icons.delete_forever_rounded,
          iconColor: AppColors.danger,
          title: 'Clear All Data',
          subtitle: 'Delete all medicines, meals, records & activities',
          titleColor: AppColors.danger,
          onTap: controller.clearAllData,
          showDivider: false,
        ),
      ],
    );
  }

  // ─── About Card ───────────────────────────────────────────────────────────────
  Widget _buildAboutCard(bool isDark) {
    return _SettingsCard(
      isDark: isDark,
      children: [
        _SettingsTile(
          isDark: isDark,
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.primary,
          title: 'About MediAssist',
          subtitle: 'Health reminder app — v${AppConstants.appVersion}',
          showDivider: true,
        ),
        _SettingsTile(
          isDark: isDark,
          icon: Icons.privacy_tip_outlined,
          iconColor: AppColors.secondary,
          title: 'Privacy',
          subtitle: 'All data is stored locally on your device',
          showDivider: false,
        ),
      ],
    );
  }
}

// ─── Reusable Settings Card ───────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ─── Reusable Settings Tile ───────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final Color? titleColor;

  const _SettingsTile({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    required this.showDivider,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 70,
            color: Colors.grey.withOpacity(0.1),
          ),
      ],
    );
  }
}

// ─── Permission Tile ──────────────────────────────────────────────────────────
class _PermissionTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback? onTap;
  final bool showDivider;

  const _PermissionTile({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isGranted,
    this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: isGranted ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isGranted
                        ? AppColors.secondary.withOpacity(0.1)
                        : AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    color: isGranted
                        ? AppColors.secondary
                        : AppColors.danger,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                isGranted
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Granted',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Fix',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 70,
            color: Colors.grey.withOpacity(0.1),
          ),
      ],
    );
  }
}