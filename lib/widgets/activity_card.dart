import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:studentrank/models/activity.dart';
import 'package:studentrank/theme.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final iconData = _getActivityIcon();
    final accentColor = _getActivityColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.lightCardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? accentColor.withOpacity(0.2)
                  : accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 20, color: accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRichTitle(context, accentColor),
                const SizedBox(height: 4),
                Text(
                  _getTimeAgo(activity.createdAt),
                  style: GoogleFonts.inter(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichTitle(BuildContext context, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;

    // Basic logic to bold specific parts based on activity type
    // This replicates "Earned +20 points for Note Upload" style

    if (activity.type == ActivityType.upload) {
      return RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
              color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
          children: [
            const TextSpan(text: 'Earned '),
            TextSpan(
                text: '+${activity.reputationChange} points',
                style: TextStyle(
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    fontWeight: FontWeight.bold)),
            const TextSpan(text: ' for Note Upload'),
          ],
        ),
      );
    }

    // Default fallback
    return Text(
      activity.title,
      style: GoogleFonts.inter(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  IconData _getActivityIcon() {
    switch (activity.type) {
      case ActivityType.upload:
        return Icons.add_circle_outline;
      case ActivityType.improve:
        return Icons.chat_bubble_outline;
      case ActivityType.answer:
        return Icons.question_answer;
      case ActivityType.achievement:
        return Icons.star_border; // Yellow star
      case ActivityType.join:
        return Icons.group_add;
    }
  }

  Color _getActivityColor() {
    switch (activity.type) {
      case ActivityType.upload:
        return AppColors.primaryLight; // Blue
      case ActivityType.improve:
        return AppColors.accentPurple; // Purple
      case ActivityType.answer:
        return AppColors.accentGreen;
      case ActivityType.achievement:
        return AppColors.accentOrange; // Gold/Yellow
      case ActivityType.join:
        return AppColors.accentCyan;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inHours < 24) {
      if (diff.inHours == 0) return '${diff.inMinutes} minutes ago';
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }
}
