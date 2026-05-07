import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_borders.dart';
import 'package:mobile_app/core/app_colors.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final VoidCallback? onFieldSubmitted;

  const EmailTextField({
    super.key,
    required this.controller,
    this.validator,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      onFieldSubmitted: (_) => onFieldSubmitted?.call(),
      validator: validator,
      decoration: InputDecoration(
        labelText: 'Correo Electrónico',
        hintText: 'usuario@greencampus.edu',
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: AppColors.accentGreen,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorders.defaultRadius,
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.defaultRadius,
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.defaultRadius,
          borderSide: const BorderSide(color: AppColors.accentGreen, width: 2),
        ),
      ),
    );
  }
}
