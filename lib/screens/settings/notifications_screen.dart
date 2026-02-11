import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  late Map<String, bool> _settings;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().currentUser;
    _settings = Map.from(user?.notificationSettings ?? {});
  }

  Future<void> _updateSetting(String key, bool value) async {
    setState(() {
      _settings[key] = value;
    });
    try {
      await context.read<AppProvider>().updateNotificationSettings(_settings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update setting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentRankAppBar(title: 'Notifications'),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          _buildSectionHeader(context, 'Push Notifications'),
          _buildSwitchTile(
            'Activity Updates',
            'Get notified about new contributions and comments',
            'pushActivity',
          ),
          _buildSwitchTile(
            'Reputation Changes',
            'Get notified when your reputation score changes',
            'pushReputation',
          ),
          _buildSwitchTile(
            'Study Groups',
            'Get notified about group chats and events',
            'pushGroups',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Email Notifications'),
          _buildSwitchTile(
            'Weekly Summaries',
            'Receive a weekly digest of your progress',
            'emailSummaries',
          ),
          _buildSwitchTile(
            'Security Alerts',
            'Get notified about suspicious activity',
            'emailAlerts',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.semiBold.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, String key) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      value: _settings[key] ?? false,
      onChanged: (value) => _updateSetting(key, value),
      contentPadding: EdgeInsets.zero,
    );
  }
}
