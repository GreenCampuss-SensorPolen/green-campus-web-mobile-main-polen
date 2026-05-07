import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';

/// Gráfico de barras mensual reutilizable para cualquier tipo de sensor.
///
/// Acepta [values] como lista de doubles (uno por día del mes).
/// Si la lista está vacía muestra un placeholder — diseñado así para funcionar
/// desde el primer día aunque el backend aún no proporcione histórico.
///
/// [labels] son los nombres del eje X. Si no se pasan, se usan los meses
/// del año en español por defecto.
class SensorBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColorDark;
  final Color barColorLight;
  final Color trackColor;
  final double maxY;
  final double height;

  static const _defaultLabels = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  const SensorBarChart({
    super.key,
    required this.values,
    this.labels = _defaultLabels,
    this.barColorDark = const Color(0xFF1565C0),
    this.barColorLight = const Color(0xFF42A5F5),
    this.trackColor = const Color(0xFFE3F2FD),
    this.maxY = 100,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 36,
                color: Colors.blue.shade100,
              ),
              const SizedBox(height: 8),
              const Text(
                'Histórico disponible próximamente',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayLabels =
        labels.length >= values.length ? labels : _defaultLabels;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          // ── Sin cuadrícula ──────────────────────────────────────────────
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          // ── Ejes ───────────────────────────────────────────────────────
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= values.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      displayLabels[index],
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // ── Barras con degradado azul ───────────────────────────────────
          barGroups: values.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [barColorLight, barColorDark],
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: trackColor,
                  ),
                ),
              ],
            );
          }).toList(),
          // ── Tooltip ────────────────────────────────────────────────────
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  const Color(0xFF1565C0).withValues(alpha: 0.92),
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(0)}%',
                  const TextStyle(
                    color: Colors.white,
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
