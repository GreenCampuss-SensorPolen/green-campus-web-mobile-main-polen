import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/services/token_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  // Lógica para determinar la redirección inicial
  Future<void> _checkAuth() async {
    // Se simula un breve tiempo de carga para mostrar el logo
    await Future.delayed(const Duration(seconds: 2));

    // Consulta si existe un token en el almacenamiento seguro
    final token = await TokenStorage.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      // Si hay token, se redirige al home directamente
      Navigator.pushReplacementNamed(
        context,
        '/dashboard-${TokenStorage.getRole().toString().toLowerCase()}',
      );
    } else {
      // Si no hay token, el usuario debe inciar sesión
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'resources/images/logoGreenXL.png',
              width: 160,
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: AppColors.accentGreen,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
