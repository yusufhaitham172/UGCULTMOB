import 'package:flutter/material.dart';
import 'package:ugcult/app/theme/colors.dart';
import 'package:ugcult/app/theme/tokens.dart';
import 'package:ugcult/core/widgets/app_button.dart';
import 'package:ugcult/core/widgets/glass_container.dart';

class TosModal extends StatefulWidget {
  final VoidCallback onAccepted;

  const TosModal({
    super.key,
    required this.onAccepted,
  });

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TosModal(
        onAccepted: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  State<TosModal> createState() => _TosModalState();
}

class _TosModalState extends State<TosModal> {
  bool _ageAttested = false;
  bool _tosAccepted = false;

  bool get _canProceed => _ageAttested && _tosAccepted;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space4,
          vertical: AppTokens.space4,
        ),
        child: GlassContainer(
          tier: GlassTier.tierA,
          padding: const EdgeInsets.all(AppTokens.space6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ink300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space5),
              Text(
                'Terms & Age Confirmation',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink900,
                    ),
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                'UGCULT connects content creators with brands across Egypt for professional creative collaborations.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.ink700,
                    ),
              ),
              const SizedBox(height: AppTokens.space5),

              // Checkbox 1: Age Attestation (18+)
              InkWell(
                onTap: () {
                  setState(() => _ageAttested = !_ageAttested);
                },
                borderRadius: AppTokens.radiusMd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTokens.space2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _ageAttested,
                        onChanged: (val) => setState(() => _ageAttested = val ?? false),
                        activeColor: AppColors.babyBlueSolid,
                      ),
                      const SizedBox(width: AppTokens.space2),
                      Expanded(
                        child: Text(
                          'I attest that I am 18 years of age or older and legally eligible to participate in commercial brand campaigns.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.ink900,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space2),

              // Checkbox 2: ToS & Privacy
              InkWell(
                onTap: () {
                  setState(() => _tosAccepted = !_tosAccepted);
                },
                borderRadius: AppTokens.radiusMd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTokens.space2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _tosAccepted,
                        onChanged: (val) => setState(() => _tosAccepted = val ?? false),
                        activeColor: AppColors.babyBlueSolid,
                      ),
                      const SizedBox(width: AppTokens.space2),
                      Expanded(
                        child: Text(
                          'I accept the UGCULT Terms of Service and Privacy Policy, including zero-tolerance policies for harassment or abusive revisions.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.ink900,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space6),

              AppButton(
                label: 'Agree & Continue',
                variant: AppButtonVariant.primary,
                role: AppButtonRole.brand,
                isFullWidth: true,
                onPressed: _canProceed ? widget.onAccepted : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
