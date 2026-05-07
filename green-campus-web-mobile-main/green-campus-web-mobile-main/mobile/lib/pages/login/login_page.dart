import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/core/constants/user_roles.dart';
import 'package:mobile_app/data/services/token_storage.dart';
import 'package:mobile_app/domain/validators/email_validator.dart';
import 'package:mobile_app/domain/validators/password_validator.dart';
import 'package:mobile_app/logic/login/login_controller.dart';
import 'package:mobile_app/widgets/email_text_field.dart';
import 'package:mobile_app/widgets/password_text_field.dart';
import 'package:mobile_app/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Clave local para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores y Nodos de Foco
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // Instancia del controlador de lógica
  final _authController = LoginController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // 1. Validar formulario antes de proceder
    if (!_formKey.currentState!.validate()) return;

    // 2. Ocultar teclado
    FocusScope.of(context).unfocus();

    // 3. Ejecutar lógica de login
    final succes = await _authController.login(
      _emailController.text,
      _passwordController.text,
    );

    if (succes && mounted) {
      // Se recupera el rol guardado en el almacenamiento seguro
      final role = await TokenStorage.getRole();
      if (!mounted) return;

      // Se ejecuta la nevegación según el contrato de roles
      String targetRoute;

      switch (role) {
        case UserRoles.directivo:
          targetRoute = '/dashboard-directivo';
          break;
        case UserRoles.serviciosGenerales:
          targetRoute = '/dashboard-servicios';
          break;
        case UserRoles.tecnico:
          targetRoute = '/dashboard-tecnico';
          break;
        default:
          targetRoute = '/'; // Fallback por seguridad
      }

      Navigator.pushReplacementNamed(context, targetRoute);
    } else if (mounted && _authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.errorMessage!),
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
        // Blindaje contra el 'notch'
        child: ListenableBuilder(
          // Escucha cambios en el controlador
          listenable: _authController,
          builder: (context, _) {
            return SingleChildScrollView(
              // Blindaje contra el teclado
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    Image.asset(
                      'resources/images/logoGreenXL.png',
                      height: 100,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Green Campus',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Inicia sesión en tu cuenta',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Input de Email
                    EmailTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      validator: EmailValidator.validate,
                      onFieldSubmitted: () =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                    ),

                    const SizedBox(height: 20),

                    // Input contraseña
                    PasswordTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      validator: PasswordValidator.validate,
                      onFieldSubmitted: _handleLogin,
                      hintText: '',
                      label: 'Contraseña',
                    ),

                    // Enlace Olvidate Contraseña
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/forgot-password'),
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Boton principal
                    PrimaryButton(
                      text: 'Inciar Sesión',
                      isLoading: _authController.isLoading,
                      onPressed: _handleLogin,
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
