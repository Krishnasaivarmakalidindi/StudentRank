import 'package:flutter/material.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentRankAppBar(title: 'Help Center'),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for help...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context).textTheme.titleMedium?.bold,
          ),
          const SizedBox(height: 16),
          _buildFAQItem(context, 'How do I earn reputation?', 'You earn reputation by contributing verified notes, answering questions, and receiving upvotes from peers.'),
          _buildFAQItem(context, 'How do I get verified?', 'Go to Settings > Account > Verification Status and follow the instructions to upload your student ID.'),
          _buildFAQItem(context, 'Can I change my college?', 'Yes, you can update your college in Edit Profile. However, you may need to re-verify your status.'),
          _buildFAQItem(context, 'Is StudentRank free?', 'Yes, StudentRank is completely free for all students.'),
          
          const SizedBox(height: 32),
          Text(
            'Support',
            style: Theme.of(context).textTheme.titleMedium?.bold,
          ),
          const SizedBox(height: 16),
          _buildActionTile(context, Icons.email_outlined, 'Contact Support', 'Get help from our team'),
          _buildActionTile(context, Icons.bug_report_outlined, 'Report a Problem', 'Let us know if something is broken'),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
