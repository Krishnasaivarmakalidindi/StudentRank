import 'package:flutter/material.dart';
import 'package:studentrank/models/resource.dart';
import 'package:studentrank/theme.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback onTap;

  const ResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(resource.subject, style: context.textStyles.labelSmall?.semiBold.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                  ),
                  const Spacer(),
                  Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(resource.qualityRating.toStringAsFixed(1), style: context.textStyles.labelSmall?.semiBold),
                ],
              ),
              const SizedBox(height: 12),
              Text(resource.title, style: context.textStyles.titleMedium?.semiBold, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text(resource.description, style: context.textStyles.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(resource.authorName, style: context.textStyles.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const Spacer(),
                  Icon(Icons.visibility_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${resource.viewCount}', style: context.textStyles.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(width: 12),
                  Icon(Icons.trending_up, size: 14, color: Theme.of(context).colorScheme.tertiary),
                  const SizedBox(width: 4),
                  Text('+${resource.reputationImpact}', style: context.textStyles.labelSmall?.semiBold.copyWith(color: Theme.of(context).colorScheme.tertiary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
