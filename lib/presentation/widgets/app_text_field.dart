import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// A labeled text input with a leading icon and optional trailing action
/// (e.g. the show/hide password toggle). Mirrors the email/password/full
/// name fields on the Login and Registration screens so every form in the
/// app looks and behaves the same way.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final IconData leadingIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.leadingIcon,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.trailing,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelBold),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            prefixIcon: Icon(leadingIcon, color: AppColors.outline, size: 20),
            suffixIcon: trailing,
          ),
        ),
      ],
    );
  }
}
