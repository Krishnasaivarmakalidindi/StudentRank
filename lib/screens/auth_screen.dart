import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _educationLevelController = TextEditingController();
  
  bool _isPasswordVisible = false;
  String _educationLevel = 'Undergraduate'; // Default

  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Clear errors on edit
    _emailController.addListener(() {
      if (_emailError != null) setState(() => _emailError = null);
    });
    _passwordController.addListener(() {
      if (_passwordError != null) setState(() => _passwordError = null);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _educationLevelController.dispose();
    super.dispose();
  }

  void _submit() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final isLogin = _tabController.index == 0;

    try {
      if (isLogin) {
        await provider.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await provider.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      }
      
      // Navigation is handled by AppRouter listening to auth changes
    } catch (e) {
      if (!mounted) return;
      
      String msg = e.toString();
      String? emailErr;
      String? passErr;
      String? generalErr;

      // Map Firebase Auth errors
      if (msg.contains('wrong-password') || msg.contains('INVALID_LOGIN_CREDENTIALS')) {
        passErr = 'Incorrect password. Please try again.';
      } else if (msg.contains('user-not-found') || msg.contains('EMAIL_NOT_FOUND')) {
        emailErr = 'No account found with this email.';
      } else if (msg.contains('invalid-email')) {
        emailErr = 'Please enter a valid email address.';
      } else if (msg.contains('email-already-in-use')) {
        emailErr = 'Email is already registered.';
      } else if (msg.contains('network-request-failed')) {
        generalErr = 'Something went wrong. Check your connection.';
      } else {
        // Fallback cleanup of the error message
        generalErr = msg.replaceAll(RegExp(r'\[.*?\]'), '').trim();
      }

      setState(() {
        _emailError = emailErr;
        _passwordError = passErr;
      });

      if (generalErr != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(generalErr),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _continueAsDemo() async {
    try {
      await context.read<AppProvider>().createDemoUser();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create demo user: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _handleGoogleSignIn() async {
    try {
      await context.read<AppProvider>().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
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
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _educationLevel,
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
                
                Navigator.pop(context); // Close dialog
                try {
                  await context.read<AppProvider>().signInAnonymously(
                    _nameController.text.trim(),
                    _educationLevel,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Guest login failed: $e')),
                    );
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
    final isLoading = context.watch<AppProvider>().isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
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
                const SizedBox(height: 48),

                // Auth Form Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
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
                            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                            indicatorColor: theme.colorScheme.primary,
                            dividerColor: Colors.transparent,
                            onTap: (_) => setState(() {}),
                            tabs: const [
                              Tab(text: 'Sign In'),
                              Tab(text: 'Sign Up'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          if (_tabController.index == 1) ...[
                            TextFormField(
                              controller: _nameController,
                              validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _emailController,
                            validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              errorText: _emailError,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                              errorText: _passwordError,
                            ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Text(_tabController.index == 0 ? 'Sign In' : 'Create Account'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          /*
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: isLoading ? null : _handleGoogleSignIn,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: theme.colorScheme.outline),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.g_mobiledata, size: 28, color: theme.colorScheme.onSurface),
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
                          */
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: theme.colorScheme.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: theme.colorScheme.outline)),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Demo & Guest Buttons
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _continueAsDemo,
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Continue with Demo Account'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isLoading ? null : _showGuestDialog,
                  child: const Text('Continue as Guest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
