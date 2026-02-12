import 'package:flutter/material.dart';

class StudentRankAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogo;
  final List<Widget>? actions;
  final Widget? bottom;
  final double? bottomHeight;
  final String? subtitle;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const StudentRankAppBar({
    super.key,
    required this.title,
    this.showLogo = true,
    this.actions,
    this.bottom,
    this.bottomHeight,
    this.subtitle,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      centerTitle: false,
      titleSpacing: 16,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            Icon(
              Icons.school_rounded,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: actions,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight ?? 48),
              child: bottom!,
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottomHeight ?? (bottom != null ? 48 : 0)));
}
