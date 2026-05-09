import 'package:flutter/material.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_spacing.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';

typedef ResendVerification = Future<void> Function();

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.onResend});

  final ResendVerification? onResend;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isResending = false;

  Future<void> _onResend() async {
    if (_isResending) return;
    setState(() => _isResending = true);
    try {
      final resend = widget.onResend;
      if (resend != null) {
        await resend();
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email resent.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not resend verification email.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
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
          'Verify Email',
          style: TextStyle(
            fontSize: 18,
            height: 24 / 18,
            fontWeight: FontWeight.w700,
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
            AppSpacing.lg,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _StatusPanel(),
                const SizedBox(height: AppSpacing.lg),
                const _WhyVerifyCard(),
                const SizedBox(height: AppSpacing.xl),
                _ResendButton(
                  isLoading: _isResending,
                  onPressed: _isResending ? null : _onResend,
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    "Can't find the email? Check your spam folder or try resending in 2 minutes.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: const Color(0xFF757682),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.softBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.paleSignalBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_unread,
              size: 32,
              color: AppColors.logisticsNavy,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Verification Pending',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              height: 32 / 24,
              letterSpacing: -0.24,
              fontWeight: FontWeight.w700,
              color: AppColors.nearBlackInk,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              "We've sent a verification link to your student email. Please check your inbox to activate your account.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.mutedOperationalInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyVerifyCard extends StatelessWidget {
  const _WhyVerifyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3FA),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: const Color(0xFFC5C5D3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.verified_outlined,
              color: AppColors.commandBlue,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why verify your email?',
                  style: TextStyle(
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.nearBlackInk,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Verification helps unlock trusted account capabilities to exclusive events and receiving priority notifications.',
                  style: AppTextStyles.bodyMuted.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendButton extends StatelessWidget {
  const _ResendButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const Key('resendVerification'),
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.logisticsNavy,
        disabledBackgroundColor:
            AppColors.logisticsNavy.withValues(alpha: 0.6),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        elevation: 6,
        shadowColor: AppColors.logisticsNavy.withValues(alpha: 0.25),
      ),
      child: isLoading
          ? const SizedBox(
              key: Key('resendLoading'),
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
                Icon(Icons.send, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text('Resend Verification Email'),
              ],
            ),
    );
  }
}
