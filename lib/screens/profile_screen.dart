import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/models/activity.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/services/activity_service.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/activity_card.dart';
import 'package:studentrank/widgets/verified_badge.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final ActivityService _activityService = ActivityService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final user = appProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: StudentRankAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.tertiaryContainer,
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(user.name.substring(0, 1).toUpperCase(), style: context.textStyles.displayMedium?.bold.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.name, style: context.textStyles.headlineSmall?.bold),
                      if (user.isVerified) ...[
                        const SizedBox(width: 8),
                        const VerifiedBadge(size: 24),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(user.collegeName ?? 'No College Set', style: context.textStyles.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  if (user.bio != null) ...[
                    const SizedBox(height: 12),
                    Text(user.bio!, style: context.textStyles.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(context, user.reputationScore.toString(), 'Reputation'),
                      Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outline),
                      _buildStatColumn(context, '#${user.collegeRank}', 'Rank'),
                      Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outline),
                      _buildStatColumn(context, 'Level ${user.level}', 'Progress'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: AppSpacing.horizontalLg,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  labelStyle: context.textStyles.labelMedium?.semiBold,
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(text: 'Activity'),
                    Tab(text: 'Badges'),
                    Tab(text: 'Subjects'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActivityTab(user.id),
                  _buildBadgesTab(user.badges),
                  _buildSubjectsTab(user.subjects),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: context.textStyles.titleLarge?.bold.copyWith(color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: context.textStyles.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildActivityTab(String userId) {
    return FutureBuilder<List<Activity>>(
      future: _activityService.getRecentActivities(userId, limit: 30),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context, 'No activity yet', Icons.history);
        }

        return ListView.builder(
          padding: AppSpacing.paddingLg,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => ActivityCard(activity: snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildBadgesTab(List badges) {
    if (badges.isEmpty) {
      return _buildEmptyState(context, 'No badges earned yet', Icons.emoji_events);
    }

    return GridView.builder(
      padding: AppSpacing.paddingLg,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events, size: 32, color: Theme.of(context).colorScheme.onTertiaryContainer),
              ),
              const SizedBox(height: 12),
              Text(badge.name, style: context.textStyles.titleSmall?.semiBold, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(badge.description, style: context.textStyles.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectsTab(List<String> subjects) {
    if (subjects.isEmpty) {
      return _buildEmptyState(context, 'No subjects added', Icons.school);
    }

    return ListView.separated(
      padding: AppSpacing.paddingLg,
      itemCount: subjects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.book, size: 24, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(subject, style: context.textStyles.titleMedium?.semiBold),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(message, style: context.textStyles.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
