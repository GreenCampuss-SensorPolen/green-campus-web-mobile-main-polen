import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/domain/validators/email_validator.dart';
import 'package:mobile_app/logic/forgot_password/forgot_password_request_controller.dart';
import 'package:mobile_app/widgets/email_text_field.dart';
import 'package:mobile_app/widgets/primary_button.dart';

class RequestResetPage extends StatefulWidget {
  const RequestResetPage({super.key});

  @override
  State<RequestResetPage> createState() => _RequestResetPageState();
}

class _RequestResetPageState extends State<RequestResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _controller = ForgotPasswordRequestController();

  @override
  void dispose() {
    _emailController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // Ocultar teclado para mejorar UX durante la carga
    FocusScope.of(context).unfocus();

    final success = await _controller.requestCode(_emailController.text.trim());

    if (success && mounted) {
      // Navegación al paso 2 pasando el email como argumento
      Navigator.pushNamed(
        context,
        '/new-password',
        arguments: _emailController.text.trim(),
      );
    } else if (mounted && _controller.errorMessage != null) {
      // Error excusivo vía Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
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
        // Blindaje para el Notch
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SingleChildScrollView(
              // Blindaje contra el teclado
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: AppColors.accentGreen,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Recuperar Contraseña',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Ingresa tu correo elctrónico para recibir un código',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 40),

                    // Reutilización del widget de Email
                    EmailTextField(
                      controller: _emailController,
                      validator: EmailValidator.validate,
                    ),
                    const SizedBox(height: 24),
                    // Reutilización del PrimaryButton
                    PrimaryButton(
                      text: 'Enviar código de verificación',
                      isLoading: _controller.isLoading,
                      onPressed: _handleRequest,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '← Volver al inicio de sesión',
                        style: TextStyle(color: AppColors.accentGreen),
                      ),
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
