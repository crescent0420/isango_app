import 'package:flutter/material.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_spacing.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';
import 'package:isango_app/screens/auth/widgets/auth_scaffold.dart';

typedef SignInSubmit = Future<void> Function(String email, String password);

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.onSubmit});

  final SignInSubmit? onSubmit;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _submissionError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!pattern.hasMatch(email)) {
      return 'Please enter a valid university email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _onSignIn() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final submit = widget.onSubmit;
      if (submit != null) {
        await submit(_emailController.text.trim(), _passwordController.text);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submissionError =
            'We could not sign you in. Check your details and try again.';
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset will be available soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            const SizedBox(height: AppSpacing.lg),
            const _Intro(),
            const SizedBox(height: AppSpacing.lg),
            if (_submissionError != null) ...[
              _SubmissionErrorBanner(message: _submissionError!),
              const SizedBox(height: AppSpacing.md),
            ],
            _LabeledField(
              label: 'Email Address',
              labelColor: _emailHasError ? AppColors.criticalRed : null,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                enabled: !_isSubmitting,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'your university email',
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: _emailHasError
                        ? AppColors.criticalRed
                        : AppColors.mutedOperationalInk,
                  ),
                  suffixIcon: _emailHasError
                      ? const Icon(
                          Icons.error_outline,
                          color: AppColors.criticalRed,
                        )
                      : null,
                ),
                validator: _validateEmail,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _LabeledField(
              label: 'Password',
              trailing: TextButton(
                key: const Key('forgotPassword'),
                onPressed: _isSubmitting ? null : _onForgotPassword,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.commandBlue,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                enabled: !_isSubmitting,
                onFieldSubmitted: (_) => _onSignIn(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: _validatePassword,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              key: const Key('signInSubmit'),
              onPressed: _isSubmitting ? null : _onSignIn,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.logisticsNavy,
                disabledBackgroundColor:
                    AppColors.logisticsNavy.withValues(alpha: 0.6),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 6,
                shadowColor: AppColors.logisticsNavy.withValues(alpha: 0.25),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      key: Key('signInLoading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.cardWhite,
                      ),
                    )
                  : const Text('Sign In'),
            ),
            const SizedBox(height: AppSpacing.md),
            _SignUpFooter(
              isSubmitting: _isSubmitting,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.signUp,
              ),
            ),
          ],
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'Isango',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            height: 40 / 32,
            letterSpacing: -0.64,
            fontWeight: FontWeight.w700,
            color: AppColors.logisticsNavy,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          'Welcome back!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            height: 24 / 18,
            fontWeight: FontWeight.w600,
            color: AppColors.nearBlackInk,
          ),
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Sign in to access your personalized campus events feed.',
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyMuted.copyWith(fontSize: 14, height: 20 / 14),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.trailing,
    this.labelColor,
  });

  final String label;
  final Widget child;
  final Widget? trailing;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: labelColor ?? AppColors.nearBlackInk,
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        child,
      ],
    );
  }
}

class _SignUpFooter extends StatelessWidget {
  const _SignUpFooter({required this.isSubmitting, required this.onTap});

  final bool isSubmitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: AppTextStyles.bodyMuted.copyWith(fontSize: 14),
          ),
          GestureDetector(
            key: const Key('goToSignUp'),
            onTap: isSubmitting ? null : onTap,
            child: const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                color: AppColors.commandBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionErrorBanner extends StatelessWidget {
  const _SubmissionErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('signInError'),
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
