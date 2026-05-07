import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/data/services/token_storage.dart';

class FacilityManagementService {
  late final http.Client _client;

  FacilityManagementService() {
    final ioClient = HttpClient();

    // Solo para desarrollo local con certificado autofirmado
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          return host == '10.0.2.2' || host == 'localhost';
        };
    _client = IOClient(ioClient);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Traer los KPIs del semáforo de habitabilidad
  Future<http.Response> getHabitabilityStats() async {
    final headers = await _getHeaders();
    return await _client.get(
      Uri.parse('${AppConfig.apiUrl}/management/habitability'),
      headers: headers,
    );
  }

  // Traer el diagnóstico de las zonas
  Future<http.Response> getZonesStatus() async {
    final headers = await _getHeaders();
    return await _client.get(
      Uri.parse('${AppConfig.apiUrl}/management/zones'),
      headers: headers,
    );
  }

  // Traer la lista de tareas preventivas
  Future<http.Response> getPreventiveTasks() async {
    final headers = await _getHeaders();
    return await _client.get(
      Uri.parse('${AppConfig.apiUrl}/management/tasks'),
      headers: headers,
    );
  }
}
