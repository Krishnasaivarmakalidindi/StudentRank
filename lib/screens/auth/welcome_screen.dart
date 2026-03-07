import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studentrank/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Icon(Icons.emoji_events, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 32),
              Text('Welcome to\nStudentRank', style: context.textStyles.displaySmall?.bold),
              const SizedBox(height: 16),
              Text('Track your academic contributions, build your reputation, and showcase your verified skills.', style: context.textStyles.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 40),
              _buildFeature(context, Icons.verified_user, 'Verified Identity', 'College-verified academic profile'),
              const SizedBox(height: 20),
              _buildFeature(context, Icons.trending_up, 'Build Reputation', 'Earn points for quality contributions'),
              const SizedBox(height: 20),
              _buildFeature(context, Icons.workspace_premium, 'Skill Badges', 'Exportable achievements for employers'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/auth'),
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textStyles.titleMedium?.semiBold),
              const SizedBox(height: 4),
              Text(subtitle, style: context.textStyles.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
