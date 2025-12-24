import 'package:flutter/material.dart';
import 'package:studentrank/theme.dart';

class ReputationCard extends StatelessWidget {
  final int reputationScore;
  final int rank;
  final int level;
  final String subject;

  const ReputationCard({
    super.key,
    required this.reputationScore,
    required this.rank,
    required this.level,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress();
    final nextLevelPoints = _getNextLevelPoints();

    return Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reputation', style: context.textStyles.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('$reputationScore', style: context.textStyles.headlineLarge?.semiBold.copyWith(color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, size: 18, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      const SizedBox(width: 6),
                      Text('Level $level', style: context.textStyles.labelLarge?.semiBold.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('College Rank', style: context.textStyles.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('#$rank', style: context.textStyles.titleLarge?.bold),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Subject', style: context.textStyles.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(subject, style: context.textStyles.titleMedium?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Next Level', style: context.textStyles.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    Text('$reputationScore / $nextLevelPoints', style: context.textStyles.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.tertiary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateProgress() {
    final currentLevelMin = _getLevelMinPoints(level);
    final nextLevelMin = _getNextLevelPoints();
    final levelRange = nextLevelMin - currentLevelMin;
    final currentProgress = reputationScore - currentLevelMin;
    return (currentProgress / levelRange).clamp(0.0, 1.0);
  }

  int _getLevelMinPoints(int lvl) {
    const levelPoints = [0, 500, 1000, 2000, 3500, 5500, 8000];
    if (lvl >= 1 && lvl <= levelPoints.length) return levelPoints[lvl - 1];
    return 0;
  }

  int _getNextLevelPoints() {
    const levelPoints = [500, 1000, 2000, 3500, 5500, 8000, 12000];
    if (level >= 1 && level <= levelPoints.length) return levelPoints[level - 1];
    return 12000;
  }
}
