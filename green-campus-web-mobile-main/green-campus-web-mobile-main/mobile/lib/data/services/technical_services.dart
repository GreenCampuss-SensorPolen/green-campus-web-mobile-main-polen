import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mobile_app/core/config/app_config.dart';
import 'package:mobile_app/data/services/token_storage.dart';

class TechnicalServices {
  late final http.Client _client;

  TechnicalServices() {
    final ioClient = HttpClient();

    // Solo para desarrollo local con certificado autofirmado.
    // Mismo patrón que AuthService para que 10.0.2.2 / localhost funcionen en el emulador.
    ioClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          return host == '10.0.2.2' || host == 'localhost';
        };
    _client = IOClient(ioClient);
  }

  // Se obtienen los headers con el token de seguridad
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Vital para que el backend lo acepte
    };
  }

  // Traer la lista de dispositivos
  Future<http.Response> getNodes() async {
    final headers = await _getHeaders();
    return await _client.get(
      Uri.parse(AppConfig.nodesEndpoint),
      headers: headers,
    );
  }

  Future<http.Response> getNodeDetails(String nodeId) async {
    final headers = await _getHeaders();
    return await _client.get(
      Uri.parse(AppConfig.nodeIdEndpoint(nodeId)),
      headers: headers,
    );
  }

  // Obtener las últimas N lecturas de un nodo (para el gráfico de rendimiento 24h del dashboard IoT)
  Future<http.Response> getNodeReadings(String nodeId, {int limit = 24}) async {
    final headers = await _getHeaders();
    return await _client.get(
      Uri.parse(AppConfig.nodeLastReadingEndpoint(nodeId)),
      headers: headers,
    );
  }

  Future<http.Response> getNodeTypeReadingByMonth(
    String type,
    int year,
    int month,
  ) async {
    final headers = await _getHeaders();
    return await _client.get(
      Uri.parse(AppConfig.nodeTypeReadingByMonthEndpoint(type, year, month)),
      headers: headers,
    );
  }

  Future<http.Response> getNodeLastReading(String nodeId) async {
    final headers = await _getHeaders();
    return await _client.get(
      Uri.parse(AppConfig.nodeLastReadingEndpoint(nodeId)),
      headers: headers,
    );
  }

  Future<http.Response> getNodeTypeReadingByYear(
    String typeOrId,
    int year,
  ) async {
    final headers = await _getHeaders();
    return await _client.get(
      Uri.parse(AppConfig.nodeTypeReadingByYear(typeOrId, year)),
      headers: headers,
    );
  }
}
