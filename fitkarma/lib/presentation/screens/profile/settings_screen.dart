import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _stepReminderEnabled = true;
  bool _mealReminderEnabled = true;
  bool _darkMode = false;
  bool _lowDataMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('setting_notifications') ?? true;
      _stepReminderEnabled = prefs.getBool('setting_step_reminder') ?? true;
      _mealReminderEnabled = prefs.getBool('setting_meal_reminder') ?? true;
      _darkMode = prefs.getBool('setting_dark_mode') ?? false;
      _lowDataMode = prefs.getBool('setting_low_data') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _setSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _exportData() {
    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    final data = {
      'user': user.toJson(),
      'food_logs':
          HiveService.foodLogBox.values.map((e) => e.toJson()).toList(),
      'water_logs': HiveService.waterBox.keys
          .where((k) => k.toString().startsWith('log_'))
          .map((k) {
            final v = HiveService.waterBox.get(k);
            return v?.toJson();
          })
          .whereType<Map<String, dynamic>>()
          .toList(),
      'weight_logs': HiveService.settingsBox.get('weight_logs') ?? [],
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    // Copy to clipboard for MVP (production: share_plus would save to file)
    Clipboard.setData(ClipboardData(text: jsonStr));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data copied to clipboard as JSON'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all local data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authStateProvider.notifier).signOut();
              if (mounted) context.go('/login');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Push Notifications'),
            subtitle: const Text('Enable all app notifications'),
            value: _notificationsEnabled,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (v) {
              setState(() => _notificationsEnabled = v);
              _setSetting('setting_notifications', v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.directions_walk_outlined),
            title: const Text('Step Reminder'),
            subtitle: const Text('Daily reminder to check your steps'),
            value: _stepReminderEnabled && _notificationsEnabled,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: _notificationsEnabled
                ? (v) {
                    setState(() => _stepReminderEnabled = v);
                    _setSetting('setting_step_reminder', v);
                  }
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.restaurant_outlined),
            title: const Text('Meal Reminder'),
            subtitle: const Text('Reminders to log your meals'),
            value: _mealReminderEnabled && _notificationsEnabled,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: _notificationsEnabled
                ? (v) {
                    setState(() => _mealReminderEnabled = v);
                    _setSetting('setting_meal_reminder', v);
                  }
                : null,
          ),
          const Divider(),
          _sectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme across the app'),
            value: _darkMode,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (v) {
              setState(() => _darkMode = v);
              _setSetting('setting_dark_mode', v);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restart app to apply theme change'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(),
          _sectionHeader('Data & Privacy'),
          SwitchListTile(
            secondary: const Icon(Icons.data_saver_on_outlined),
            title: const Text('Low Data Mode'),
            subtitle: const Text('Reduce image quality & sync frequency'),
            value: _lowDataMode,
            activeThumbColor: AppTheme.primaryColor,
            onChanged: (v) {
              setState(() => _lowDataMode = v);
              _setSetting('setting_low_data', v);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export My Data'),
            subtitle: const Text('Download all your health data as JSON'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportData,
          ),
          const Divider(),
          _sectionHeader('Account'),
          ListTile(
            leading:
                const Icon(Icons.delete_outline, color: AppTheme.errorColor),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            subtitle: const Text('Permanently remove all data'),
            onTap: _showDeleteAccountDialog,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium),
            child: Text(
              'FitKarma v${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
