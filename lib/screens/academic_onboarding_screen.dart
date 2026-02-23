import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/models/campus.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/services/campus_service.dart';

class AcademicOnboardingScreen extends StatefulWidget {
  const AcademicOnboardingScreen({super.key});

  @override
  State<AcademicOnboardingScreen> createState() =>
      _AcademicOnboardingScreenState();
}

class _AcademicOnboardingScreenState extends State<AcademicOnboardingScreen>
    with SingleTickerProviderStateMixin {
  final CampusService _campusService = CampusService();
  final _formKey = GlobalKey<FormState>();

  // State
  List<Campus> _campuses = [];
  bool _isLoadingCampuses = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Form values
  Campus? _selectedCampus;
  String? _selectedBranch;
  int? _selectedYear;
  int? _selectedSemester;

  // Options
  static const List<String> _branches = [
    'CSE',
    'CSE (AIML)',
    'CSE (Data Science)',
    'CSE (Cyber Security)',
    'CSE (IoT)',
    'CSE (Full Stack)',
    'AIML',
    'IT',
    'ECE',
    'EEE',
    'ME',
    'CE',
    'BT',
    'Other',
  ];

  static const List<int> _years = [1, 2, 3, 4];
  static const List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
    _loadCampuses();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCampuses() async {
    try {
      final campuses = await _campusService.getActiveCampuses();
      if (campuses.isEmpty) {
        // No campuses in Firestore — seed them
        await _campusService.seedCampuses();
        _campusService.clearCache();
        final seeded = await _campusService.getActiveCampuses();
        setState(() {
          _campuses = seeded;
          _isLoadingCampuses = false;
        });
      } else {
        setState(() {
          _campuses = campuses;
          _isLoadingCampuses = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingCampuses = false;
        _errorMessage = 'Failed to load campuses. Please try again.';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCampus == null ||
        _selectedBranch == null ||
        _selectedYear == null ||
        _selectedSemester == null) {
      setState(() => _errorMessage = 'Please fill in all fields to continue.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<AppProvider>().completeOnboarding(
            campusId: _selectedCampus!.id,
            branch: _selectedBranch!,
            year: _selectedYear!,
            semester: _selectedSemester!,
          );
      // Navigation handled by AuthGate
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.06),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoadingCampuses ? _buildLoading(theme) : _buildForm(theme),
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Loading campuses...',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Header
                _buildStepIndicator(theme),
                const SizedBox(height: 24),

                // Greeting
                Consumer<AppProvider>(
                  builder: (context, provider, _) {
                    final name = provider.currentUser?.name ?? 'Student';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $name! 👋',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete your academic profile to get started. '
                          'This helps us personalize your experience and enable campus leaderboards.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Error
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: theme.colorScheme.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Campus Dropdown
                _buildDropdownCard(
                  theme: theme,
                  icon: Icons.apartment_rounded,
                  label: 'NIAT Campus',
                  child: DropdownButtonFormField<Campus>(
                    initialValue: _selectedCampus,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    hint: Text('Select your campus',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant)),
                    validator: (val) =>
                        val == null ? 'Campus is required' : null,
                    items: _campuses
                        .map((campus) => DropdownMenuItem(
                              value: campus,
                              child: Text(
                                campus.name,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCampus = val),
                  ),
                ),
                const SizedBox(height: 16),

                // Branch Dropdown
                _buildDropdownCard(
                  theme: theme,
                  icon: Icons.account_tree_rounded,
                  label: 'Branch',
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedBranch,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    hint: Text('Select your branch',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant)),
                    validator: (val) =>
                        val == null ? 'Branch is required' : null,
                    items: _branches
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedBranch = val),
                  ),
                ),
                const SizedBox(height: 16),

                // Year & Semester Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownCard(
                        theme: theme,
                        icon: Icons.calendar_today_rounded,
                        label: 'Year',
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedYear,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          hint: Text('Year',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant)),
                          validator: (val) => val == null ? 'Required' : null,
                          items: _years
                              .map((y) => DropdownMenuItem(
                                  value: y, child: Text('Year $y')))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedYear = val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownCard(
                        theme: theme,
                        icon: Icons.view_timeline_rounded,
                        label: 'Semester',
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedSemester,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          hint: Text('Sem',
                              style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant)),
                          validator: (val) => val == null ? 'Required' : null,
                          items: _semesters
                              .map((s) => DropdownMenuItem(
                                  value: s, child: Text('Sem $s')))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedSemester = val),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      disabledBackgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Complete Setup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Academic identity can only be updated once every 30 days to maintain leaderboard integrity.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                'Academic Profile',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCard({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
