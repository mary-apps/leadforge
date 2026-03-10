import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/brutal_button.dart';
import '../../utils/haptics.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (_isSignUp && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    Haptics.light();

    try {
      if (_isSignUp) {
        await ref.read(authProvider.notifier).signUpWithEmail(email, password);
      } else {
        await ref.read(authProvider.notifier).signInWithEmail(email, password);
      }
      Haptics.medium();
    } catch (e) {
      Haptics.heavy();
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    Haptics.light();

    try {
      await ref.read(authProvider.notifier).signInWithApple();
      Haptics.medium();
    } catch (e) {
      Haptics.heavy();
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => _errorMessage = message);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Haptics.light();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email address'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    Haptics.medium();
    try {
      await ref.read(authProvider.notifier).resetPassword(email);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 8),
                const Text('Email Sent'),
              ],
            ),
            content: Text(
              'Password reset link sent to $email. Check your inbox.',
            ),
            actions: [
              AnimatedButton.primary(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Haptics.heavy();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildPillToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isSignUp) {
                  Haptics.light();
                  setState(() => _isSignUp = false);
                }
              },
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isSignUp ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: !_isSignUp
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                  boxShadow: !_isSignUp
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            offset: const Offset(2, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: !_isSignUp
                        ? AppColors.background
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isSignUp) {
                  Haptics.light();
                  setState(() => _isSignUp = true);
                }
              },
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isSignUp ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: _isSignUp
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                  boxShadow: _isSignUp
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            offset: const Offset(2, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _isSignUp
                        ? AppColors.background
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo area with animated gradient container
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.bolt,
                      size: 80,
                      color: AppColors.primary,
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 2000.ms,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                    const SizedBox(height: 16),
                    Text(
                      'LeadForge',
                      style: AppTypography.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI-powered lead generation',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .fade(begin: 0.85, end: 1.0, duration: 3000.ms, curve: Curves.easeInOut),
              const SizedBox(height: 32),

              // Brutal pill toggle for Sign In / Sign Up
              _buildPillToggle(),
              const SizedBox(height: 24),

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: _validateEmail,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: _validatePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Forgot password link
              if (!_isSignUp)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Error message (animated)
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .slideX(begin: -0.1, duration: 200.ms, curve: Curves.easeOut)
                    .fadeIn(duration: 200.ms)
                    .shake(hz: 4, curve: Curves.easeInOut),
              const SizedBox(height: 24),

              // Submit button — BrutalButton, full width
              SizedBox(
                width: double.infinity,
                child: BrutalButton(
                  label: _isSignUp ? 'Sign Up' : 'Sign In',
                  onPressed: _isLoading ? null : _handleEmailAuth,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(height: 24),

              // Divider + Apple Sign In (only on Apple platforms)
              if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) ...[
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32),

              // Apple Sign In
              AnimatedButton(
                onPressed: _isLoading ? null : _handleAppleSignIn,
                enabled: !_isLoading,
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.apple),
                    SizedBox(width: 8),
                    Text('Continue with Apple'),
                  ],
                ),
              ),
              ],
            ],
          ),
          ),
        ),
      ),
    );
  }
}
