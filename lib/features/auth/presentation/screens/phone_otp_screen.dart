import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ugcult/app/theme/colors.dart';
import 'package:ugcult/app/theme/tokens.dart';
import 'package:ugcult/core/widgets/app_button.dart';
import 'package:ugcult/core/widgets/app_card.dart';
import 'package:ugcult/core/widgets/glass_container.dart';
import 'package:ugcult/features/auth/presentation/providers/auth_provider.dart';
import 'package:ugcult/features/auth/utils/egyptian_phone_formatter.dart';
import 'package:ugcult/features/onboarding/presentation/widgets/tos_modal.dart';

class PhoneOtpScreen extends ConsumerStatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  ConsumerState<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<PhoneOtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isCodeSent = false;
  bool _isLoading = false;
  String? _phoneError;
  String? _otpError;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void dispose() {
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
        // 6th digit entered -> auto-submit!
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space5,
              vertical: AppTokens.space6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button if in code-entry phase
                if (_isCodeSent)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ink900),
                    onPressed: () {
                      setState(() {
                        _isCodeSent = false;
                        _otpError = null;
                      });
                    },
                  )
                else
                  const SizedBox(height: AppTokens.space4),

                const SizedBox(height: AppTokens.space4),
                // Heading
                Text(
                  _isCodeSent ? 'Enter 6-digit Code' : 'Welcome to UGCULT',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink900,
                      ),
                ),
                const SizedBox(height: AppTokens.space2),
                Text(
                  _isCodeSent
                      ? 'We sent a 6-digit SMS verification code to ${EgyptianPhoneUtils.formatDisplay(_phoneController.text)}.'
                      : 'Egypt\'s premier UGC marketplace. Enter your mobile phone number to log in or create an account.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ink700,
                        height: 1.4,
                      ),
                ),

                const SizedBox(height: AppTokens.space8),

                if (!_isCodeSent) ...[
                  // Phone Number Input Card
                  AppCard(
                    padding: const EdgeInsets.all(AppTokens.space5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Egyptian Mobile Number',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
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
                ] else ...[
                  // 6-digit OTP Code Entry
                  GlassContainer(
                    tier: GlassTier.tierA,
                    padding: const EdgeInsets.all(AppTokens.space5),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 46,
                              height: 54,
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _otpFocusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink900,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.white,
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: AppTokens.radiusMd,
                                    borderSide: const BorderSide(color: AppColors.ink100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: AppTokens.radiusMd,
                                    borderSide: const BorderSide(
                                      color: AppColors.babyBlueSolid,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (val) => _onOtpDigitChanged(index, val),
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
                                ),
                          ),
                        ],

                        const SizedBox(height: AppTokens.space5),

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

                  const SizedBox(height: AppTokens.space5),

                  Center(
                    child: _resendCountdown > 0
                        ? Text(
                            'Resend code in ${_resendCountdown}s',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.ink500,
                                ),
                          )
                        : TextButton(
                            onPressed: _isLoading ? null : _handleSendOtp,
                            child: const Text('Resend Code'),
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
