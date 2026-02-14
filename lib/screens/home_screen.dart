import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/services/activity_service.dart';
import 'package:studentrank/theme.dart';
import 'package:studentrank/widgets/reputation_card.dart';
import 'package:studentrank/widgets/activity_card.dart';

// import 'package:studentrank/models/activity.dart'; // duplicate removed

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActivityService _activityService = ActivityService();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider for user data
    final appProvider = context.watch<AppProvider>();
    final user = appProvider.currentUser;

    // Loading State
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.deepNavy,
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await appProvider.refreshUser();
          },
          color: AppColors.primary,
          backgroundColor: AppColors.cardSurface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                _buildHeader(context, user),

                const SizedBox(height: 32),

                // 2. Greeting
                Text(
                  '${_getGreeting()},\n${user.name.split(' ').first}',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text: Theme.of(context).brightness == Brightness.dark
                        ? 'Your next achievement is within reach! '
                        : 'Ready to boost your rank today? ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.accentCyan
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      if (Theme.of(context).brightness == Brightness.dark)
                        const TextSpan(text: '🚀'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 3. Reputation Card
                ReputationCard(
                  reputationScore: user.reputationScore,
                  rank: user.collegeRank,
                  level: user.level,
                  subject: user.subjects.isNotEmpty
                      ? user.subjects.first
                      : 'General',
                ),

                const SizedBox(height: 32),

                // 4. Rank Faster Grid
                Text(
                  Theme.of(context).brightness == Brightness.dark
                      ? 'Rank Faster'
                      : 'Quick Actions',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16, // Increased spacing
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1, // Adjusted for content
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.upload_file_rounded,
                      label: 'Upload Notes',
                      subLabel: Theme.of(context).brightness == Brightness.dark
                          ? 'Claim +50 Points'
                          : 'Share knowledge',
                      subLabelColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.accentGreen
                              : AppColors.lightTextSecondary,
                      iconBgColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : Colors.blue.shade50,
                      iconColor: AppColors.primary,
                      onTap: () => context.go('/contribute'),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.groups_rounded,
                      label: Theme.of(context).brightness == Brightness.dark
                          ? 'Collab Now'
                          : 'Study Groups',
                      subLabel: Theme.of(context).brightness == Brightness.dark
                          ? '12 peers online'
                          : 'Join classmates',
                      subLabelColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary,
                      iconBgColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.accentPurple.withValues(alpha: 0.2)
                              : Colors.orange.shade50,
                      iconColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.accentPurple
                          : Colors.orange.shade800,
                      onTap: () => context.go('/groups'),
                    ),
                    _buildActionCard(
                      context,
                      icon: Theme.of(context).brightness == Brightness.dark
                          ? Icons.emoji_events_rounded
                          : Icons.quiz,
                      label: Theme.of(context).brightness == Brightness.dark
                          ? 'Boost Your Score'
                          : 'Daily Quiz',
                      subLabel: Theme.of(context).brightness == Brightness.dark
                          ? '2x Multiplier Active'
                          : 'Keep the streak',
                      subLabelColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.accentOrange
                              : AppColors.lightTextSecondary,
                      iconBgColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.accentOrange.withValues(alpha: 0.2)
                              : Colors.green.shade50,
                      iconColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.accentOrange
                          : Colors.green.shade700,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quizzes coming soon!')),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Theme.of(context).brightness == Brightness.dark
                          ? Icons.auto_awesome
                          : Icons.smart_toy,
                      label: Theme.of(context).brightness == Brightness.dark
                          ? 'Smart Help'
                          : 'Ask AI',
                      subLabel: Theme.of(context).brightness == Brightness.dark
                          ? 'Solve instantly'
                          : 'Instant answers',
                      subLabelColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondary
                              : Colors.white.withValues(alpha: 0.9),
                      iconBgColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.accentGreen.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.2),
                      iconColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.accentGreen
                          : Colors.white,
                      isPrimaryCard:
                          Theme.of(context).brightness == Brightness.light,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('AI Help coming soon!')),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 5. Activity Feed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'Your Progress'
                          : 'Recent Activity',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/profile'),
                      child: Text(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'View History'
                            : 'See all',
                        style: GoogleFonts.inter(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder(
                  future: _activityService.getFeedActivities(limit: 5),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          ActivityCard(activity: snapshot.data![index]),
                    );
                  },
                ),
                // Extra padding for bottom nav
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primary, // Blue background for logo
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.school_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          'StudentRank',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  size: 28), // Filled icon
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.error
                      : AppColors.primary, // Red/Blue dot
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2), // Ring effect
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => context.go('/profile'),
          borderRadius: BorderRadius.circular(20),
          child: CircleAvatar(
            radius: 20,
            backgroundColor:
                const Color(0xFFFFCC80), // Peach/Skin tone avatar bg usually
            child: const Icon(Icons.person,
                color: Colors.black, size: 24), // Simple avatar for now
            // In real app, use user.profileImageUrl or Initials
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subLabel,
    required Color subLabelColor,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
    bool isPrimaryCard = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPrimaryCard
                ? AppColors.primary
                : (isDark ? AppColors.cardSurface : Colors.white),
            borderRadius: BorderRadius.circular(24),
            border: isDark
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.05), width: 1)
                : null,
            boxShadow: isDark || isPrimaryCard
                ? null
                : [
                    BoxShadow(
                      color: AppColors.lightCardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius:
                      BorderRadius.circular(16), // Rounded square/circle hybrid
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isPrimaryCard
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subLabel,
                style: GoogleFonts.inter(
                  color: subLabelColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history,
                size: 48, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(
              'No recent activity',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
