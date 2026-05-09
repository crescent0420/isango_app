import 'package:flutter/material.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_spacing.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';

typedef SignUpSubmit = Future<void> Function(
  String fullName,
  String email,
  String password,
);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.onSubmit});

  final SignUpSubmit? onSubmit;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _submissionError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your full name';
    if (name.length < 2) return 'Name is too short';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!pattern.hasMatch(email)) {
      return 'Please use a valid university email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Create a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _onSignUp() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final submit = widget.onSubmit;
      if (submit != null) {
        await submit(
          _fullNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.verifyEmail,
        arguments: _emailController.text.trim(),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submissionError =
            'We could not create your account. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mistBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardWhite,
        surfaceTintColor: AppColors.cardWhite,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.logisticsNavy),
          onPressed: () => Navigator.canPop(context)
              ? Navigator.pop(context)
              : Navigator.pushReplacementNamed(context, AppRoutes.login),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 24,
            height: 32 / 24,
            letterSpacing: -0.24,
            fontWeight: FontWeight.w800,
            color: AppColors.logisticsNavy,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Text(
                      'Join your campus community if you never want to miss an event.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.mutedOperationalInk,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_submissionError != null) ...[
                    _ErrorBanner(message: _submissionError!),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _StitchField(
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    child: TextFormField(
                      controller: _fullNameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      textCapitalization: TextCapitalization.words,
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        hintText: 'John Doe',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: _validateFullName,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StitchField(
                    label: 'University Email',
                    icon: Icons.mail_outline,
                    keyOverride: const Key('signUpEmailField'),
                    isError: _emailHasError,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      enabled: !_isSubmitting,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        hintText: 'your university email',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: _validateEmail,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StitchField(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    trailingIcon: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.mutedOperationalInk,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      enabled: !_isSubmitting,
                      decoration: const InputDecoration(
                        hintText: '••••••••',
                        helperText: 'At least 6 characters',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: _validatePassword,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _StitchField(
                    label: 'Confirm Password',
                    icon: Icons.lock_reset_outlined,
                    trailingIcon: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.mutedOperationalInk,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      enabled: !_isSubmitting,
                      onFieldSubmitted: (_) => _onSignUp(),
                      decoration: const InputDecoration(
                        hintText: '••••••••',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      validator: _validateConfirm,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    key: const Key('signUpSubmit'),
                    onPressed: _isSubmitting ? null : _onSignUp,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.logisticsNavy,
                      disabledBackgroundColor:
                          AppColors.logisticsNavy.withValues(alpha: 0.6),
                      minimumSize: const Size.fromHeight(56),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: 6,
                      shadowColor:
                          AppColors.logisticsNavy.withValues(alpha: 0.25),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            key: Key('signUpLoading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.cardWhite,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Create Account'),
                              SizedBox(width: AppSpacing.xs),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: SizedBox(
                      width: 320,
                      child: Text(
                        'We will send you a verification link to your email after you sign up.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMuted.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _emailHasError {
    if (_submissionError != null) return false;
    final value = _emailController.text;
    if (value.isEmpty) return false;
    return _validateEmail(value) != null;
  }
}

class _StitchField extends StatelessWidget {
  const _StitchField({
    required this.label,
    required this.icon,
    required this.child,
    this.trailingIcon,
    this.isError = false,
    this.keyOverride,
  });

  final String label;
  final IconData icon;
  final Widget child;
  final Widget? trailingIcon;
  final bool isError;
  final Key? keyOverride;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isError ? AppColors.criticalRed : AppColors.softBorder;
    final iconColor =
        isError ? AppColors.criticalRed : AppColors.mutedOperationalInk;
    final fillColor = isError
        ? AppColors.criticalRed.withValues(alpha: 0.06)
        : AppColors.cardWhite;

    return Column(
      key: keyOverride,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w600,
              color: isError ? AppColors.criticalRed : AppColors.nearBlackInk,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: child),
                if (isError)
                  const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xs),
                    child: Icon(
                      Icons.error_outline,
                      color: AppColors.criticalRed,
                    ),
                  )
                else
                  ?trailingIcon,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('signUpError'),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.criticalRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.criticalRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.criticalRed),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.criticalRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
