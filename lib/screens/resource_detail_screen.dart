import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:studentrank/models/resource.dart';
import 'package:studentrank/services/resource_service.dart';
import 'package:studentrank/theme.dart';

class ResourceDetailScreen extends StatefulWidget {
  final String resourceId;

  const ResourceDetailScreen({super.key, required this.resourceId});

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  final ResourceService _resourceService = ResourceService();

  @override
  void initState() {
    super.initState();
    _resourceService.incrementViewCount(widget.resourceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<Resource?>(
        future: _resourceService.getResourceById(widget.resourceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return _buildErrorState(context);
          }

          final resource = snapshot.data!;

          return SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(resource.subject, style: context.textStyles.labelMedium?.semiBold.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                ),
                const SizedBox(height: 16),
                Text(resource.title, style: context.textStyles.headlineSmall?.bold),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(resource.authorName.substring(0, 1), style: context.textStyles.titleMedium?.semiBold.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(resource.authorName, style: context.textStyles.titleSmall?.semiBold),
                          Text(DateFormat('MMM dd, yyyy').format(resource.createdAt), style: context.textStyles.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                          const SizedBox(width: 4),
                          Text(resource.qualityRating.toStringAsFixed(1), style: context.textStyles.labelMedium?.semiBold),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(context, Icons.visibility_outlined, '${resource.viewCount}', 'Views'),
                      Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outline),
                      _buildStat(context, Icons.download_outlined, '${resource.downloadCount}', 'Downloads'),
                      Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outline),
                      _buildStat(context, Icons.trending_up, '+${resource.reputationImpact}', 'Reputation'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Description', style: context.textStyles.titleMedium?.semiBold),
                const SizedBox(height: 12),
                Text(resource.description, style: context.textStyles.bodyMedium?.copyWith(height: 1.6)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Resource'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Improve feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Suggest Improvements'),
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
          Text('Resource not found', style: context.textStyles.titleMedium),
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
