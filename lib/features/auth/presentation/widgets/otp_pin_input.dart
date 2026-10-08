import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Accessible 6-digit PIN / OTP input widget with responsive bento cells,
/// focused teal borders, and keyboard paste support.
class OtpPinInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final bool enabled;
  final FocusNode? focusNode;

  const OtpPinInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.onCompleted,
    this.hasError = false,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<OtpPinInput> createState() => _OtpPinInputState();
}

class _OtpPinInputState extends State<OtpPinInput> {
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    widget.controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChange);
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  void _handleControllerChange() {
    setState(() {});
    if (widget.controller.text.length == 6) {
      widget.onCompleted?.call(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;

    return Semantics(
      textField: true,
      label: '6-digit verification code',
      value: text,
      hint: 'Enter the 6-digit code sent via SMS',
      enabled: widget.enabled,
      child: GestureDetector(
        onTap: () {
          if (widget.enabled) {
            _effectiveFocusNode.requestFocus();
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hidden native TextField that captures keystrokes, autofill, and paste
            Opacity(
              opacity: 0.0,
              child: SizedBox(
                height: 56,
                child: TextField(
                  key: const Key('otp_hidden_text_field'),
                  controller: widget.controller,
                  focusNode: _effectiveFocusNode,
                  keyboardType: TextInputType.number,
                  enabled: widget.enabled,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: widget.onChanged,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            // Visible 6-cell Bento PIN display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                final isFilled = index < text.length;
                final isCurrent = index == text.length && _effectiveFocusNode.hasFocus;
                final digit = isFilled ? text[index] : '';

                Color borderColor = AppColors.surfaceBorder;
                if (widget.hasError) {
                  borderColor = AppColors.error;
                } else if (isCurrent) {
                  borderColor = AppColors.primary;
                } else if (isFilled) {
                  borderColor = AppColors.primaryAccent;
                }

                Color backgroundColor = AppColors.surface;
                if (isCurrent) {
                  backgroundColor = AppColors.surfaceElevated;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 46,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: AppRadii.roundedMd,
                    border: Border.all(
                      color: borderColor,
                      width: isCurrent || widget.hasError ? 2.0 : 1.0,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    digit,
                    style: AppTypography.headline.copyWith(
                      color: widget.hasError
                          ? AppColors.error
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
