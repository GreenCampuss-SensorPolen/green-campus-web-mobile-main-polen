import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/models/technical_data.dart';
import 'package:mobile_app/logic/dashboard/temperatura_controller.dart';
import 'package:mobile_app/widgets/sensor_accordion_card.dart';

// ─── Paleta de colores de temperatura  ─────────────────────────────────
const _kTempPrimary = Color(0xFFFF6D00);   // naranja intenso
const _kTempMid     = Color(0xFFFFAB40);   // naranja ámbar (degradado medio)
const _kTempPale    = Color(0xFFFFF3E0);   // naranja muy pálido (pista de barra)
const _kTempBg      = Color(0xFFFFFBF5);   // fondo de página cálido suave

// ─── Page ─────────────────────────────────────────────────────────────────────

class TemperatureSensorPage extends StatefulWidget {
  const TemperatureSensorPage({super.key});

  @override
  State<TemperatureSensorPage> createState() => _TemperatureSensorPageState();
}

class _TemperatureSensorPageState extends State<TemperatureSensorPage> {
  late final TemperaturaController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TemperaturaController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Lee los nodos pasados como argumento desde TechnicalDashboardPage.
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
      backgroundColor: _kTempBg,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(_kTempPrimary),
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

  // ── AppBar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: _kTempBg,
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
        'Sensores de Temperatura',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      sliver: SliverToBoxAdapter(
        child: _TemperatureAverageHeader(
          average: _controller.averageTemperature,
        ),
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
              Icon(Icons.sensors_off_rounded, size: 52, color: _kTempMid.withValues(alpha: 0.4)),
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
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final node = nodes[index];
            final double? temp = _controller.temperatureOf(node);

            return SensorAccordionCard(
              sensorName: node.name,
              location: '${node.edificio} · ${node.planta}',
              currentValue: temp != null ? '${temp.toStringAsFixed(1)}°C' : '--',
              monthlyValues: _controller.monthlyHistory(node.id),
              accentColor: temp != null ? _temperatureColor(temp) : AppColors.textMuted,
              // Sobrescribir colores del gráfico al parámetro naranja
              barColorDark: _kTempPrimary,
              barColorLight: _kTempMid,
              trackColor: _kTempPale,
              maxY: 40,
            );
          },
          childCount: nodes.length,
        ),
      ),
    );
  }

  Color _temperatureColor(double t) {
    if (t < 18) return Colors.blue.shade400;   // frío
    if (t > 26) return _kTempPrimary;          // calor
    return AppColors.accentGreen;              // confort
  }
}

// ─── Widget específico de esta Page  ────────────

/// Header con recuadro de temperatura y donut 
class _TemperatureAverageHeader extends StatelessWidget {
  final double? average;
  static const double _maxTemp = 40.0;

  const _TemperatureAverageHeader({required this.average});

  @override
  Widget build(BuildContext context) {
    final hasData = average != null;
    final fraction = hasData ? (average! / _maxTemp).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.13),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chip de categoría ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kTempPale,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thermostat_rounded, color: _kTempPrimary, size: 13),
                SizedBox(width: 5),
                Text(
                  'Sensor de Temperatura',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kTempPrimary,
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

          // ── Fila: recuadro °C + donut ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Recuadro con borde naranja ─────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: _kTempPale,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasData ? _kTempPrimary : AppColors.inputBorder,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasData ? '${average!.toStringAsFixed(1)}°C' : '--',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: hasData ? _kTempPrimary : AppColors.textMuted,
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

              // ── Donut PieChart fino en naranja ─────────────────────────
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
                                ? _kTempPrimary
                                : AppColors.inputBorder,
                            radius: 13,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: (1 - fraction) * 100,
                            color: _kTempMid.withValues(alpha: 0.35),
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
                          hasData ? '${average!.toStringAsFixed(0)}°C' : '--',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: hasData ? _kTempPrimary : AppColors.textMuted,
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

  Widget _buildStatusRow(double t) {
    late Color color;
    late String label;
    late IconData icon;

    if (t < 18) {
      color = Colors.blue.shade400;
      label = 'Temperatura baja';
      icon = Icons.ac_unit_rounded;
    } else if (t > 26) {
      color = _kTempPrimary;
      label = 'Temperatura alta';
      icon = Icons.local_fire_department_rounded;
    } else {
      color = AppColors.accentGreen;
      label = 'Confort térmico';
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
