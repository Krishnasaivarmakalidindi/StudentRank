import 'package:flutter/material.dart';
import 'package:studentrank/theme.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // Mock progress for visual match

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  AppColors.reputationGradientStart,
                  AppColors.reputationGradientEnd
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          isDark
              ? BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              : BoxShadow(
                  color: AppColors.lightCardShadow,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative glow/noise could go here

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Reputation',
                      style: GoogleFonts.inter(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.lightTextSecondary,
                        fontSize: 14,
                        fontWeight: isDark ? FontWeight.bold : FontWeight.w600,
                        letterSpacing: isDark ? 1.2 : 0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events,
                              color: isDark ? Colors.amber : AppColors.primary,
                              size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'SILVER II', // Screenshot says SILVER III, sticking to mock
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Big Score
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '1,250',
                      style: GoogleFonts.outfit(
                        color:
                            isDark ? Colors.white : AppColors.lightTextPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PTS',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Progress Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress to Gold I',
                      style: GoogleFonts.inter(
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '1,250 / 1,500',
                      style: GoogleFonts.inter(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : AppColors.lightTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : AppColors.neutral200,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Container(
                      height: 10,
                      width: MediaQuery.of(context).size.width *
                          0.6, // 85% width approx
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : AppColors.primary,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 6)
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  '250 pts to reach your next milestone',
                  style: GoogleFonts.inter(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 24),

                // Footer / Button (Button only in Light Mode per screenshot, or Footer in Dark)
                if (isDark)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SEASON PROGRESS',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.accentGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+12% this week',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Ranking Details',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward,
                              color: AppColors.primary, size: 16),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
