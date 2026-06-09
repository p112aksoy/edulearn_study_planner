import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edulearn/core/responsive.dart';

/// common input field widget : using by auth_screen and create_account_screen
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool isNumber;
  final bool lettersOnly;
  final int? maxLength;
  final TextInputAction textInputAction;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText      = false,
    this.keyboardType     = TextInputType.text,
    this.suffixIcon,
    this.isNumber         = false,
    this.lettersOnly      = false,
    this.maxLength,
    this.textInputAction  = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text  = Theme.of(context).textTheme;

    return TextField(
      controller:       controller,
      obscureText:      obscureText,
      keyboardType:     isNumber ? TextInputType.number : keyboardType,
      inputFormatters:  isNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : lettersOnly
          ? [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZğüşıöçĞÜŞİÖÇ\s]"))]
          : [],
      textInputAction:  textInputAction,
      maxLength:        maxLength,
      style: text.bodyMedium?.copyWith(color: color.onSurface),
      decoration: InputDecoration(
        hintText:       hint,
        hintStyle:      text.bodyMedium?.copyWith(
            color: color.onSurface.withValues(alpha: 0.35)),
        filled:         true,
        fillColor:      color.surface,
        suffixIcon:     suffixIcon,
        counterText:    '',                // hiding maxLength counter
        contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.spacing(context) * 1.25,
            vertical:   Responsive.spacing(context) * 1.125),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
          borderSide: BorderSide(
              color: color.primary.withValues(alpha: 0.25), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
          borderSide: BorderSide(color: color.primary, width: 1.8),
        ),
      ),
    );
  }
}