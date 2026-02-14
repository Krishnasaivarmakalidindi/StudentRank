import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  late Map<String, bool> _settings;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().currentUser;
    _settings = Map.from(user?.privacySettings ?? {});
  }

  Future<void> _updateSetting(String key, bool value) async {
    setState(() {
      _settings[key] = value;
    });
    try {
      await context.read<AppProvider>().updatePrivacySettings(_settings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update setting: $e')),
        );
      }
    }
  }

  Future<void> _updateProfileVisibility(String mode) async {
    // mode: 'public', 'college', 'private'
    bool profileVisible = true;
    bool collegeOnly = false;

    if (mode == 'private') {
      profileVisible = false;
    } else if (mode == 'college') {
      profileVisible = true;
      collegeOnly = true;
    } else {
      // public
      profileVisible = true;
      collegeOnly = false;
    }

    setState(() {
      _settings['profileVisible'] = profileVisible;
      _settings['collegeOnly'] = collegeOnly;
    });

    try {
      await context.read<AppProvider>().updatePrivacySettings(_settings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update setting: $e')),
        );
      }
    }
  }

  String _getCurrentVisibilityMode() {
    if (_settings['profileVisible'] == false) return 'private';
    if (_settings['collegeOnly'] == true) return 'college';
    return 'public';
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = _getCurrentVisibilityMode();

    return Scaffold(
      appBar: const StudentRankAppBar(title: 'Privacy Controls'),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          _buildSectionHeader(context, 'Profile Visibility'),
          _buildRadioTile(
            'Public',
            'Visible to everyone on StudentRank',
            'public',
            currentMode,
          ),
          _buildRadioTile(
            'College Only',
            'Visible only to students from your college',
            'college',
            currentMode,
          ),
          _buildRadioTile(
            'Private',
            'Visible only to you',
            'private',
            currentMode,
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Content Privacy'),
          SwitchListTile(
            title: const Text('Show Contributions'),
            subtitle: Text(
              'Allow others to see your notes and resources',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            value: _settings['contributionsVisible'] ?? true,
            onChanged: (value) => _updateSetting('contributionsVisible', value),
            contentPadding: EdgeInsets.zero,
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

  Widget _buildRadioTile(
      String title, String subtitle, String value, String groupValue) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
      onChanged: (v) {
        if (v != null) _updateProfileVisibility(v);
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}
