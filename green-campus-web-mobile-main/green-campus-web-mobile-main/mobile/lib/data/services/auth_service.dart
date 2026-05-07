import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/data/services/token_storage.dart';

class AuthService {
  late final http.Client _client;

  AuthService() {
    final ioClient = HttpClient();

    // Solo para desarrollo local con certificado autofirmado
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          return host == '10.0.2.2' || host == 'localhost';
        };
    _client = IOClient(ioClient);
  }
  // Login estandar: Envia email y contraseña, recibe JWT y datos de usuario
  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse(AppConfig.loginEndpoint);

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
      return response;
    } catch (e) {
      // Error de conexión
      rethrow;
    }
  }

  // Solicita el código de recuperación al servidor
  Future<http.Response> requestPasswordReset(String email) async {
    // El endpoint definido
    final url = Uri.parse(AppConfig.forgotPasswordEndpoint);

    return await _client
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(const Duration(seconds: 10));
  }

  // Finaliza el proceso estableciendo la nueva contraseña
  Future<http.Response> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    final url = Uri.parse(AppConfig.resetPasswordEndpoint);

    return await _client
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'code': code,
            'newPassword': newPassword,
          }),
        )
        .timeout(const Duration(seconds: 10));
  }

  // Logout de la app
  Future<http.Response> logout() async {
    final url = Uri.parse(AppConfig.logoutEndpoint);
    final String? token = await TokenStorage.getToken();

    return await _client
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization':
                'Bearer $token', // El server necesita el token para invalidarlo
          },
        )
        .timeout(const Duration(seconds: 10));
  }
}
