import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_app/data/services/auth_service.dart';

class ForgotPasswordRequestController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Ejecuta la solicitud del código de 6 dígitos
  Future<bool> requestCode(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.requestPasswordReset(email);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true; // El servidor envió el correo
      } else {
        // Capturamos el error específico del servidor
        _errorMessage = body['message'] ?? "No se pudo procesar la solicitud";
      }
    } catch (e) {
      _errorMessage = "Error de conexión. Revisa tu conexión.";
    }

    _isLoading = false;
    notifyListeners();
    return false; // Hubo un error
  }
}
