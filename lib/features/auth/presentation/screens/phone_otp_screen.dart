import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ugcult/app/theme/colors.dart';
import 'package:ugcult/app/theme/tokens.dart';
import 'package:ugcult/core/widgets/app_button.dart';
import 'package:ugcult/core/widgets/bouncy_scale.dart';
import 'package:ugcult/core/widgets/glass_container.dart';
import 'package:ugcult/features/auth/presentation/providers/auth_provider.dart';
import 'package:ugcult/features/auth/utils/egyptian_phone_formatter.dart';
import 'package:ugcult/features/onboarding/presentation/widgets/tos_modal.dart';

class PhoneOtpScreen extends ConsumerStatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  ConsumerState<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<PhoneOtpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  late final AnimationController _shakeController;
  int _focusedOtpIndex = 0;

  bool _isCodeSent = false;
  bool _isLoading = false;
  String? _phoneError;
  String? _otpError;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    for (int i = 0; i < _otpFocusNodes.length; i++) {
      _otpFocusNodes[i].addListener(() {
        if (_otpFocusNodes[i].hasFocus) {
          setState(() => _focusedOtpIndex = i);
        }
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _resendCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
        setState(() => _resendCountdown = 0);
      }
    });
  }

  Future<void> _handleSendOtp() async {
    final rawPhone = _phoneController.text.trim();
    if (!EgyptianPhoneUtils.isValid(rawPhone)) {
      setState(() {
        _phoneError = 'Please enter a valid Egyptian mobile number (e.g. 01012345678)';
      });
      return;
    }

    setState(() {
      _phoneError = null;
      _isLoading = true;
    });

    try {
      final agreed = await TosModal.show(context);
      if (agreed != true) {
        setState(() => _isLoading = false);
        return;
      }

      final normalizedPhone = EgyptianPhoneUtils.toE164(rawPhone);
      await ref.read(authNotifierProvider.notifier).sendOtp(normalizedPhone);

      setState(() {
        _isCodeSent = true;
        _isLoading = false;
      });
      _startCountdown();

      // Focus first OTP input
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _otpFocusNodes[0].requestFocus();
      });
    } catch (e) {
      setState(() {
        _phoneError = 'Failed to send OTP code: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 6) {
      _shakeController.forward(from: 0.0);
      setState(() => _otpError = 'Please enter all 6 digits.');
      return;
    }

    setState(() {
      _isLoading = true;
      _otpError = null;
    });

    try {
      final phone = EgyptianPhoneUtils.toE164(_phoneController.text.trim());
      final nextState = await ref.read(authNotifierProvider.notifier).verifyOtp(
            phone: phone,
            token: code,
          );

      HapticFeedback.mediumImpact();

      if (!mounted) return;

      if (nextState.isAuthenticated) {
        if (nextState.isCreator) {
          context.go('/creator/home');
        } else {
          context.go('/brand/home');
        }
      } else {
        context.go('/onboarding/role-selection');
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      setState(() {
        _otpError = 'Invalid verification code. Please check and try again.';
        _isLoading = false;
      });
    }
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      HapticFeedback.selectionClick();
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
        // 6th digit entered -> auto-submit
        _handleVerifyOtp();
      }
    } else {
      if (index > 0) {
        _otpFocusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.canvasGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space5,
              vertical: AppTokens.space6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button if in code-entry phase
                if (_isCodeSent)
                  BouncyScale(
                    onTap: () {
                      setState(() {
                        _isCodeSent = false;
                        _otpError = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppTokens.space2),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppTokens.radiusSm,
                        boxShadow: const [AppColors.shadowSm],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.ink900,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: AppTokens.space4),

                const SizedBox(height: AppTokens.space4),

                // Heading with Apple typography
                Text(
                  _isCodeSent ? 'Enter 6-digit Code' : 'Welcome to UGCULT',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.ink900,
                      ),
                ),
                const SizedBox(height: AppTokens.space2),
                Text(
                  _isCodeSent
                      ? 'We sent a 6-digit SMS verification code to ${EgyptianPhoneUtils.formatDisplay(_phoneController.text)}.'
                      : 'Enter your mobile phone number to get started with Egypt\'s premier UGC creator marketplace.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ink700,
                        height: 1.4,
                      ),
                ),

                const SizedBox(height: AppTokens.space8),

                if (!_isCodeSent) ...[
                  // Phone Number Input Card with Glass Refraction
                  GlassContainer(
                    tier: GlassTier.tierA,
                    padding: const EdgeInsets.all(AppTokens.space5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Egyptian Mobile Number',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink900,
                              ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppTokens.radiusMd,
                            border: Border.all(
                              color: _phoneError != null
                                  ? AppColors.error
                                  : AppColors.ink100,
                              width: 1.5,
                            ),
                            boxShadow: const [AppColors.shadowSm],
                          ),
                          child: Row(
                            children: [
                              // Country code badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTokens.space3,
                                  vertical: AppTokens.space3,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: AppColors.ink100,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🇪🇬 ', style: TextStyle(fontSize: 18)),
                                    Text(
                                      '+20',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink900,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppTokens.space3),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.ink900,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                  decoration: const InputDecoration(
                                    hintText: '010 1234 5678',
                                    hintStyle: TextStyle(color: AppColors.ink300),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    if (_phoneError != null) {
                                      setState(() => _phoneError = null);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_phoneError != null) ...[
                          const SizedBox(height: AppTokens.space2),
                          Text(
                            _phoneError!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTokens.space6),

                  AppButton(
                    label: 'Send Verification Code',
                    variant: AppButtonVariant.primary,
                    role: AppButtonRole.brand,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    onPressed: _handleSendOtp,
                  ),

                  const SizedBox(height: AppTokens.space8),

                  // Quick Demo & Design System Exploration
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Interactive Previews',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.ink500,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        Wrap(
                          spacing: AppTokens.space3,
                          runSpacing: AppTokens.space2,
                          alignment: WrapAlignment.center,
                          children: [
                            BouncyScale(
                              onTap: () => context.push('/design-system'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTokens.space4,
                                  vertical: AppTokens.space2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: AppTokens.radiusMd,
                                  border: Border.all(color: AppColors.ink100),
                                  boxShadow: const [AppColors.shadowSm],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.palette_outlined, size: 16, color: AppColors.ink700),
                                    SizedBox(width: AppTokens.space2),
                                    Text('Design System', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                            BouncyScale(
                              onTap: () => context.push('/onboarding/role-selection'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTokens.space4,
                                  vertical: AppTokens.space2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: AppTokens.radiusMd,
                                  border: Border.all(color: AppColors.babyPinkSolid),
                                  boxShadow: const [AppColors.shadowSm],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.explore_outlined, size: 16, color: AppColors.babyPinkSolid),
                                    SizedBox(width: AppTokens.space2),
                                    Text('Onboarding Flow', style: TextStyle(color: AppColors.babyPinkSolid, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // 6-digit OTP Code Entry Card with Error Shake & Animated Cells
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final double offset = _otpError != null
                          ? sin(_shakeController.value * pi * 6) *
                              (1.0 - _shakeController.value) *
                              9.0
                          : 0.0;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: GlassContainer(
                      tier: GlassTier.tierA,
                      padding: const EdgeInsets.all(AppTokens.space5),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final isFocused = _focusedOtpIndex == index && _otpFocusNodes[index].hasFocus;
                              final hasValue = _otpControllers[index].text.isNotEmpty;

                              return AnimatedContainer(
                                duration: AppTokens.durationFast,
                                curve: Curves.easeOutCubic,
                                width: 48,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: AppTokens.radiusMd,
                                  border: Border.all(
                                    color: _otpError != null
                                        ? AppColors.error
                                        : isFocused
                                            ? AppColors.babyBlueSolid
                                            : hasValue
                                                ? AppColors.ink700
                                                : AppColors.ink100,
                                    width: isFocused ? 2.0 : 1.2,
                                  ),
                                  boxShadow: isFocused
                                      ? [
                                          BoxShadow(
                                            color: AppColors.babyBlueSolid.withValues(alpha: 0.25),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : const [AppColors.shadowSm],
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _otpControllers[index],
                                    focusNode: _otpFocusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.ink900,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(1),
                                    ],
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (val) => _onOtpDigitChanged(index, val),
                                  ),
                                ),
                              );
                            }),
                          ),

                          if (_otpError != null) ...[
                            const SizedBox(height: AppTokens.space3),
                            Text(
                              _otpError!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],

                          const SizedBox(height: AppTokens.space6),

                          AppButton(
                            label: 'Verify & Continue',
                            variant: AppButtonVariant.primary,
                            role: AppButtonRole.brand,
                            isLoading: _isLoading,
                            isFullWidth: true,
                            onPressed: _handleVerifyOtp,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTokens.space5),

                  Center(
                    child: _resendCountdown > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.space4,
                              vertical: AppTokens.space2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.7),
                              borderRadius: AppTokens.radiusFull,
                              border: Border.all(color: AppColors.ink100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink500),
                                  ),
                                ),
                                const SizedBox(width: AppTokens.space2),
                                Text(
                                  'Resend code in ${_resendCountdown}s',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.ink700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : BouncyScale(
                            onTap: _isLoading ? null : _handleSendOtp,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTokens.space4,
                                vertical: AppTokens.space2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: AppTokens.radiusFull,
                                border: Border.all(color: AppColors.babyBlueSolid),
                                boxShadow: const [AppColors.shadowSm],
                              ),
                              child: const Text(
                                'Resend Code',
                                style: TextStyle(
                                  color: AppColors.babyBlueSolid,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
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
