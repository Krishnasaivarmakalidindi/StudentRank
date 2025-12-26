import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/models/activity.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/services/activity_service.dart';
import 'package:studentrank/theme.dart';
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

    final theme = Theme.of(context);
    
    // Calculate progress to next level (Mock logic: 1000 pts per level)
    final pointsForNextLevel = (user.level + 1) * 1000;
    final pointsInCurrentLevel = user.reputationScore % 1000;
    final progress = pointsInCurrentLevel / 1000.0;
    final remainingPoints = 1000 - pointsInCurrentLevel;

    return Scaffold(
      appBar: StudentRankAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/settings/edit-profile'),
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // --- HEADER ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      decoration: BoxDecoration(
                         color: theme.colorScheme.surface,
                         border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))),
                      ),
                      child: Column(
                        children: [
                           Stack(
                             children: [
                               CircleAvatar(
                                 radius: 56,
                                 backgroundColor: theme.colorScheme.primaryContainer,
                                 backgroundImage: user.profileImageUrl != null ? NetworkImage(user.profileImageUrl!) : null,
                                 child: user.profileImageUrl == null
                                     ? Text(user.name.substring(0, 1).toUpperCase(), 
                                            style: context.textStyles.displayMedium?.bold.copyWith(color: theme.colorScheme.onPrimaryContainer))
                                     : null,
                               ),
                               Positioned(
                                 bottom: 0,
                                 right: 0,
                                 child: Container(
                                   padding: const EdgeInsets.all(8),
                                   decoration: BoxDecoration(
                                     color: theme.colorScheme.primary,
                                     shape: BoxShape.circle,
                                     border: Border.all(color: theme.colorScheme.surface, width: 2),
                                   ),
                                   child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 16),
                           
                           // Name & Verification
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Text(user.name, style: context.textStyles.headlineSmall?.bold),
                               if (user.isVerified) ...[
                                 const SizedBox(width: 8),
                                 const VerifiedBadge(size: 20),
                               ],
                             ],
                           ),
                           
                           // College & Joined Date
                           const SizedBox(height: 4),
                           Text(
                             user.collegeName ?? 'No College Set',
                             style: context.textStyles.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             'Joined ${DateFormat.yMMMd().format(user.createdAt)}',
                             style: context.textStyles.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                           ),

                           // Bio
                           if (user.bio != null && user.bio!.isNotEmpty) ...[
                             const SizedBox(height: 12),
                             Text(
                               user.bio!,
                               style: context.textStyles.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                               textAlign: TextAlign.center,
                               maxLines: 3,
                               overflow: TextOverflow.ellipsis,
                             ),
                           ],
                        ],
                      ),
                    ),
                    
                    // --- STATS ---
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Reputation
                          Column(
                            children: [
                               Text(
                                 '${user.reputationScore}',
                                 style: context.textStyles.displaySmall?.copyWith(
                                   color: theme.colorScheme.primary,
                                   fontWeight: FontWeight.w800,
                                   fontSize: 40,
                                 ),
                               ),
                               Text('Reputation', style: context.textStyles.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                          
                          Container(width: 1, height: 50, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                          
                          // Level Progress
                          Column(
                            children: [
                               Stack(
                                 alignment: Alignment.center,
                                 children: [
                                   SizedBox(
                                     height: 60,
                                     width: 60,
                                     child: CircularProgressIndicator(
                                       value: progress,
                                       strokeWidth: 6,
                                       backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                       color: theme.colorScheme.secondary,
                                       strokeCap: StrokeCap.round,
                                     ),
                                   ),
                                   Text(
                                     'Lvl ${user.level}',
                                     style: context.textStyles.titleMedium?.bold,
                                   ),
                                 ],
                               ),
                               const SizedBox(height: 8),
                               Text(
                                 '$remainingPoints pts to next',
                                 style: context.textStyles.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 10),
                               ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: theme.colorScheme.primary,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    labelStyle: context.textStyles.titleSmall?.semiBold,
                    tabs: const [
                      Tab(text: 'Activity'),
                      Tab(text: 'Badges'),
                      Tab(text: 'Subjects'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildActivityTab(user.id),
              _buildBadgesTab(user.badges),
              _buildSubjectsTab(user.subjects),
            ],
          ),
        ),
      ),
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
          return _buildEmptyActivityState(context);
        }
        
        return ListView.separated(
          padding: AppSpacing.paddingLg,
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, index) => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 20), 
              height: 20, 
              width: 2, 
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)
            ),
          ),
          itemBuilder: (context, index) {
            final activity = snapshot.data![index];
            return _buildTimelineItem(context, activity);
          },
        );
      },
    );
  }
  
  Widget _buildTimelineItem(BuildContext context, Activity activity) {
    IconData icon;
    Color color;
    
    switch (activity.type) {
      case ActivityType.upload:
        icon = Icons.upload_file;
        color = Colors.blue;
        break;
      case ActivityType.improve:
        icon = Icons.rate_review;
        color = Colors.orange;
        break;
      case ActivityType.answer:
        icon = Icons.comment;
        color = Colors.green;
        break;
      case ActivityType.achievement:
        icon = Icons.emoji_events;
        color = Colors.purple;
        break;
      case ActivityType.join:
        icon = Icons.group_add;
        color = Colors.teal;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.description,
                style: context.textStyles.bodyMedium?.semiBold,
              ),
              const SizedBox(height: 4),
              Text(
                _timeAgo(activity.createdAt),
                style: context.textStyles.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        if (activity.reputationChange > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${activity.reputationChange}',
              style: context.textStyles.labelSmall?.bold.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
      ],
    );
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 7) return DateFormat.yMMMd().format(timestamp);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Widget _buildEmptyActivityState(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingXl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_graph, size: 64, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Start building your academic profile!',
            style: context.textStyles.titleMedium?.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your contributions help other students and earn you reputation.',
            style: context.textStyles.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          _buildActionButton(
            context,
            'Upload Your First Note',
            Icons.upload_file,
            Colors.blue,
            () => context.push('/contribute'),
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            'Join a Study Group',
            Icons.group,
            Colors.teal,
            () => context.go('/groups'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            'Explore Resources',
            Icons.explore,
            Colors.purple,
            () => context.go('/explore'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, 
    String label, 
    IconData icon, 
    Color color, 
    VoidCallback onTap, 
    {bool isPrimary = false}
  ) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary 
        ? ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: color),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
    );
  }

  Widget _buildBadgesTab(List badges) {
    if (badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.military_tech_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text('No badges yet', style: context.textStyles.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: AppSpacing.paddingLg,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.emoji_events, size: 32, color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name, 
              style: context.textStyles.labelSmall?.semiBold, 
              textAlign: TextAlign.center, 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubjectsTab(List<String> subjects) {
    if (subjects.isEmpty) {
      return Center(
         child: Text('No subjects added', style: context.textStyles.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
    }

    return ListView.builder(
      padding: AppSpacing.paddingLg,
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return ListTile(
          leading: const Icon(Icons.book_outlined),
          title: Text(subject),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
