import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/models/study_group.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/services/study_group_service.dart';
import 'package:studentrank/theme.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final StudyGroupService _groupService = StudyGroupService();

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final user = appProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<StudyGroup?>(
        future: _groupService.getGroupById(widget.groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return _buildErrorState(context);
          }

          final group = snapshot.data!;
          final isMember = user != null && group.members.contains(user.id);

          return SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(Icons.groups, size: 64, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(group.name, style: context.textStyles.headlineSmall?.bold),
                    ),
                    if (group.isPrivate)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, size: 14),
                            const SizedBox(width: 4),
                            Text('Private', style: context.textStyles.labelSmall?.semiBold),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(group.subject, style: context.textStyles.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 16),
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(context, Icons.people, '${group.memberCount}', 'Members'),
                      Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outline),
                      _buildStat(context, Icons.description, '${group.resourceIds.length}', 'Resources'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('About', style: context.textStyles.titleMedium?.semiBold),
                const SizedBox(height: 12),
                Text(group.description, style: context.textStyles.bodyMedium?.copyWith(height: 1.6)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: isMember
                      ? OutlinedButton.icon(
                          onPressed: () async {
                            await _groupService.leaveGroup(group.id, user.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Left group')),
                            );
                            setState(() {});
                          },
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text('Leave Group'),
                        )
                      : ElevatedButton.icon(
                          onPressed: () async {
                            if (user == null) return;
                            await _groupService.joinGroup(group.id, user.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Joined group! +5 reputation')),
                            );
                            setState(() {});
                          },
                          icon: const Icon(Icons.group_add),
                          label: const Text('Join Group'),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(value, style: context.textStyles.titleMedium?.bold),
        const SizedBox(height: 4),
        Text(label, style: context.textStyles.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text('Group not found', style: context.textStyles.titleMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
