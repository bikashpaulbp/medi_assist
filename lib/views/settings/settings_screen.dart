// lib/views/settings/settings_screen.dart
import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/foreground_service.dart';
import '../../core/services/permission_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/alarm_service.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    final isRunning = await ForegroundService.isRunning();
    if (mounted) {
      setState(() {
        _isServiceRunning = isRunning;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildForegroundServiceTile(),
          const Divider(height: 32),
          _buildPermissionSection(),
          const Divider(height: 32),
          _buildTestSection(),
          const Divider(height: 32),
          _buildSystemSettingsSection(),
          const Divider(height: 32),
          _buildAboutSection(),
        ],
      ),
    );
  }

  // Foreground Service Control Tile
  Widget _buildForegroundServiceTile() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        title: const Text(
          'Foreground Service',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Keep MediAssist running in the background to receive reminders.'),
        value: _isServiceRunning,
        onChanged: (bool value) async {
          if (value) {
            ForegroundService.startService();
            Get.snackbar('Service Started', 'MediAssist is now running in the background.');
          } else {
            ForegroundService.stopService();
            Get.snackbar('Service Stopped', 'You may miss reminders while the service is off.');
          }
          _checkServiceStatus();
        },
        activeColor: AppColors.primary,
      ),
    );
  }

  // Permissions Section
  Widget _buildPermissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'App Permissions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildPermissionTile(
          'Notifications',
          'Receive reminder notifications.',
          Permission.notification,
        ),
        const SizedBox(height: 12),
        if (GetPlatform.isAndroid) ...[
          _buildBatteryOptimizationTile(),
          const SizedBox(height: 12),
          _buildAutoStartTile(),
        ],
      ],
    );
  }

  // Generic Permission Tile
  Widget _buildPermissionTile(String title, String description, Permission permission) {
    return FutureBuilder<PermissionStatus>(
      future: PermissionService.getPermissionStatus(permission),
      builder: (context, snapshot) {
        final status = snapshot.data;
        final isGranted = status?.isGranted ?? false;

        return Card(
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              isGranted ? Icons.check_circle : Icons.block,
              color: isGranted ? Colors.green : Colors.red,
            ),
            title: Text(title),
            subtitle: Text(description),
            trailing: ElevatedButton(
              onPressed: () async {
                if (isGranted) {
                  Get.snackbar(
                    'Permission Already Granted',
                    'No action needed.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  final granted = await PermissionService.requestPermission(
                    permission,
                    rationale: 'We need $title permission to function properly.',
                  );
                  if (granted) {
                    Get.snackbar('Permission Granted', '$title permission has been granted.');
                    setState(() {}); // Refresh UI
                  } else {
                    Get.snackbar('Permission Denied', '$title permission is required for full functionality.');
                  }
                }
              },
              child: Text(isGranted ? 'Granted' : 'Request'),
            ),
          ),
        );
      },
    );
  }

  // Battery Optimization Tile (Android only)
  Widget _buildBatteryOptimizationTile() {
    return FutureBuilder<BatteryRestrictionSnapshot?>(
      future: PermissionService.getBatteryRestrictionSnapshot(),
      builder: (context, snapshot) {
        final isEnabled = snapshot.data?.isBatteryOptimizationEnabled ?? true;

        return Card(
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              isEnabled ? Icons.battery_alert : Icons.battery_std,
              color: isEnabled ? Colors.orange : Colors.green,
            ),
            title: const Text('Battery Optimization'),
            subtitle: const Text('Disable to prevent system from stopping the app.'),
            trailing: ElevatedButton(
              onPressed: () async {
                await PermissionService.requestBatteryOptimization();
                setState(() {});
              },
              child: Text(isEnabled ? 'Disable' : 'Check Status'),
            ),
          ),
        );
      },
    );
  }

  // Auto-Start Tile (Android only)
  Widget _buildAutoStartTile() {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.start, color: Colors.purple),
        title: const Text('Auto-Start / Background Settings'),
        subtitle: const Text('Enable for reliable background operation (Xiaomi, Oppo, etc.).'),
        trailing: ElevatedButton(
          onPressed: () => PermissionService.openAutoStartSettings(),
          child: const Text('Configure'),
        ),
      ),
    );
  }

  // Test Section
  Widget _buildTestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Notifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.blue),
            title: const Text('Test Notification'),
            subtitle: const Text('Show a sample notification.'),
            trailing: ElevatedButton(
              onPressed: () async {
                await NotificationService.showNotification(
                  id: 9999,
                  title: 'Test Notification',
                  body: 'This is a test notification from MediAssist.',
                );
                Get.snackbar('Notification Sent', 'Check your notification tray.');
              },
              child: const Text('Send'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.alarm, color: Colors.orange),
            title: const Text('Test Alarm'),
            subtitle: const Text('Trigger a test alarm.'),
            trailing: ElevatedButton(
              onPressed: () async {
                final alarmTime = DateTime.now().add(const Duration(seconds: 5));
                await AlarmService.scheduleAlarm(
                  id: 9998,
                  time: alarmTime,
                  title: 'Test Alarm',
                  body: 'This is a test alarm from MediAssist.',
                );
                Get.snackbar('Alarm Scheduled', 'Alarm will ring in 5 seconds.');
              },
              child: const Text('Schedule'),
            ),
          ),
        ),
      ],
    );
  }

  // System Settings Section
  Widget _buildSystemSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.settings, color: AppColors.primary),
            title: const Text('Open App Settings'),
            subtitle: const Text('Manually manage all app permissions.'),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () => PermissionService.openAppSettings(),
            ),
          ),
        ),
        if (GetPlatform.isAndroid) ...[
          const SizedBox(height: 12),
          Card(
  elevation: 0,
  color: Colors.grey[50],
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: ListTile(
    leading: const Icon(Icons.alarm, color: Colors.orange),
    title: const Text('Exact Alarm Permission'),
    subtitle: const Text('Required for reliable alarm reminders.'),
    trailing: ElevatedButton(
      onPressed: () async {
        await PermissionService.checkAndRequestAlarmPermission();
        Get.snackbar('Permission Checked', 'Alarm permission status updated.');
      },
      child: const Text('Request'),
    ),
  ),
),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: const Text('Open Notification Settings'),
              subtitle: const Text('Check notification channel settings.'),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () => PermissionService.openNotificationSettings(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // About Section
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('MediAssist'),
            subtitle: const Text('Version 1.0.0\nYour personal health reminder app.'),
            trailing: const Icon(Icons.health_and_safety, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}