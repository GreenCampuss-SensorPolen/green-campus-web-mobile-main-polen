import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/widgets/sensor_bar_chart.dart';

/// Card acordeón genérico y reutilizable para cualquier tipo de sensor.
///
/// • Cerrado → [sensorName] izquierda + [currentValue] derecha.
/// • Abierto → [SensorBarChart] con [monthlyValues] (puede ser vacío).
///
/// Diseño: [BorderRadius.circular(25)], sombra suave flotante,
/// fondo blanco puro, barra de color lateral.
class SensorAccordionCard extends StatefulWidget {
  final String sensorName;
  final String location;
  final String currentValue;
  final List<double> monthlyValues;
  final Color accentColor;
  final Color barColorDark;
  final Color barColorLight;
  final Color trackColor;
  final double maxY;

  const SensorAccordionCard({
    super.key,
    required this.sensorName,
    required this.location,
    required this.currentValue,
    this.monthlyValues = const [],
    this.accentColor = AppColors.accentGreen,
    this.barColorDark = const Color(0xFF1565C0),
    this.barColorLight = const Color(0xFF42A5F5),
    this.trackColor = const Color(0xFFE3F2FD),
    this.maxY = 100,
  });

  @override
  State<SensorAccordionCard> createState() => _SensorAccordionCardState();
}

class _SensorAccordionCardState extends State<SensorAccordionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Fila del resumen ──────────────────────────────────────
                Row(
                  children: [
                    // Barra de color lateral
                    Container(
                      width: 4,
                      height: 42,
                      decoration: BoxDecoration(
                        color: widget.accentColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Nombre + ubicación
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.sensorName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Valor actual
                    Text(
                      widget.currentValue,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Chevron animado
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                        size: 22,
                      ),
                    ),
                  ],
                ),

                // ── Contenido expandible ──────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'HISTÓRICO MENSUAL',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 9,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 14),
                              SensorBarChart(
                                values: widget.monthlyValues,
                                barColorDark: widget.barColorDark,
                                barColorLight: widget.barColorLight,
                                trackColor: widget.trackColor,
                                maxY: widget.maxY,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
