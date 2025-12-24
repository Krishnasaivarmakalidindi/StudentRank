import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/models/study_group.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/services/study_group_service.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/group_card.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> with SingleTickerProviderStateMixin {
  final StudyGroupService _groupService = StudyGroupService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    return Scaffold(
      appBar: const StudentRankAppBar(title: 'Groups'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                      labelStyle: context.textStyles.labelLarge?.semiBold,
                      padding: const EdgeInsets.all(4),
                      tabs: const [
                        Tab(text: 'My Groups'),
                        Tab(text: 'Browse'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyGroups(user?.id ?? '1'),
                  _buildBrowseGroups(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGroups(String userId) {
    return FutureBuilder<List<StudyGroup>>(
      future: _groupService.getMyGroups(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context, 'No groups yet', 'Join a study group to collaborate with peers', Icons.groups);
        }

        return ListView.separated(
          padding: AppSpacing.paddingLg,
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = snapshot.data![index];
            return GroupCard(
              group: group,
              onTap: () => context.push('/group/${group.id}'),
            );
          },
        );
      },
    );
  }

  Widget _buildBrowseGroups() {
    return FutureBuilder<List<StudyGroup>>(
      future: _groupService.getAllGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(context, 'No groups available', 'Be the first to create a study group', Icons.group_add);
        }

        return ListView.separated(
          padding: AppSpacing.paddingLg,
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = snapshot.data![index];
            return GroupCard(
              group: group,
              onTap: () => context.push('/group/${group.id}'),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(title, style: context.textStyles.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(subtitle, style: context.textStyles.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
