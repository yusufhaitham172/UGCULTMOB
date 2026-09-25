import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/typography.dart';

/// AppTextInput
/// Production text field using clean paper container with concentric borders
class AppTextInput extends StatefulWidget {
  const AppTextInput({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.accentColor = AppColors.blue500,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int maxLines;
  final Color accentColor;

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    Border border;
    if (hasError) {
      border = Border.all(color: AppColors.dangerFg, width: 2.0);
    } else if (_isFocused) {
      border = Border.all(color: widget.accentColor, width: 2.0);
    } else {
      border = Border.all(color: AppColors.ink100, width: 1.0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppTokens.space1,
              bottom: AppTokens.space1,
            ),
            child: Text(
              widget.label!,
              style: AppTypography.subhead.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
        ],
        AnimatedContainer(
          duration: AppTokens.durationFast,
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.white : AppColors.ink100.withValues(alpha: 0.5),
            borderRadius: AppTokens.radiusMd,
            border: border,
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [AppColors.shadowSm],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            style: AppTypography.body.copyWith(
              color: widget.enabled ? AppColors.ink900 : AppColors.ink300,
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hintText,
              hintStyle: AppTypography.callout.copyWith(color: AppColors.ink300),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: AppTokens.space4,
                        end: AppTokens.space2,
                      ),
                      child: widget.prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: AppTokens.space2,
                        end: AppTokens.space4,
                      ),
                      child: widget.suffixIcon,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              border: InputBorder.none,
              contentPadding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppTokens.space4,
                vertical: AppTokens.space4,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppTokens.space2,
              top: AppTokens.space1,
            ),
            child: Text(
              widget.errorText!,
              style: AppTypography.caption.copyWith(
                color: AppColors.dangerFg,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
