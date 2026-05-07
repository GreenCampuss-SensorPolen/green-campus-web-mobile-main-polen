import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/models/technical_data.dart';
import 'package:mobile_app/data/services/auth_service.dart';
import 'package:mobile_app/data/services/token_storage.dart';
import 'package:mobile_app/widgets/common_app_drawer.dart';
import 'package:mobile_app/widgets/common_app_header.dart';
import 'valor_gauge_sensor.dart';
import 'panel_control_sensor.dart';
import 'mesual_anual_graficos_sensor.dart';

/// Vista de detalle de un sensor concreto.
/// Muestra el gauge de valor actual y el panel de control/salud
/// apilados en un scroll vertical.
class SensorDetailPage extends StatefulWidget {
  final IotNode node;

  const SensorDetailPage({super.key, required this.node});

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  String? _userName;
  String? _lastName;
  String? _userEmail;
  String? _role;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // ignore: slash_for_doc_comments
  /**
 * Este método no es necesario, puedes tirar del controlador TechnicalDashboardController para sacar los datos del usuario
 * y asñi evitar repetición de código.
 */
  Future<void> _loadUserProfile() async {
    final results = await Future.wait([
      TokenStorage.getFirstName(),
      TokenStorage.getLastName(),
      TokenStorage.getEmail(),
      TokenStorage.getRole(),
      TokenStorage.getProfileImage(),
    ]);
    if (!mounted) return;
    setState(() {
      _userName = results[0];
      _lastName = results[1];
      _userEmail = results[2];
      _role = results[3];
      _profileImageUrl = results[4];
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    try {
      await authService.logout().timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Error en logout del servidor: $e');
    }
    await TokenStorage.clearSession();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  /// Mapea el tipo de nodo (texto libre de la API) al enum [SensorType].
  SensorType _sensorType() {
    final t = widget.node.type.toLowerCase();
    if (t.contains('humedad')) return SensorType.humedad;
    if (t.contains('calidad')) return SensorType.calidadAire;
    if (t.contains('matriz') ||
        t.contains('termica') ||
        t.contains('térmica')) {
      return SensorType.matrizTermica;
    }
    return SensorType.temperatura; // default
  }

  /// Extrae el valor numérico actual de la telemetría del nodo.
  double _currentValue() {
    final t = widget.node.type.toLowerCase();
    if (t.contains('humedad'))
      // ignore: curly_braces_in_flow_control_structures
      return widget.node.lastTelemetry?.humidity ?? 0.0;
    if (t.contains('calidad'))
      // ignore: curly_braces_in_flow_control_structures
      return widget.node.lastTelemetry?.co2?.toDouble() ?? 0.0;
    return widget.node.lastTelemetry?.temperature ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final sensorType = _sensorType();
    final config = kSensorConfigs[sensorType]!;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      drawer: CommonAppDrawer(
        userName: _userName ?? 'Usuario',
        lastName: _lastName ?? '',
        userEmail: _userEmail ?? '',
        role: _role ?? '',
        profileImageUrl: _profileImageUrl,
        onLogout: () => _handleLogout(context),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header común de la app ─────────────────────────
            CommonAppHeader(
              userName: _userName ?? 'Usuario',
              profileImageUrl: _profileImageUrl,
            ),
            // ── Contenido del sensor ───────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Gauge de valor actual ──────────────────────
                  SensorGaugeCard(
                    sensorType: sensorType,
                    sensorId: widget.node.id,
                    room: widget.node.location,
                    fetchValue: () async =>
                        _currentValue(), // ← reemplazar por llamada real a la API
                  ),
                  const SizedBox(height: 16),
                  // ── Panel de control y salud ───────────────────
                  SensorControlPanel(healthData: SensorHealthData.simulated()),
                  const SizedBox(height: 16),
                  // ── Actividad mensual (últimos 30 días) ────────
                  MonthlyActivityCard(
                    sensorName: config.defaultName,
                    unit: config.unit,
                    optimalMin: config.optimalMin,
                    optimalMax: config.optimalMax,
                    // readings: ← reemplazar con datos reales de la API
                  ),
                  const SizedBox(height: 16),
                  // ── Histórico anual ────────────────────────────
                  AnnualHistoryCard(
                    sensorName: config.defaultName,
                    unit: config.unit,
                    optimalMin: config.optimalMin,
                    optimalMax: config.optimalMax,
                    // data: ← reemplazar con datos reales de la API
                    // year: ← reemplazar con el año actual de la API
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
