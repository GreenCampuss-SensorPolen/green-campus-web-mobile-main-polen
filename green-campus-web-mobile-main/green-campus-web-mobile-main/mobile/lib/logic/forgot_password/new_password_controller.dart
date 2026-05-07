import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_app/data/services/auth_service.dart';

class NewPasswordController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final String email;

  bool _isLoading = false;
  String? _errorMessage;
  int _resendSeconds = 60;
  Timer? _timer;

  // El controlador recibe los datos de sesión temporal en el constructor
  NewPasswordController({required this.email}) {
    _startTimer();
  }

  void _startTimer() {
    _resendSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        _resendSeconds--;
      } else {
        _timer?.cancel();
      }
    });
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get resendSeconds => _resendSeconds;
  bool get canResend => _resendSeconds == 0;

  // Lógica para ejecutar el cambio de clave
  Future<bool> resetPassword(String code, String newPassword) async {
    if (code.length < 6) {
      _errorMessage = "El código debe tener 6 dígitos";
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.resetPassword(
        email,
        code,
        newPassword,
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true; // Contraseña cambiada exitosamente
      } else {
        final body = jsonDecode(response.body);
        _errorMessage = body['message'] ?? "Error al actualizar la contraseña";
      }
    } catch (e) {
      _errorMessage = "Error de conexión. Inténtalo de nuevo.";
    }

    _isLoading = false;
    notifyListeners();
    return false; // Falló el cambio de contraseña
  }
}
