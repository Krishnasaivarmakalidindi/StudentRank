import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:studentrank/nav.dart'; // Removed
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/services/validation_service.dart';
import 'package:studentrank/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  // State
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _rememberMe = false;
  String _educationLevel = 'Undergraduate';
  String? _selectedCollege;
  bool _acceptedTerms = false;
  bool _localLoading = false; // Local loading state for better control

  // Errors
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  // Predefined Lists
  final List<String> _colleges = [
    'IIT Bombay',
    'IIT Delhi',
    'IIT Madras',
    'IIT Kanpur',
    'IIT Kharagpur',
    'BITS Pilani',
    'NIT Trichy',
    'Anna University',
    'Delhi University',
    'VIT Vellore',
    'Manipal Institute of Technology',
    'SRM University',
    'Demo University',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Clear errors on edit
    _emailController.addListener(() {
      if (_emailError != null || _generalError != null) {
        setState(() {
          _emailError = null;
          _generalError = null;
        });
      }
    });
    _passwordController.addListener(() {
      if (_passwordError != null || _generalError != null) {
        setState(() {
          _passwordError = null;
          _generalError = null;
        });
      }
      setState(() {}); // For strength meter
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final isSignUp = _tabController.index == 1;

    if (isSignUp) {
      if (!_acceptedTerms) {
        setState(() => _generalError = 'Please accept the Terms & Conditions');
        return;
      }
      if (_selectedCollege == null) {
        setState(() => _generalError = 'Please select your college');
        return;
      }
    }

    setState(() => _localLoading = true);
    final provider = context.read<AppProvider>();

    try {
      if (isSignUp) {
        await provider.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      } else {
        await provider.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      // Explicit navigation handled by AuthGate
      // if (mounted) {
      //   context.go(AppRoutes.main);
      // }
    } catch (e) {
      if (!mounted) return;
      setState(() => _localLoading = false);
      _handleAuthError(e);
    }
  }

  void _handleAuthError(dynamic e) {
    String msg = e.toString();
    String? emailErr;
    String? passErr;
    String? genErr;

    // Map Firebase auth errors to user friendly messages
    if (msg.contains('wrong-password') ||
        msg.contains('INVALID_LOGIN_CREDENTIALS')) {
      // Show generic error for security, or specific if preferred.
      // User asked for "Incorrect email or password" on SAME page.
      // Usually better to attach to fields or show a banner.
      // I'll attach to password field for bad password.
      passErr = 'Incorrect email or password';
      emailErr = ' '; // Mark email as error too visually
    } else if (msg.contains('user-not-found') ||
        msg.contains('EMAIL_NOT_FOUND')) {
      emailErr = 'No account found with this email';
      passErr = ' ';
    } else if (msg.contains('invalid-email')) {
      emailErr = 'Please enter a valid email address';
    } else if (msg.contains('email-already-in-use')) {
      emailErr = 'Email is already registered';
    } else if (msg.contains('network-request-failed')) {
      genErr = 'Connection failed. Please check your internet.';
    } else {
      genErr = msg.replaceAll(RegExp(r'\[.*?\]'), '').trim();
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
      _generalError = genErr;
    });
  }

  void _handleGoogleSignIn() async {
    setState(() => _localLoading = true);
    try {
      await context.read<AppProvider>().signInWithGoogle();
      // AuthGate handles navigation
      // if (mounted) context.go(AppRoutes.main);
    } catch (e) {
      if (mounted) {
        setState(() => _localLoading = false);
        _handleAuthError(e);
      }
    }
  }

  void _showGuestDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Continue as Guest',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _educationLevel,
              decoration: const InputDecoration(
                labelText: 'Education Level',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: ['School', 'Undergraduate', 'Postgraduate', 'Other']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _educationLevel = val!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) return;
                Navigator.pop(context);
                setState(() => _localLoading = true);
                try {
                  await context.read<AppProvider>().signInAnonymously(
                        _nameController.text.trim(),
                        _educationLevel,
                      );
                  // AuthGate handles navigation
                  // if (mounted) context.go(AppRoutes.main);
                } catch (e) {
                  if (context.mounted) {
                    setState(() => _localLoading = false);
                    _handleAuthError(e);
                  }
                }
              },
              child: const Text('Start Exploring'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSignUp = _tabController.index == 1;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    const Icon(
                      Icons.school_rounded,
                      size: 64,
                      color: LightModeColors.lightPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'StudentRank',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your academic journey starts here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Auth Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TabBar(
                                controller: _tabController,
                                labelColor: theme.colorScheme.primary,
                                unselectedLabelColor:
                                    theme.colorScheme.onSurfaceVariant,
                                indicatorColor: theme.colorScheme.primary,
                                dividerColor: Colors.transparent,
                                onTap: (_) => setState(() {
                                  _generalError = null;
                                  _emailError = null;
                                  _passwordError = null;
                                }),
                                tabs: const [
                                  Tab(text: 'Sign In'),
                                  Tab(text: 'Sign Up'),
                                ],
                              ),
                              const SizedBox(height: 24),

                              if (_generalError != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: theme.colorScheme.error,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(_generalError!,
                                              style: TextStyle(
                                                  color: theme
                                                      .colorScheme.error))),
                                    ],
                                  ),
                                ),

                              // FIELDS
                              if (isSignUp) ...[
                                TextFormField(
                                  controller: _nameController,
                                  validator: ValidationService.validateName,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(Icons.person_outline),
                                    hintText: 'Letters only, 2-50 chars',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedCollege,
                                  decoration: const InputDecoration(
                                    labelText: 'College/University',
                                    prefixIcon:
                                        Icon(Icons.account_balance_outlined),
                                  ),
                                  items: _colleges
                                      .map((c) => DropdownMenuItem(
                                          value: c, child: Text(c)))
                                      .toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedCollege = val),
                                ),
                                const SizedBox(height: 16),
                              ],

                              TextFormField(
                                controller: _emailController,
                                validator: ValidationService.validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  errorText: _emailError,
                                  // Show checkmark only if valid and no error
                                  suffixIcon:
                                      _emailController.text.isNotEmpty &&
                                              _emailError == null &&
                                              ValidationService.validateEmail(
                                                      _emailController.text) ==
                                                  null
                                          ? const Icon(Icons.check_circle,
                                              color: Colors.green)
                                          : null,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _passwordController,
                                validator: ValidationService.validatePassword,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setState(() =>
                                        _isPasswordVisible =
                                            !_isPasswordVisible),
                                  ),
                                  errorText: _passwordError,
                                ),
                              ),

                              if (!isSignUp) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (v) => setState(
                                              () => _rememberMe = v ?? false),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Text('Remember me',
                                            style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Forgot Password feature coming soon!')));
                                      },
                                      child: const Text('Forgot Password?'),
                                    ),
                                  ],
                                ),
                              ],

                              if (isSignUp) ...[
                                const SizedBox(height: 8),
                                _PasswordStrengthMeter(
                                    password: _passwordController.text),
                              ],

                              const SizedBox(height: 16),

                              if (isSignUp) ...[
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  validator: (val) {
                                    if (val != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                  obscureText: !_isConfirmPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(_isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () => setState(() =>
                                          _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CheckboxListTile(
                                  value: _acceptedTerms,
                                  onChanged: (val) => setState(
                                      () => _acceptedTerms = val ?? false),
                                  title: const Text(
                                      'I accept the Terms & Conditions',
                                      style: TextStyle(fontSize: 12)),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _submit, // Loading handled by overlay
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                      isSignUp ? 'Create Account' : 'Sign In'),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Google Sign In - kept but improved
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _handleGoogleSignIn,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                        color: theme.colorScheme.outline),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.g_mobiledata,
                                          size: 28,
                                          color: theme.colorScheme.onSurface),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Demo & Guest Buttons
                    TextButton(
                      onPressed: _showGuestDialog,
                      child: const Text('Continue as Guest'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_localLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Signing in...', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const _PasswordStrengthMeter({required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = ValidationService.getPasswordStrength(password);

    Color color = Colors.red;
    String label = 'Weak';

    if (strength > 0.6) {
      color = Colors.green;
      label = 'Strong';
    } else if (strength > 0.3) {
      color = Colors.orange;
      label = 'Medium';
    }

    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                color: color,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Min 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
