import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/ios_toast.dart';
import '../../utils/haptics.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  String? _errorMessage;
  String? _emailError;
  String? _passwordError;
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

  bool _validate() {
    final emailErr = _validateEmail(_emailController.text);
    final passErr = _validatePassword(_passwordController.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    return emailErr == null && passErr == null;
  }

  Future<void> _handleEmailAuth() async {
    if (!_validate()) return;

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
      IosToast.show(context, 'Please enter your email address');
      return;
    }

    Haptics.medium();
    try {
      await ref.read(authProvider.notifier).resetPassword(email);

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Email Sent'),
            content: Text(
              'Password reset link sent to $email. Check your inbox.',
            ),
            actions: [
              CupertinoDialogAction(
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
        IosToast.show(context, 'Error: $e');
      }
    }
  }

  Widget _buildPillToggle(BuildContext context) {
    final dividerColor =
        CupertinoDynamicColor.resolve(AppColors.divider, context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dividerColor,
        borderRadius: BorderRadius.circular(AppColors.radiusL),
      ),
      child: Row(
        children: [
          _buildPillOption(context, 'Sign In', !_isSignUp, () {
            if (_isSignUp) {
              Haptics.light();
              setState(() {
                _isSignUp = false;
                _errorMessage = null;
                _emailError = null;
                _passwordError = null;
              });
            }
          }),
          _buildPillOption(context, 'Sign Up', _isSignUp, () {
            if (!_isSignUp) {
              Haptics.light();
              setState(() {
                _isSignUp = true;
                _errorMessage = null;
                _emailError = null;
                _passwordError = null;
              });
            }
          }),
        ],
      ),
    );
  }

  Widget _buildPillOption(
      BuildContext context, String label, bool isActive, VoidCallback onTap) {
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final surfaceColor =
        CupertinoDynamicColor.resolve(AppColors.surface, context);
    final secondaryColor =
        CupertinoDynamicColor.resolve(AppColors.textSecondary, context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? surfaceColor : null,
            borderRadius: BorderRadius.circular(AppColors.radiusM),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.08),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isActive ? accentColor : secondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchFieldColor =
        CupertinoDynamicColor.resolve(AppColors.searchField, context);
    final tertiaryColor =
        CupertinoDynamicColor.resolve(AppColors.textTertiary, context);
    final primaryTextColor =
        CupertinoDynamicColor.resolve(AppColors.textPrimary, context);
    final secondaryTextColor =
        CupertinoDynamicColor.resolve(AppColors.textSecondary, context);
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final scoreBadColor =
        CupertinoDynamicColor.resolve(AppColors.scoreBad, context);
    final dividerColor =
        CupertinoDynamicColor.resolve(AppColors.divider, context);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pageHorizontal, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 56),

                // Title — text only, editorial minimalism
                Column(
                  children: [
                    Text(
                      'LeadForge',
                      style: AppTypography.displayLarge(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI-powered lead generation',
                      style: AppTypography.bodyLarge(context).copyWith(
                        color: secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(
                        begin: -0.03,
                        duration: 400.ms,
                        curve: Curves.easeOut),
                const SizedBox(height: 36),

                // Pill toggle
                _buildPillToggle(context),
                const SizedBox(height: 24),

                // Email field
                CupertinoTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  placeholder: 'Email address',
                  placeholderStyle: TextStyle(color: tertiaryColor),
                  style: TextStyle(color: primaryTextColor),
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.mail,
                      size: 20,
                      color: tertiaryColor,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: searchFieldColor,
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                    border: _emailError != null
                        ? Border.all(color: scoreBadColor, width: 0.5)
                        : null,
                  ),
                ),
                if (_emailError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      _emailError!,
                      style: TextStyle(
                        fontSize: 12,
                        color: scoreBadColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),

                // Password field
                CupertinoTextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleEmailAuth(),
                  placeholder: 'Password',
                  placeholderStyle: TextStyle(color: tertiaryColor),
                  style: TextStyle(color: primaryTextColor),
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.lock,
                      size: 20,
                      color: tertiaryColor,
                    ),
                  ),
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: () {
                        setState(
                            () => _obscurePassword = !_obscurePassword);
                      },
                      child: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        size: 20,
                        color: tertiaryColor,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: searchFieldColor,
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                    border: _passwordError != null
                        ? Border.all(color: scoreBadColor, width: 0.5)
                        : null,
                  ),
                ),
                if (_passwordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      _passwordError!,
                      style: TextStyle(
                        fontSize: 12,
                        color: scoreBadColor,
                      ),
                    ),
                  ),

                if (!_isSignUp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onPressed: _forgotPassword,
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 13,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: scoreBadColor.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppColors.radiusM),
                      border: Border.all(
                        color: scoreBadColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.exclamationmark_circle,
                            color: scoreBadColor, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: scoreBadColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 250.ms),

                // Submit button
                AppButton(
                  label: _isSignUp ? 'Create Account' : 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleEmailAuth,
                ),
                const SizedBox(height: 20),

                // Apple Sign In
                if (!kIsWeb &&
                    (Platform.isIOS || Platform.isMacOS)) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 0.5,
                          color: dividerColor,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(
                            fontSize: 15,
                            color: tertiaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.5,
                          color: dividerColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  AppButton(
                    label: 'Continue with Apple',
                    variant: AppButtonVariant.secondary,
                    onPressed: _isLoading ? null : _handleAppleSignIn,
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
