import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/models/technical_data.dart';
import 'package:mobile_app/logic/dashboard/humedad_controller.dart';
import 'package:mobile_app/widgets/sensor_accordion_card.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

class HumiditySensorPage extends StatefulWidget {
  const HumiditySensorPage({super.key});

  @override
  State<HumiditySensorPage> createState() => _HumiditySensorPageState();
}

class _HumiditySensorPageState extends State<HumiditySensorPage> {
  late final HumedadController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = HumedadController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Lee los nodos pasados como argumento desde TechnicalDashboardPage.
      // Esto evita cualquier llamada de red redundante.
      final args = ModalRoute.of(context)?.settings.arguments;
      final nodes = args is List<IotNode> ? args : <IotNode>[];
      _controller.init(nodes);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo gris suave para que las cards y el header "floten"
      backgroundColor: const Color(0xFFF4F6FA),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF1565C0)),
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildHeader(),
              _buildSectionLabel(),
              _buildAccordionList(),
            ],
          );
        },
      ),
    );
  }

  // ── SliverAppBar ──────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF4F6FA),
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 18,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Sensores de Humedad',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── Header con PieChart de fl_chart ──────────────────────────────────────

  Widget _buildHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      sliver: SliverToBoxAdapter(
        child: _HumidityAverageHeader(average: _controller.averageHumidity),
      ),
    );
  }

  // ── Etiqueta de sección ───────────────────────────────────────────────────

  Widget _buildSectionLabel() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SENSORES ACTIVOS',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '${_controller.nodes.length} nodos',
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 9,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Lista de acordeones ───────────────────────────────────────────────────

  Widget _buildAccordionList() {
    final nodes = _controller.nodes;

    if (nodes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sensors_off_rounded,
                size: 52,
                color: Colors.blue.shade100,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin sensores disponibles',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Los datos llegarán cuando\nel backend esté conectado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final node = nodes[index];
          final double? humidity = _controller.humidityOf(node);

          return SensorAccordionCard(
            sensorName: node.name,
            location: '${node.edificio} · ${node.planta}',
            currentValue: humidity != null ? '${humidity.toStringAsFixed(1)}%' : '--',
            monthlyValues: _controller.monthlyHistory(node.id),
            accentColor: humidity != null ? _humidityColor(humidity) : AppColors.textMuted,
          );
        }, childCount: nodes.length),
      ),
    );
  }

  Color _humidityColor(double v) {
    if (v < 45) return AppColors.statusWarning;
    if (v > 70) return const Color(0xFF1565C0);
    return AppColors.accentGreen;
  }
}

// ─── Widget específico de esta Page (no reutilizable → queda aquí) ────────────

/// Header con:
/// • Chip de categoría.
/// • Recuadro con borde azul definido que muestra el porcentaje en negrita.
/// • PieChart de fl_chart estilizado como donut muy fino en azul vibrante.
class _HumidityAverageHeader extends StatelessWidget {
  final double? average;
  const _HumidityAverageHeader({required this.average});

  @override
  Widget build(BuildContext context) {
    final hasData = average != null;
    final fraction = hasData ? (average! / 100).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.14),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chip de categoría ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  color: Color(0xFF1565C0),
                  size: 13,
                ),
                SizedBox(width: 5),
                Text(
                  'Sensor de Humedad',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Media de todos los sensores',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 20),

          // ── Fila: recuadro % + PieChart donut ─────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Recuadro con borde azul definido ─────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasData
                        ? const Color(0xFF1565C0)
                        : AppColors.inputBorder,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasData ? '${average!.toStringAsFixed(1)}%' : '--',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: hasData
                            ? const Color(0xFF1565C0)
                            : AppColors.textMuted,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    hasData
                        ? _buildStatusRow(average!)
                        : const Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 12, color: AppColors.textMuted),
                              SizedBox(width: 4),
                              Text(
                                'Sin datos hoy',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Donut PieChart muy fino ────────────────────────────────
              SizedBox(
                width: 114,
                height: 114,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                        centerSpaceRadius: 44,
                        sections: [
                          PieChartSectionData(
                            value: fraction * 100,
                            color: hasData
                                ? const Color(0xFF1565C0)
                                : AppColors.inputBorder,
                            radius: 13,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: (1 - fraction) * 100,
                            color: const Color(0xFFBBDEFB),
                            radius: 13,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasData ? '${average!.toStringAsFixed(0)}%' : '--',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: hasData
                                ? const Color(0xFF1565C0)
                                : AppColors.textMuted,
                          ),
                        ),
                        const Text(
                          'media',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(double v) {
    final Color color;
    final String label;
    final IconData icon;

    if (v < 45) {
      color = AppColors.statusWarning;
      label = 'Ambiente seco';
      icon = Icons.warning_amber_rounded;
    } else if (v > 70) {
      color = const Color(0xFF1565C0);
      label = 'Alta humedad';
      icon = Icons.water_drop_rounded;
    } else {
      color = AppColors.accentGreen;
      label = 'Nivel óptimo';
      icon = Icons.check_circle_outline_rounded;
    }

    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
