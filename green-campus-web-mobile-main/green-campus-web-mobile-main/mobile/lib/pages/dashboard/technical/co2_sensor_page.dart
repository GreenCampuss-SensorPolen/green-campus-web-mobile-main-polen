import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/models/technical_data.dart';
import 'package:mobile_app/logic/dashboard/co2_controller.dart';
import 'package:mobile_app/widgets/sensor_accordion_card.dart';

// ─── Paleta de colores de CO2 (Verdes) ─────────────────────────────────
const _kCo2Primary = Color(0xFF00C853); // Verde fuerte (Éxito)
const _kCo2Mid = Color(0xFF69F0AE); // Verde menta (Medio)
const _kCo2Pale = Color(0xFFE8F5E9); // Verde muy pálido (Fondo/Pista)
const _kCo2Bg = Color(0xFFF9FFF9); // Fondo de página muy suave

// ─── Page ─────────────────────────────────────────────────────────────────────

class Co2SensorPage extends StatefulWidget {
  const Co2SensorPage({super.key});

  @override
  State<Co2SensorPage> createState() => _Co2SensorPageState();
}

class _Co2SensorPageState extends State<Co2SensorPage> {
  late final Co2Controller _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = Co2Controller();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Lee los nodos pasados como argumento
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
      backgroundColor: _kCo2Bg,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(_kCo2Primary),
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
      backgroundColor: _kCo2Bg,
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
        'Calidad del Aire (CO2)',
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
        child: _Co2AverageHeader(average: _controller.averageCo2),
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
                Icons.air_rounded,
                size: 52,
                color: _kCo2Mid..withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin sensores de CO2',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
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
          final double? val = _controller.co2LevelOf(node);

          return SensorAccordionCard(
            sensorName: node.name,
            location: '${node.edificio} · ${node.planta}',
            currentValue: val != null ? '${val.toInt()} ppm' : '--',
            monthlyValues: _controller.monthlyHistory(node.id),
            accentColor: val != null ? _co2Color(val) : AppColors.textMuted,
            barColorDark: _kCo2Primary,
            barColorLight: _kCo2Mid,
            trackColor: _kCo2Pale,
            maxY: 1500, // Escala habitual para CO2
          );
        }, childCount: nodes.length),
      ),
    );
  }

  Color _co2Color(double v) {
    if (v > 1000) return Colors.redAccent; // Mala ventilación
    if (v > 750) return Colors.orangeAccent; // Precaución
    return _kCo2Primary; // Excelente
  }
}

// ─── Widget específico de esta Page ────────────

class _Co2AverageHeader extends StatelessWidget {
  final double? average;
  static const double _maxVisual = 1500.0;

  const _Co2AverageHeader({required this.average});

  @override
  Widget build(BuildContext context) {
    final hasData = average != null;
    final fraction = hasData ? (average! / _maxVisual).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black..withValues(alpha: 0.5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chip de categoría ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kCo2Pale,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.air_rounded, color: _kCo2Primary, size: 13),
                SizedBox(width: 5),
                Text(
                  'Calidad del Aire',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kCo2Primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Media de CO2 en el campus',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 20),

          // ── Fila Principal CORREGIDA (Sin desbordamiento) ──────────────
          Row(
            children: [
              // Recuadro del valor con Expanded para que sea flexible
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: _kCo2Pale,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasData ? _kCo2Primary : AppColors.inputBorder,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasData ? '${average!.toInt()} ppm' : '--',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: hasData ? _kCo2Primary : AppColors.textMuted,
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
              ),

              const SizedBox(width: 12),

              // Donut PieChart con Flexible
              Flexible(
                flex: 2,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 0,
                          centerSpaceRadius: 35,
                          sections: [
                            PieChartSectionData(
                              value: fraction * 100,
                              color: hasData
                                  ? _kCo2Primary
                                  : AppColors.inputBorder,
                              radius: 11,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: (1 - fraction) * 100,
                              color: _kCo2Mid..withValues(alpha: 0.5),
                              radius: 11,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_queue_rounded,
                            size: 14,
                            color: hasData ? _kCo2Primary : AppColors.textMuted,
                          ),
                          Text(
                            hasData ? '${(fraction * 100).toInt()}%' : '--',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: hasData ? _kCo2Primary : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(double v) {
    late Color color;
    late String label;
    late IconData icon;

    if (v > 1000) {
      color = Colors.redAccent;
      label = 'Ventilar ahora';
      icon = Icons.warning_amber_rounded;
    } else if (v > 750) {
      color = Colors.orangeAccent;
      label = 'Aire aceptable';
      icon = Icons.info_outline_rounded;
    } else {
      color = _kCo2Primary;
      label = 'Aire óptimo';
      icon = Icons.verified_user_outlined;
    }

    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
