import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studentrank/models/activity.dart';
import 'package:studentrank/theme.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final icon = _getActivityIcon();
    final color = _getActivityColor(context);

    return Container(
      padding: AppSpacing.paddingMd,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: context.textStyles.titleSmall?.semiBold, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(activity.description, style: context.textStyles.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (activity.reputationChange > 0) ...[
                      Icon(Icons.trending_up, size: 14, color: Theme.of(context).colorScheme.tertiary),
                      const SizedBox(width: 4),
                      Text('+${activity.reputationChange}', style: context.textStyles.labelSmall?.semiBold.copyWith(color: Theme.of(context).colorScheme.tertiary)),
                      const SizedBox(width: 12),
                    ],
                    Text(DateFormat('MMM dd, yyyy').format(activity.createdAt), style: context.textStyles.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon() {
    switch (activity.type) {
      case ActivityType.upload:
        return Icons.upload_file;
      case ActivityType.improve:
        return Icons.edit;
      case ActivityType.answer:
        return Icons.question_answer;
      case ActivityType.achievement:
        return Icons.emoji_events;
      case ActivityType.join:
        return Icons.group_add;
    }
  }

  Color _getActivityColor(BuildContext context) {
    switch (activity.type) {
      case ActivityType.upload:
        return Theme.of(context).colorScheme.primary;
      case ActivityType.improve:
        return Colors.orange.shade700;
      case ActivityType.answer:
        return Colors.blue.shade600;
      case ActivityType.achievement:
        return Theme.of(context).colorScheme.tertiary;
      case ActivityType.join:
        return Colors.purple.shade600;
    }
  }
}
