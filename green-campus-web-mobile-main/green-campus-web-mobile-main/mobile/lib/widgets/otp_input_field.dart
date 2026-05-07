import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/core/app_borders.dart';
import 'package:mobile_app/core/app_colors.dart';

class OtpInputField extends StatefulWidget {
  final Function(String) onCompleted;

  const OtpInputField({super.key, required this.onCompleted});

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  // Lista de controladores y focos para los 6 campos
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // Salto al primer input vacío al hacer tap
  void handleTap(int index) {
    int firstEmptyIndex = _controllers.indexWhere(
      (controller) => controller.text.isEmpty,
    );

    // Si hay una casilla vacía antes de la que el usuario pulsó, se fuerza el foco allí
    if (firstEmptyIndex != -1 && firstEmptyIndex < index) {
      _focusNodes[firstEmptyIndex].requestFocus();
    }
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Salto automático al siguiente campo
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // Si es el último, enviamos el código completo
        final code = _controllers.map((e) => e.text).join();
        widget.onCompleted(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 48,
          // CllabackShortcuts para detectar el Backspace en vacío
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.backspace): () {
                if (_controllers[index].text.isNotEmpty) {
                  // Si el campo actual tiene texto, lo limpiamos
                  _controllers[index].clear();
                } else if (index > 0) {
                  // Si el campo está vacío, se salta al anterior y se borra su contenido
                  _focusNodes[index - 1].requestFocus();
                  _controllers[index - 1].clear();
                }
              },
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              onTap: () => handleTap(index), // Se aplica el foco inteligente
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: AppBorders.defaultRadius,
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppBorders.defaultRadius,
                  borderSide: const BorderSide(
                    color: AppColors.accentGreen,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) => _onChanged(value, index),
            ),
          ),
        );
      }),
    );
  }
}
