import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';
import 'package:studentrank/widgets/verified_badge.dart';

class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: const StudentRankAppBar(title: 'Verification Status'),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          _buildStatusCard(context, user),
          const SizedBox(height: 24),
          Text(
            'Verification Steps',
            style: Theme.of(context).textTheme.titleMedium?.bold,
          ),
          const SizedBox(height: 16),
          _buildStep(
            context,
            'Email Verification',
            'Verify your email address to secure your account.',
            isCompleted: user.email != null && !user.isGuest && !user.isDemo, // Basic check
            action: user.email != null && !user.isGuest && !user.isDemo 
                ? null 
                : TextButton(onPressed: () {}, child: const Text('Verify')),
          ),
          const SizedBox(height: 12),
          _buildStep(
            context,
            'College Verification',
            'Upload your student ID or use a .edu email to verify your student status.',
            isCompleted: user.isVerified,
            action: user.isVerified
                ? null 
                : TextButton(onPressed: () {}, child: const Text('Verify')),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Benefits of Verification',
                      style: Theme.of(context).textTheme.titleSmall?.bold.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBenefit(context, 'Official Verified Badge on your profile'),
                _buildBenefit(context, 'Access to college-exclusive groups'),
                _buildBenefit(context, 'Higher visibility for your contributions'),
                _buildBenefit(context, 'Participate in inter-college rankings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, dynamic user) {
    String accountType = 'Standard Account';
    Color statusColor = Theme.of(context).colorScheme.primary;
    IconData statusIcon = Icons.account_circle;

    if (user.isDemo) {
      accountType = 'Demo Account';
      statusColor = Colors.orange;
      statusIcon = Icons.science;
    } else if (user.isGuest) {
      accountType = 'Guest Account';
      statusColor = Colors.grey;
      statusIcon = Icons.person_outline;
    } else if (user.isVerified) {
      accountType = 'Verified Student';
      statusColor = Colors.green;
      statusIcon = Icons.verified;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 48, color: statusColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                accountType,
                style: Theme.of(context).textTheme.titleLarge?.bold,
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 8),
                const VerifiedBadge(size: 20),
              ],
            ],
          ),
          const SizedBox(height: 4),
          if (user.email != null)
            Text(
              user.email!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String title, String description, {required bool isCompleted, Widget? action}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Colors.green.withOpacity(0.1) 
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.circle_outlined,
              size: 20,
              color: isCompleted ? Colors.green : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.semiBold),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 8),
                  action,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
