import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentRankAppBar(title: 'About StudentRank'),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(Icons.school_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'StudentRank',
                  style: Theme.of(context).textTheme.headlineMedium?.bold,
                ),
                const SizedBox(height: 8),
                Text(
                  'Version $_version',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Our Mission',
            style: Theme.of(context).textTheme.titleLarge?.bold,
          ),
          const SizedBox(height: 12),
          Text(
            'StudentRank is designed to democratize academic reputation. We believe every contribution counts, whether it\'s sharing a helpful note, organizing a study group, or answering a complex question. Our goal is to build a trustworthy platform where students can showcase their knowledge and verify their skills beyond grades.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {}, // Add URL launcher
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {}, // Add URL launcher
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Open Source Licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}
