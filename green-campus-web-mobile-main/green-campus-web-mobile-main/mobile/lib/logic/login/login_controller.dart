import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/login_response.dart';
import 'package:mobile_app/data/services/auth_service.dart';
import 'package:mobile_app/data/services/token_storage.dart';

class LoginController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  // Estados privados para el control interno
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para que la UI pueda leer el estado pero no modificarlo directamente
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Método principal para ejecutar el inicio de sesión
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      final body = jsonDecode(response.body);
      // ignore: avoid_print
      print('LOGIN STATUS: ${response.statusCode}');
      // ignore: avoid_print
      print('LOGIN BODY: ${response.body}');
      if (response.statusCode == 200) {
        final logindata = LoginResponse.fromJson(body);
        // Se guardan los datos de forma segura
        await TokenStorage.saveSession(
          token: logindata.jwt,
          role: logindata.role,
          email: logindata.email,
          profileImage: logindata.profileImageUrl,
          firstName: logindata.firstName,
          lastName: logindata.lastName,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = body['message'] ?? "Error de acceso";
      }
    } catch (e) {
      // ignore: avoid_print
      print('Login error real: $e');
      _errorMessage = "No se pudo conectar con el servidor";
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
