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
    if (_isSignUp) {
      if (value.length < 8) {
        return 'Password must be at least 8 characters';
      }
      if (!RegExp(r'[A-Za-z]').hasMatch(value) || !RegExp(r'[0-9]').hasMatch(value)) {
        return 'Password must contain letters and numbers';
      }
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
                      color: CupertinoDynamicColor.resolve(AppColors.accent, context).withValues(alpha: 0.08),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.button(context).copyWith(
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
    final accentColor =
        CupertinoDynamicColor.resolve(AppColors.accent, context);
    final scoreBadColor =
        CupertinoDynamicColor.resolve(AppColors.scoreBad, context);
    final dividerColor =
        CupertinoDynamicColor.resolve(AppColors.divider, context);

    return CupertinoPageScaffold(
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SafeArea(bottom: false, child: _HeroSection()),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusM),
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
                          style: AppTypography.chip(context).copyWith(
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
                        padding: const EdgeInsets.only(right: 4),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(44, 44),
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
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusM),
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
                          style: AppTypography.chip(context).copyWith(
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
                            style: AppTypography.labelLarge(context).copyWith(
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
                                style: AppTypography.labelLarge(context).copyWith(
                                  color: scoreBadColor,
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
                              style: AppTypography.bodyLarge(context).copyWith(
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
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    const heroBg = CupertinoDynamicColor.withBrightness(
      color: Color(0xFF18181B),
      darkColor: Color(0xFF111113),
    );
    const heroText = CupertinoDynamicColor.withBrightness(
      color: Color(0xFFFFFFFF),
      darkColor: Color(0xFFF0F0F0),
    );
    const heroMuted = CupertinoDynamicColor.withBrightness(
      color: Color(0xFF666666),
      darkColor: Color(0xFF777777),
    );
    const heroLine = CupertinoDynamicColor.withBrightness(
      color: Color(0x14FFFFFF),
      darkColor: Color(0x18FFFFFF),
    );

    final resolvedBg = CupertinoDynamicColor.resolve(heroBg, context);
    final resolvedText = CupertinoDynamicColor.resolve(heroText, context);
    final resolvedMuted = CupertinoDynamicColor.resolve(heroMuted, context);
    final resolvedLine = CupertinoDynamicColor.resolve(heroLine, context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.pageHorizontal, 32, AppConstants.pageHorizontal, 24,
      ),
      color: resolvedBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEADFORGE',
            style: AppTypography.labelSmall(context).copyWith(
              color: resolvedMuted, letterSpacing: 1.5,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.03, duration: 400.ms, curve: Curves.easeOut),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: AppTypography.displayLarge(context).copyWith(
                fontSize: 30, fontWeight: FontWeight.w900, height: 1.1, color: resolvedText,
              ),
              children: [
                const TextSpan(text: 'Turn weak\nwebsites into\n'),
                TextSpan(text: 'your clients.', style: TextStyle(color: resolvedMuted)),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: -0.03, duration: 400.ms, curve: Curves.easeOut),
          const SizedBox(height: 12),
          Container(
            width: 40, height: 3,
            decoration: BoxDecoration(
              color: resolvedText.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: resolvedLine, width: 1)),
            ),
            child: Row(
              children: [
                _HeroStat(value: '2.4K', label: 'Leads found', color: resolvedText, mutedColor: resolvedMuted),
                const SizedBox(width: 20),
                _HeroStat(value: '890', label: 'Demos built', color: resolvedText, mutedColor: resolvedMuted),
                const SizedBox(width: 20),
                _HeroStat(value: '94%', label: 'Response rate', color: resolvedText, mutedColor: resolvedMuted),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.03, duration: 400.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color mutedColor;

  const _HeroStat({required this.value, required this.label, required this.color, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.titleMedium(context).copyWith(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: AppTypography.chip(context).copyWith(fontSize: 10, color: mutedColor)),
      ],
    );
  }
}
