import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/data/services/token_storage.dart';

class ProfileService {
  late final http.Client _client;

  ProfileService() {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          return host == '10.0.2.2' || host == 'localhost';
        };
    _client = IOClient(ioClient);
  }

  /// Actualiza nombre, apellido y contraseña del usuario autenticado.
  /// La contraseña es opcional: si es null o vacía, no se envía al servidor.
  Future<http.Response> updateProfile({
    required String firstName,
    required String lastName,
    String? password,
  }) async {
    final token = await TokenStorage.getToken();

    final body = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
    };
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    return await _client
        .patch(
          Uri.parse(AppConfig.profileEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
  }
}
