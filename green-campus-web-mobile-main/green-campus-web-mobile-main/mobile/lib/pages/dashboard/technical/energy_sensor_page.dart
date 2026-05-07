import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/models/technical_data.dart';
import 'package:mobile_app/logic/dashboard/energia_controller.dart';
import 'package:mobile_app/widgets/sensor_accordion_card.dart';

// ─── Paleta de colores de energía  ─────────────────────────────────
const _kEnergyPrimary = Color(0xFFFFB300);   // amber intenso
const _kEnergyMid     = Color(0xFFFFCA28);   // amber medio
const _kEnergyPale    = Color(0xFFFFF8E1);   // amber muy pálido
const _kEnergyBg      = Color(0xFFFFFBF5);   // fondo cálido base

// ─── Page ─────────────────────────────────────────────────────────────────────

class EnergySensorPage extends StatefulWidget {
  const EnergySensorPage({super.key});

  @override
  State<EnergySensorPage> createState() => _EnergySensorPageState();
}

class _EnergySensorPageState extends State<EnergySensorPage> {
  late final EnergiaController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = EnergiaController();
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
      backgroundColor: _kEnergyBg,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(_kEnergyPrimary),
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
      backgroundColor: _kEnergyBg,
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
        'Sensores de Energía',
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
        child: _EnergyAverageHeader(
          average: _controller.averageEnergy,
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
              Icon(Icons.bolt, size: 52, color: _kEnergyMid.withValues(alpha: 0.4)),
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
            final double? energy = _controller.energyOf(node);

            return SensorAccordionCard(
              sensorName: node.name,
              location: '${node.edificio} · ${node.planta}',
              currentValue: energy != null ? '${energy.toStringAsFixed(1)} W' : '--',
              monthlyValues: _controller.monthlyHistory(node.id),
              accentColor: energy != null ? _energyColor(energy) : AppColors.textMuted,
              // Sobrescribir colores del gráfico al parámetro amber
              barColorDark: _kEnergyPrimary,
              barColorLight: _kEnergyMid,
              trackColor: _kEnergyPale,
              maxY: 2000, // Máximo estimado para la gráfica
            );
          },
          childCount: nodes.length,
        ),
      ),
    );
  }

  Color _energyColor(double e) {
    if (e < 100) return AppColors.accentGreen;     // bajo consumo
    if (e > 800) return AppColors.statusWarning;   // alto consumo
    return _kEnergyPrimary;                        // consumo medio
  }
}

// ─── Widget específico de esta Page  ────────────

/// Header con recuadro de energía y donut 
class _EnergyAverageHeader extends StatelessWidget {
  final double? average;
  // Ajustar _maxEnergy según el entorno real, p. ej. 1000W para la demo de porcentaje
  static const double _maxEnergy = 1000.0;

  const _EnergyAverageHeader({required this.average});

  @override
  Widget build(BuildContext context) {
    final hasData = average != null;
    final fraction = hasData ? (average! / _maxEnergy).clamp(0.0, 1.0) : 0.0;

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
              color: _kEnergyPale,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: _kEnergyPrimary, size: 13),
                SizedBox(width: 5),
                Text(
                  'Sensor de Energía',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kEnergyPrimary,
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

          // ── Fila: recuadro W + donut ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Recuadro con borde amber ─────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: _kEnergyPale,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasData ? _kEnergyPrimary : AppColors.inputBorder,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasData ? '${average!.toStringAsFixed(1)} W' : '--',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 27, // Poco menor para que no desborde con W
                        fontWeight: FontWeight.bold,
                        color: hasData ? _kEnergyPrimary : AppColors.textMuted,
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

              // ── Donut PieChart fino en amber ─────────────────────────
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
                                ? _kEnergyPrimary
                                : AppColors.inputBorder,
                            radius: 13,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: (1 - fraction) * 100,
                            color: _kEnergyMid.withValues(alpha: 0.35),
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
                          hasData ? '${(fraction * 100).toStringAsFixed(0)}%' : '--',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: hasData ? _kEnergyPrimary : AppColors.textMuted,
                          ),
                        ),
                        const Text(
                          'uso red',
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

  Widget _buildStatusRow(double e) {
    late Color color;
    late String label;
    late IconData icon;

    if (e < 100) {
      color = AppColors.accentGreen;
      label = 'Bajo consumo';
      icon = Icons.eco_rounded;
    } else if (e > 800) {
      color = AppColors.statusWarning;
      label = 'Alto consumo';
      icon = Icons.warning_amber_rounded;
    } else {
      color = _kEnergyPrimary;
      label = 'Consumo normal';
      icon = Icons.bolt;
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
