import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studentrank/models/resource.dart';
import 'package:studentrank/services/resource_service.dart';
import 'package:studentrank/services/user_service.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/resource_card.dart';
import 'package:studentrank/widgets/student_rank_app_bar.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ResourceService _resourceService = ResourceService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  
  String? _selectedSubject;
  String _selectedSort = 'Most Popular';
  
  final List<String> _subjects = ['All', 'Physics', 'Computer Science', 'Mathematics', 'Databases', 'Web Development'];
  final List<String> _sortOptions = ['Most Popular', 'Recent', 'Highest Rated', 'Most Downloaded'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentRankAppBar(title: 'Explore'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search resources (e.g., Quantum, React)...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filters & Sort Row
                  Row(
                    children: [
                       Expanded(
                         child: SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _subjects.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final subject = _subjects[index];
                              final isSelected = _selectedSubject == subject || (_selectedSubject == null && subject == 'All');
                              
                              return FilterChip(
                                label: Text(subject),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedSubject = subject == 'All' ? null : subject;
                                  });
                                },
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                                labelStyle: context.textStyles.labelMedium?.semiBold.copyWith(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              );
                            },
                          ),
                      ),
                       ),
                       const SizedBox(width: 8),
                       // Sort Dropdown (Small)
                       MenuAnchor(
                         builder: (context, controller, child) {
                           return IconButton(
                             onPressed: () {
                               if (controller.isOpen) {
                                 controller.close();
                               } else {
                                 controller.open();
                               }
                             },
                             icon: const Icon(Icons.sort),
                             tooltip: 'Sort by',
                           );
                         },
                         menuChildren: _sortOptions.map((option) {
                           return MenuItemButton(
                             onPressed: () => setState(() => _selectedSort = option),
                             child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 if (_selectedSort == option) const Icon(Icons.check, size: 16),
                                 if (_selectedSort == option) const SizedBox(width: 8),
                                 Text(option),
                               ],
                             ),
                           );
                         }).toList(),
                       ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                   setState(() {});
                },
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                        future: _userService.getTopContributors(subject: _selectedSubject, limit: 5),
                        builder: (context, snapshot) {
                          // Show minimal skeleton or mock if no data
                          // Since UserService might return empty list initially, we can show nothing or a placeholder
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            // If empty, we can skip or show placeholders if we want to encourage users
                            return const SizedBox.shrink(); 
                          }
                
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Top Contributors', style: context.textStyles.titleLarge?.semiBold),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 110, // Increased height for stats
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final contributor = snapshot.data![index];
                                    return InkWell(
                                      onTap: () {
                                          // Navigate to public profile if implemented
                                          // context.push('/profile/${contributor.id}');
                                      },
                                      child: Container(
                                        width: 90,
                                        padding: AppSpacing.paddingSm,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                              backgroundImage: contributor.profileImageUrl != null ? NetworkImage(contributor.profileImageUrl!) : null,
                                              child: contributor.profileImageUrl == null 
                                                  ? Text(contributor.name.substring(0, 1), style: context.textStyles.titleMedium?.bold.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer))
                                                  : null,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                                contributor.name.split(' ').first, 
                                                style: context.textStyles.labelSmall?.semiBold, 
                                                maxLines: 1, 
                                                overflow: TextOverflow.ellipsis, 
                                                textAlign: TextAlign.center
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                                '${contributor.reputationScore} Rep', 
                                                style: context.textStyles.labelSmall?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.primary), 
                                                maxLines: 1, 
                                                overflow: TextOverflow.ellipsis
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          );
                        },
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Resources', style: context.textStyles.titleLarge?.semiBold),
                          Text('$_selectedSort', style: context.textStyles.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      FutureBuilder<List<Resource>>(
                        future: _getResources(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildEmptyState(context);
                          }
                          
                          // Sort client-side based on _selectedSort
                          // (Wait, logic in getResources uses backend sort for trending but here we might want to override)
                          final resources = snapshot.data!;
                          _sortResources(resources);
                
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: resources.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final resource = resources[index];
                              return ResourceCard(
                                resource: resource,
                                onTap: () => context.push('/resource/${resource.id}'),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Resource>> _getResources() async {
    if (_searchController.text.isNotEmpty) {
      return _resourceService.searchResources(_searchController.text);
    } else if (_selectedSubject != null) {
      return _resourceService.getResourcesBySubject(_selectedSubject!);
    } else {
      return _resourceService.getTrendingResources(limit: 20);
    }
  }
  
  void _sortResources(List<Resource> resources) {
    switch (_selectedSort) {
      case 'Most Popular':
        resources.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'Recent':
        resources.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Highest Rated':
        resources.sort((a, b) => b.qualityRating.compareTo(a.qualityRating));
        break;
      case 'Most Downloaded':
        resources.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
        break;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No resources found', style: context.textStyles.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Try adjusting your search or filters', style: context.textStyles.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
