import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/services/activity_service.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/reputation_card.dart';
import 'package:studentrank/widgets/quick_action_button.dart';
import 'package:studentrank/widgets/activity_card.dart';
import 'package:studentrank/widgets/verified_badge.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActivityService _activityService = ActivityService();
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final user = appProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: StudentRankAppBar(
        title: 'StudentRank',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => context.go('/profile'),
              borderRadius: BorderRadius.circular(20),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: context.textStyles.titleSmall?.bold.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await appProvider.refreshUser();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, ${user.name.split(' ').first}',
                      style: context.textStyles.headlineSmall?.bold,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.collegeName ?? 'No College Set',
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 6),
                          const VerifiedBadge(size: 16),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ReputationCard(
                  reputationScore: user.reputationScore,
                  rank: user.collegeRank,
                  level: user.level,
                  subject: user.subjects.isNotEmpty ? user.subjects.first : 'General',
                ),
                const SizedBox(height: 24),
                Text('Quick Actions', style: context.textStyles.titleLarge?.semiBold),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  children: [
                    QuickActionButton(
                      icon: Icons.upload_file,
                      label: 'Upload Notes',
                      iconColor: Theme.of(context).colorScheme.primary,
                      onTap: () => context.go('/contribute'),
                    ),
                    QuickActionButton(
                      icon: Icons.groups,
                      label: 'Study Groups',
                      iconColor: Colors.purple.shade600,
                      onTap: () => context.go('/groups'),
                    ),
                    QuickActionButton(
                      icon: Icons.quiz,
                      label: 'Take Challenge',
                      iconColor: Colors.orange.shade700,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Challenges coming soon!')),
                        );
                      },
                    ),
                    QuickActionButton(
                      icon: Icons.psychology,
                      label: 'Ask AI',
                      iconColor: Colors.indigo.shade600,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('AI assistant coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Activity', style: context.textStyles.titleLarge?.semiBold),
                    TextButton(
                      onPressed: () => context.go('/profile'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder(
                  future: _activityService.getFeedActivities(limit: 5),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) => ActivityCard(activity: snapshot.data![index]),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingLg,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.tertiaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.rocket_launch, size: 32, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Contribute something today', style: context.textStyles.titleLarge?.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Share your knowledge and earn reputation points', style: context.textStyles.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/contribute'),
                        icon: const Icon(Icons.add),
                        label: const Text('Start Contributing'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          children: [
            Icon(Icons.history, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No recent activity', style: context.textStyles.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Start contributing to see your activity here', style: context.textStyles.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
