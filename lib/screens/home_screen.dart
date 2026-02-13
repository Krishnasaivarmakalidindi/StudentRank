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
      backgroundColor: AppColors.deepNavy,
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
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    text: 'Your next achievement is within reach! ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.w500,
                    ),
                    children: const [
                      TextSpan(text: '🚀'),
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
                  'Rank Faster',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                      subLabel: 'Claim +50 Points',
                      subLabelColor: AppColors.accentGreen,
                      iconBgColor: AppColors.primary.withOpacity(0.2), // Blue
                      iconColor: AppColors.primary,
                      onTap: () => context.go('/contribute'),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.groups_rounded,
                      label: 'Collab Now',
                      subLabel: '12 peers online',
                      subLabelColor: AppColors.textSecondary,
                      iconBgColor: AppColors.accentPurple.withOpacity(0.2),
                      iconColor: AppColors.accentPurple,
                      onTap: () => context.go('/groups'),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.emoji_events_rounded,
                      label: 'Boost Your Score',
                      subLabel: '2x Multiplier Active',
                      subLabelColor: AppColors.accentOrange,
                      iconBgColor: AppColors.accentOrange.withOpacity(0.2),
                      iconColor: AppColors.accentOrange,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Multipliers coming soon!')),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.auto_awesome,
                      label: 'Smart Help',
                      subLabel: 'Solve instantly',
                      subLabelColor: AppColors.textSecondary,
                      iconBgColor: AppColors.accentGreen.withOpacity(0.2),
                      iconColor: AppColors.accentGreen,
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
                      'Your Progress',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/profile'),
                      child: Text(
                        'View History',
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
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 28), // Filled icon
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.deepNavy, width: 2), // Ring effect
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
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
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
                  color: Colors.white,
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
            Icon(Icons.history, size: 48, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 12),
            Text(
              'No recent activity',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
