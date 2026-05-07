import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_borders.dart';
import 'package:mobile_app/core/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // El boton no debe hacer nada si está cargando o deshabilitado
    final bool effectiveDisabled = isDisabled || isLoading;

    return SizedBox(
      width: double.infinity, // El boton ocupa todo el ancho disponible
      height: 50, // Altura estandar
      child: ElevatedButton(
        onPressed: effectiveDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.inputBorder,
          shape: RoundedRectangleBorder(borderRadius: AppBorders.defaultRadius),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
