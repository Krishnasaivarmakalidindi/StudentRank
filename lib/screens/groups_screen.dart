import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/models/study_group.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/services/group_service.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/group_card.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  final GroupService _groupService = GroupService();
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategory;
  bool _isCreating = false;

  final List<String> _categories = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Electrical Engineering',
    'Emerging Tech',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _joinGroup(String groupId) async {
    try {
      await _groupService.joinGroup(groupId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined group!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join group: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    setState(() => _isCreating = true);

    try {
      final groupId = await _groupService.createGroup(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory!,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close dialog

      _nameController.clear();
      _descController.clear();
      setState(() {
        _selectedCategory = null;
        _isCreating = false;
      });

      _tabController.animateTo(0); // Go to My Groups

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isCreating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create group: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Group'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'e.g., Web Dev Beginners',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      hintText: 'Select category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'What is this group about?',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isCreating ? null : _createGroup,
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final user = appProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const StudentRankAppBar(title: 'Groups'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.paddingLg,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.5)),
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
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  labelStyle: context.textStyles.labelLarge?.semiBold,
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(text: 'My Groups'),
                    Tab(text: 'Browse'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyGroups(user.id),
                  _buildBrowseGroups(user.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGroups(String userId) {
    return StreamBuilder<List<StudyGroup>>(
      stream: _groupService.getUserGroups(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            context,
            'No groups yet',
            'Browse groups and join one to get started',
            Icons.groups_2,
            action: ElevatedButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('Browse Groups'),
            ),
          );
        }

        return ListView.separated(
          padding: AppSpacing.paddingLg,
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final group = snapshot.data![index];
            return GroupCard(
              group: group,
              isMember: true,
              onTap: () => context.push('/group/${group.id}'),
            );
          },
        );
      },
    );
  }

  Widget _buildBrowseGroups(String userId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showCreateGroupDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create New Group'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<StudyGroup>>(
            stream: _groupService.getAllGroups(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(
                  context,
                  'No groups available',
                  'Be the first to create a study group',
                  Icons.group_add,
                );
              }

              return ListView.separated(
                padding: AppSpacing.paddingLg,
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final group = snapshot.data![index];
                  final isMember = group.members.contains(userId);

                  return GroupCard(
                    group: group,
                    isMember: isMember,
                    onTap: () => context.push('/group/${group.id}'),
                    onJoin: isMember ? null : () => _joinGroup(group.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
      BuildContext context, String title, String subtitle, IconData icon,
      {Widget? action}) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(title,
                style: context.textStyles.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: context.textStyles.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
