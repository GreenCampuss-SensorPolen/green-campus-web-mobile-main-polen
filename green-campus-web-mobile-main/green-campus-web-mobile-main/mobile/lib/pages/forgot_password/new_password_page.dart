import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/domain/validators/password_validator.dart';
import 'package:mobile_app/logic/forgot_password/new_password_controller.dart';
import 'package:mobile_app/widgets/otp_input_field.dart';
import 'package:mobile_app/widgets/password_text_field.dart';
import 'package:mobile_app/widgets/primary_button.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  late NewPasswordController _logicController;
  String _otpCode = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extraemos los argumentos enviados desde el paso 2
    final email = ModalRoute.of(context)!.settings.arguments as String;
    _logicController = NewPasswordController(email: email);
  }

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    _logicController.dispose(); // Se libera la memoria
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Introduce el código de 6 dígitos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar coincidencia exacta
    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las contraseña no coinciden"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _logicController.resetPassword(
      _otpCode,
      _passController.text,
    );

    if (success && mounted) {
      // Feedback verde y limpieza de historial
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Contraseña actualizada!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else if (mounted && _logicController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_logicController.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _logicController,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const Icon(
                      Icons.lock_open_rounded,
                      size: 80,
                      color: AppColors.accentGreen,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Restablecer cuenta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Introduce el código enviado a tu email y tu nueva clave',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Código de verificación",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Se inserta el campo OTP aquí
                    OtpInputField(onCompleted: (code) => _otpCode = code),

                    const SizedBox(height: 24),

                    Text(
                      _logicController.canResend
                          ? "Ya puedes reenviar el código"
                          : "Reenviar código en ${_logicController.resendSeconds}s",
                    ),

                    const SizedBox(height: 32),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Nueva contraseña",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Reutilización de widget de password
                    PasswordTextField(
                      controller: _passController,
                      hintText: 'Nueva contraseña',
                      validator: PasswordValidator.validate,
                      label: 'Contraseña Nueva',
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      controller: _confirmPassController,
                      hintText: 'Repetir contraseña',
                      validator: PasswordValidator.validate,
                      label: 'Repetir Contraseña',
                    ),

                    const SizedBox(height: 40),
                    PrimaryButton(
                      text: 'Actualizar contraseña',
                      isLoading: _logicController.isLoading,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
