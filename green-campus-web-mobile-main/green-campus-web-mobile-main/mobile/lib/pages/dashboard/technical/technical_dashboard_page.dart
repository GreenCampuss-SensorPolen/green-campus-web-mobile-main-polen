import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/services/auth_service.dart';
import 'package:mobile_app/data/services/token_storage.dart';
import 'package:mobile_app/logic/dashboard/technical_dashboard_controller.dart';
import 'package:mobile_app/widgets/common_app_drawer.dart';
import 'package:mobile_app/widgets/common_app_header.dart';

class TechnicalDashboardPage extends StatefulWidget {
  const TechnicalDashboardPage({super.key});

  @override
  State<TechnicalDashboardPage> createState() => _TechnicalDashboardPageState();
}

class _TechnicalDashboardPageState extends State<TechnicalDashboardPage> {
  late final TechnicalDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TechnicalDashboardController();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose(); // Limpiar recursos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        // Mantenemos un único Scaffold para evitar el crash de reconstrucción pesada
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          // El Drawer ahora siempre está disponible y escucha al controlador
          drawer: CommonAppDrawer(
            userName: _controller.userName ?? 'Usuario',
            lastName: _controller.lastName ?? 'Apellido',
            userEmail: _controller.userEmail ?? '',
            role: _controller.role ?? '',
            profileImageUrl: _controller.profileImageUrl,
            onLogout: () => _handleLogout(context),
          ),
          body: SafeArea(
            child: _controller.isLoading && _controller.nodes.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  ) // Solo el centro cambia
                : RefreshIndicator(
                    onRefresh: () => _controller.fecthDashboardData(),
                    child: CustomScrollView(
                      slivers: [
                        CommonAppHeader(
                          userName: _controller.userName ?? 'Usuario',
                          profileImageUrl: _controller.profileImageUrl,
                          showNotificationsBell: true,
                          onNotificationsTap: () =>
                              Navigator.pushNamed(context, '/notifications'),
                        ),
                        ..._buildSlivers(),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  // Lógica de destrucción de sesión
  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();

    try {
      // Se intenta avisar al back (petición "fire and forget" con timeout corto)
      await authService.logout().timeout(const Duration(seconds: 4));
    } catch (e) {
      // Si falla el servidor o no hay red, seguimos igual: la prioridad es borrar lo local
      debugPrint('Error en logout del servidor: $e');
    }

    // Borrado de los datos en el dispositivos
    await TokenStorage.clearSession();

    if (!context.mounted) return;

    // Navegación radical: Se borra todo el historial para que no se pueda vilver atrás
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  List<Widget> _buildSlivers() {
    // final nodes = _controller.nodes;
    final nodesHardware = _controller.nodes.where((node) {
      final type = node.type.toString().toUpperCase();
      return type == "RASPBERRY" || type == "ARDUINO";
    }).toList();

    return [
      // Sección estática: resumen + sensores (pocos widgets, OK eager)
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            _buildSectionHeader(
              'Resumen de Infraestructura',
              subtitle: 'hace 30s',
            ),
            const SizedBox(height: 16),
            _buildSummaryCards(),
            const SizedBox(height: 32),
            _buildSectionHeader('Sensores en tiempo real', isLive: true),
            const SizedBox(height: 16),
            _buildSensorsGrid(),
            const SizedBox(height: 32),
            _buildSectionHeader(
              'Inventario de Dispositivos',
              count: '${nodesHardware.length} nodos',
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),

      // Contenedor del inventario: lazy — solo construye los nodos visibles
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final node = nodesHardware[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                border: Border(
                  bottom: index < nodesHardware.length - 1
                      ? const BorderSide(color: AppColors.borderLight, width: 1)
                      : BorderSide.none,
                ),
              ),
              child: _buildNodeItem(node),
            );
          }, childCount: nodesHardware.length),
        ),
      ),
    ];
  }

  // Widget auxiliar para los títulos de sección
  Widget _buildSectionHeader(
    String title, {
    String? subtitle,
    bool isLive = false,
    String? count,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        if (isLive)
          _buildLiveChip() // Se verá este pequeño widget abajo
        else if (subtitle != null || count != null)
          Text(
            subtitle ?? count!,
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 9,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }

  Widget _buildLiveChip() {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.secondsNotifier,
      builder: (context, seconds, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.statusOnlineBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.statusOnline,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${seconds}s',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.statusOnline,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    final nodes = _controller.nodes;
    final total = nodes.length;
    final online = nodes
        .where((n) => n.status.toUpperCase() == 'ONLINE')
        .length;
    final alerts = nodes.where((n) {
      final s = n.status.toUpperCase();
      return s == 'STANDBY' || s == 'OFFLINE';
    }).length;

    return Row(
      children: [
        _buildStatCard(
          '$total',
          'Nodos Total',
          Icons.table_chart_rounded,
          AppColors.textMuted,
          AppColors.surface,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '$online',
          'En Línea',
          Icons.bolt,
          AppColors.statusOnline,
          AppColors.statusOnlineBg,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '$alerts',
          'Alertas',
          Icons.warning_amber_rounded,
          AppColors.statusWarning,
          AppColors.statusWarningBg,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorsGrid() {
    final temp = _controller.avgTemperatura;
    final hum = _controller.avgHumedad;
    final co2 = _controller.avgCo2;
    final energ = _controller.avgEnergia;

    return SizedBox(
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
        children: [
          _buildSensorCard(
            'Temperatura',
            temp != null ? '${temp.toStringAsFixed(1)}°C' : '--',
            Icons.thermostat,
            Colors.orange,
            onTap: () => Navigator.pushNamed(
              context,
              '/sensor-temperatura',
              arguments: _controller.nodes,
            ),
          ),
          _buildSensorCard(
            'Humedad',
            hum != null ? '${hum.toStringAsFixed(1)}%' : '--',
            Icons.water_drop,
            Colors.blue,
            onTap: () => Navigator.pushNamed(
              context,
              '/sensor-humedad',
              arguments: _controller.nodes,
            ),
          ),
          _buildSensorCard(
            'CO2 Ambiente',
            co2 != null ? '${co2.toStringAsFixed(0)} ppm' : '--',
            Icons.air,
            Colors.purple,
            onTap: () => Navigator.pushNamed(
              context,
              '/sensor-CO2',
              arguments: _controller.nodes,
            ),
          ),
          _buildSensorCard(
            'Energía',
            energ != null ? '${energ.toStringAsFixed(1)} W' : '--',
            Icons.bolt,
            Colors.amber,
            onTap: () => Navigator.pushNamed(
              context,
              '/sensor-energia',
              arguments: _controller.nodes,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    String label,
    String value,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(
          12,
        ), // Un poco menos de padding para ganar espacio
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const Spacer(),
            // Ajuste dinámico para que el texto NO desborde
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              overflow:
                  TextOverflow.ellipsis, // Si el nombre es largo, pone "..."
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeItem(dynamic node) {
    // node es el tipo de IoTNode
    return InkWell(
      // Se define la acción al tocar
      onTap: () {
        Navigator.pushNamed(
          context,
          '/iot-dashboard',
          arguments: node,
        );
      },
      // Estilo visual
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Punto de estado (SEMÁFORO)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(node.status),
              ),
            ),
            const SizedBox(width: 12),
            // Información previa del dispositivo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${node.name} · ${node.location}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${node.type}  ·  ${node.status}  · ',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const Icon(
                        Icons.battery_charging_full_rounded,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      Text(
                        ' ${node.battery}%',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Icono de indicador de que es clicable, esto es opcional pero recomendable por UX
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Lógica de colores para el estado del hardware
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return AppColors.statusOnline;
      case 'STANDBY':
        return AppColors.statusWarning;
      case 'OFFLINE':
        return AppColors.statusOffline;
      default:
        return AppColors.textMuted;
    }
  }
}