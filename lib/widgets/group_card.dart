import 'package:flutter/material.dart';
import 'package:studentrank/models/study_group.dart';
import 'package:studentrank/theme.dart';

class GroupCard extends StatelessWidget {
  final StudyGroup group;
  final VoidCallback onTap;
  final bool isMember;
  final VoidCallback? onJoin;

  const GroupCard({
    super.key, 
    required this.group, 
    required this.onTap,
    this.isMember = false,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Controlled by parent
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.groups, 
                      size: 24, 
                      color: Theme.of(context).colorScheme.onPrimaryContainer
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name, 
                          style: context.textStyles.titleMedium?.semiBold, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group.category, 
                          style: context.textStyles.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isMember)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Joined',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (onJoin != null)
                    ElevatedButton(
                      onPressed: onJoin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Join'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                group.description, 
                style: context.textStyles.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ), 
                maxLines: 2, 
                overflow: TextOverflow.ellipsis
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people_outline, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${group.memberCount} members', 
                    style: context.textStyles.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant
                    )
                  ),
                  const Spacer(),
                  if (group.resourceIds.isNotEmpty) ...[
                    Icon(Icons.description_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${group.resourceIds.length} resources', 
                      style: context.textStyles.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant
                      )
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
