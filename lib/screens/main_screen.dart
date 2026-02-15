import 'package:flutter/material.dart';
import 'package:studentrank/screens/home_screen.dart';
import 'package:studentrank/screens/explore_screen.dart';
import 'package:studentrank/screens/contribute_screen.dart';
import 'package:studentrank/screens/groups_screen.dart';
import 'package:studentrank/screens/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    ContributeScreen(),
    GroupsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: Container(
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => setState(() => _currentIndex = 2),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 80, // Restore fixed height to ensure enough space
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero, // Remove default padding to prevent overflow
        color: Theme.of(context)
            .scaffoldBackgroundColor, // Blend with background or slightly lighter
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.explore_rounded, 'Explore'),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(
                      height: 38), // Reduced to clear FAB but save space
                  Text(
                    'Contribute',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              _buildNavItem(3, Icons.groups_rounded, 'Groups'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 8.0, vertical: 4.0), // Reduced vertical padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24), // Reduced icon size
            const SizedBox(height: 2), // Reduced gap
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
