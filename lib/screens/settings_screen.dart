import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<AppProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Choose Theme',
                    style: Theme.of(context).textTheme.titleLarge?.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildThemeOption(context, 'System Default', ThemeMode.system, provider),
                _buildThemeOption(context, 'Light Mode', ThemeMode.light, provider),
                _buildThemeOption(context, 'Dark Mode', ThemeMode.dark, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, 
    String title, 
    ThemeMode mode, 
    AppProvider provider
  ) {
    final isSelected = provider.themeMode == mode;
    return ListTile(
      title: Text(title),
      leading: Icon(
        mode == ThemeMode.light ? Icons.light_mode : 
        mode == ThemeMode.dark ? Icons.dark_mode : Icons.settings_brightness,
        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        provider.setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _launchEmail(String subject) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@studentrank.com',
      query: 'subject=$subject',
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final isDemoOrGuest = user?.isDemo == true || user?.isGuest == true;

    return Scaffold(
      appBar: const StudentRankAppBar(title: 'Settings'),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          _buildSection(
            context,
            'Account',
            [
              _buildTile(context, Icons.person_outline, 'Edit Profile', () {
                context.go('/settings/edit-profile');
              }),
              _buildTile(context, Icons.verified_user, 'Verification Status', () {
                 context.go('/settings/verification');
              }),
              _buildTile(
                context, 
                Icons.email_outlined, 
                'Change Email', 
                () {
                  context.go('/settings/change-email');
                },
                enabled: !isDemoOrGuest,
                subtitle: isDemoOrGuest ? 'Not available for guest accounts' : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Privacy & Security',
            [
              _buildTile(context, Icons.lock_outline, 'Privacy Controls', () => context.go('/settings/privacy')),
              _buildTile(context, Icons.visibility_outlined, 'Profile Visibility', () => context.go('/settings/privacy')),
              _buildTile(context, Icons.security, 'Security', () => context.go('/settings/security')),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Notifications',
            [
              _buildTile(context, Icons.notifications_outlined, 'Push Notifications', () => context.go('/settings/notifications')),
              _buildTile(context, Icons.email_outlined, 'Email Notifications', () => context.go('/settings/notifications')),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'App',
            [
              _buildTile(context, Icons.palette_outlined, 'Theme', () => _showThemeBottomSheet(context), trailingText: _getThemeName(provider.themeMode)),
              _buildTile(context, Icons.language, 'Language', () => context.go('/settings/language'), trailingText: 'English'),
              _buildTile(context, Icons.info_outline, 'About', () => context.go('/settings/about')),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Support',
            [
              _buildTile(context, Icons.help_outline, 'Help Center', () => context.go('/settings/help')),
              _buildTile(context, Icons.feedback_outlined, 'Send Feedback', () => _launchEmail('Feedback for StudentRank')),
              _buildTile(context, Icons.bug_report_outlined, 'Report Bug', () => _launchEmail('Bug Report')),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<AppProvider>().signOut();
                      },
                      child: Text('Sign Out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return 'System';
      case ThemeMode.light: return 'Light';
      case ThemeMode.dark: return 'Dark';
    }
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(title, style: context.textStyles.titleSmall?.semiBold.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              final isLast = index == children.length - 1;
              return Column(
                children: [
                  child,
                  if (!isLast)
                    Divider(height: 1, color: Theme.of(context).colorScheme.outline),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, 
    IconData icon, 
    String title, 
    VoidCallback onTap, {
    String? trailingText,
    bool enabled = true,
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: enabled ? Theme.of(context).colorScheme.onSurface : Theme.of(context).disabledColor),
      title: Text(title, style: TextStyle(color: enabled ? Theme.of(context).colorScheme.onSurface : Theme.of(context).disabledColor)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Theme.of(context).disabledColor)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(trailingText, style: context.textStyles.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(width: 8),
          ],
          Icon(Icons.chevron_right, color: enabled ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).disabledColor),
        ],
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
