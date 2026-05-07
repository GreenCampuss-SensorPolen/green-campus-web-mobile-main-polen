// =============================================================
// widgetValorYGraf.dart
//
// Widget reutilizable: Gauge radial para sensores del edificio.
// Sin dependencias externas — solo Flutter SDK.
//
// ── INSTALACIÓN ───────────────────────────────────────────────
//  No requiere paquetes adicionales en pubspec.yaml.
//
// ── USO ───────────────────────────────────────────────────────
//
//   SensorGaugeCard(
//     sensorType: SensorType.temperatura,
//     sensorName: 'Aula 101',             // opcional
//     fetchValue: () async {
//       final data = await sensorRepository.getReading(sensorId);
//       return data.value;                 // double
//     },
//     refreshInterval: Duration(seconds: 30), // opcional, default 30 s
//   )
//
// ── PREVISUALIZACIÓN SIN API ───────────────────────────────────
//
//   MaterialApp(home: SensorGaugeDemo())
//
// =============================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────

enum SensorType { temperatura, humedad, matrizTermica, calidadAire }

enum SensorStatus { low, normal, warning, danger, offline }

// ─────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────

/// Zona de color en el arco del gauge.
class GaugeZone {
  final double start; // valor absoluto en unidades del sensor
  final double end;
  final Color color;

  const GaugeZone({
    required this.start,
    required this.end,
    required this.color,
  });
}

/// Configuración estática de cada tipo de sensor.
class SensorConfig {
  final String defaultName;
  final String emoji;
  final String unit;
  final double minValue;
  final double maxValue;

  /// Rango óptimo de operación (se muestra bajo el header).
  final double optimalMin;
  final double optimalMax;

  /// Fracción [0–1] del rango a partir de la cual se activa advertencia.
  final double warningFraction;

  /// Fracción [0–1] del rango a partir de la cual se activa peligro.
  final double dangerFraction;

  /// Valor absoluto por debajo del cual el estado es "bajo" (opcional).
  final double? lowThreshold;

  final List<GaugeZone> zones;

  const SensorConfig({
    required this.defaultName,
    required this.emoji,
    required this.unit,
    this.minValue = 0,
    required this.maxValue,
    required this.optimalMin,
    required this.optimalMax,
    required this.warningFraction,
    required this.dangerFraction,
    this.lowThreshold,
    required this.zones,
  });

  SensorStatus statusFor(double value) {
    if (lowThreshold != null && value < lowThreshold!) return SensorStatus.low;
    final fraction = (value - minValue) / (maxValue - minValue);
    if (fraction >= dangerFraction) return SensorStatus.danger;
    if (fraction >= warningFraction) return SensorStatus.warning;
    return SensorStatus.normal;
  }
}

// ─────────────────────────────────────────────────────────────
// CONFIGURACIÓN DE SENSORES
// Ajusta maxValue, warningFraction y dangerFraction según los
// requisitos del edificio.
// ─────────────────────────────────────────────────────────────

const Map<SensorType, SensorConfig> kSensorConfigs = {
  SensorType.temperatura: SensorConfig(
    defaultName: 'Temperatura',
    emoji: '🌡️',
    unit: '°C',
    maxValue: 60,
    optimalMin: 18,
    optimalMax: 26,
    lowThreshold: 15,      // < 15 °C → Baja (azul)
    warningFraction: 0.55, // 33 °C
    dangerFraction: 0.80,  // 48 °C
    zones: [
      GaugeZone(start: 0,  end: 33, color: Color(0xFF4CAF50)),
      GaugeZone(start: 33, end: 48, color: Color(0xFFFF9800)),
      GaugeZone(start: 48, end: 60, color: Color(0xFFF44336)),
    ],
  ),
  SensorType.humedad: SensorConfig(
    defaultName: 'Humedad',
    emoji: '💧',
    unit: '%',
    maxValue: 100,
    optimalMin: 40,
    optimalMax: 60,
    warningFraction: 0.70, // 70 %
    dangerFraction: 0.90,  // 90 %
    zones: [
      GaugeZone(start: 0,  end: 70,  color: Color(0xFF2196F3)),
      GaugeZone(start: 70, end: 90,  color: Color(0xFFFF9800)),
      GaugeZone(start: 90, end: 100, color: Color(0xFF9C27B0)),
    ],
  ),
  SensorType.matrizTermica: SensorConfig(
    defaultName: 'Matriz Térmica',
    emoji: '🔥',
    unit: '°C',
    maxValue: 150,
    optimalMin: 20,
    optimalMax: 80,
    warningFraction: 0.50, // 75 °C
    dangerFraction: 0.75,  // 112.5 °C
    zones: [
      GaugeZone(start: 0,     end: 75,    color: Color(0xFFFFEB3B)),
      GaugeZone(start: 75,    end: 112.5, color: Color(0xFFFF5722)),
      GaugeZone(start: 112.5, end: 150,   color: Color(0xFFB71C1C)),
    ],
  ),
  SensorType.calidadAire: SensorConfig(
    defaultName: 'Calidad del Aire',
    emoji: '🌬️',
    unit: 'AQI',
    maxValue: 500,
    optimalMin: 0,
    optimalMax: 100,
    warningFraction: 0.30, // 150 AQI — Moderado
    dangerFraction: 0.60,  // 300 AQI — Insalubre
    zones: [
      GaugeZone(start: 0,   end: 150, color: Color(0xFF8BC34A)),
      GaugeZone(start: 150, end: 300, color: Color(0xFFFF9800)),
      GaugeZone(start: 300, end: 500, color: Color(0xFFF44336)),
    ],
  ),
};

// ─────────────────────────────────────────────────────────────
// EXTENSIONES
// ─────────────────────────────────────────────────────────────

extension SensorStatusX on SensorStatus {
  String get label => switch (this) {
        SensorStatus.low     => 'Baja',
        SensorStatus.normal  => 'Buena',
        SensorStatus.warning => 'Advertencia',
        SensorStatus.danger  => 'Peligro',
        SensorStatus.offline => 'Sin señal',
      };

  Color get color => switch (this) {
        SensorStatus.low     => const Color(0xFF2196F3),
        SensorStatus.normal  => const Color(0xFF4CAF50),
        SensorStatus.warning => const Color(0xFFFF9800),
        SensorStatus.danger  => const Color(0xFFF44336),
        SensorStatus.offline => const Color(0xFF9E9E9E),
      };

  IconData get icon => switch (this) {
        SensorStatus.low     => Icons.ac_unit_outlined,
        SensorStatus.normal  => Icons.check_circle_outline,
        SensorStatus.warning => Icons.warning_amber_outlined,
        SensorStatus.danger  => Icons.error_outline,
        SensorStatus.offline => Icons.wifi_off_outlined,
      };
}

// ─────────────────────────────────────────────────────────────
// WIDGET PRINCIPAL
// ─────────────────────────────────────────────────────────────

/// Tarjeta de sensor con gauge radial y actualización automática.
///
/// Diseñada para encajarse en un grid/lista dentro de la vista
/// de detalle de cada sensor. Gestiona su propio ciclo de vida
/// de polling; la capa de datos se inyecta vía [fetchValue].
class SensorGaugeCard extends StatefulWidget {
  const SensorGaugeCard({
    super.key,
    required this.sensorType,
    required this.fetchValue,
    required this.sensorId,
    required this.room,
    this.refreshInterval = const Duration(seconds: 30),
  });

  /// Tipo de sensor — determina emoji, unidad, colores y umbrales.
  final SensorType sensorType;

  /// Callback que retorna el valor actual del sensor.
  /// Debe ser provisto por el repositorio/servicio correspondiente.
  /// Ejemplo:
  ///   fetchValue: () => sensorRepo.getLatestReading(id),
  final Future<double> Function() fetchValue;

  /// Identificador único del sensor (se muestra en la cabecera izquierda).
  /// Ejemplo: 'SEN-042'
  final String sensorId;

  /// Nombre del espacio donde está instalado (se muestra en la cabecera derecha).
  /// Ejemplo: 'Aula 101'
  final String room;

  /// Intervalo de refresco automático. Default: 30 s.
  final Duration refreshInterval;

  @override
  State<SensorGaugeCard> createState() => _SensorGaugeCardState();
}

class _SensorGaugeCardState extends State<SensorGaugeCard>
    with SingleTickerProviderStateMixin {
  // ── Config ────────────────────────────────────────────────
  late final SensorConfig _config;

  // ── Estado ────────────────────────────────────────────────
  double? _currentValue;
  SensorStatus _status = SensorStatus.offline;
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;

  // ── Animación ─────────────────────────────────────────────
  late AnimationController _animController;
  late Animation<double> _gaugeAnim;
  final _valueTween = Tween<double>(begin: 0.0, end: 0.0);

  // ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _config = kSensorConfigs[widget.sensorType]!;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _gaugeAnim = _valueTween.animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    _startPolling();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _fetchValue();
    _refreshTimer =
        Timer.periodic(widget.refreshInterval, (_) => _fetchValue());
  }

  Future<void> _fetchValue() async {
    if (!mounted) return;

    // Solo muestra spinner en la primera carga
    if (_currentValue == null) setState(() => _isLoading = true);

    try {
      final raw = await widget.fetchValue();
      if (!mounted) return;

      final value =
          raw.clamp(_config.minValue, _config.maxValue).toDouble();

      // Anima suavemente desde el valor actual al nuevo
      _valueTween
        ..begin = _gaugeAnim.value
        ..end   = value;
      _animController.forward(from: 0);

      setState(() {
        _currentValue = value;
        _status       = _config.statusFor(value);
        _isLoading    = false;
        _error        = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error     = 'Error al obtener datos';
        _status    = SensorStatus.offline;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF1C2833) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 12),
            _buildGaugeArea(theme),
            if (_currentValue != null) ...[
              const SizedBox(height: 16),
              _buildStatusPill(),
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 10),
              _buildStatusMessage(theme),
              const SizedBox(height: 12),
              _buildOptimalSection(theme),
            ],
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme) {
    const labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Color(0xFFBDBDBD),
      letterSpacing: 0.5,
    );
    return Row(
      children: [
        Text(widget.sensorId, style: labelStyle),
        const Spacer(),
        Text(widget.room, style: labelStyle),
      ],
    );
  }

  // ── Gauge ─────────────────────────────────────────────────

  Widget _buildGaugeArea(ThemeData theme) {
    if (_isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _fetchValue);
    }

    final displayStr = _gaugeAnim.value % 1 == 0
        ? _gaugeAnim.value.toStringAsFixed(0)
        : _gaugeAnim.value.toStringAsFixed(1);

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Izquierda: emoji · valor · unidad en línea ─────
          SizedBox(
            width: 140,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: displayStr,
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                          color: _status.color,
                        ),
                      ),
                      TextSpan(
                        text: ' ${_config.unit}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── Derecha: gauge sin valor numérico ──────────────
          Expanded(
            child: SizedBox.expand(
              child: _GaugePainterWidget(
                value: _gaugeAnim.value,
                config: _config,
                statusColor: _status.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pill de estado ─────────────────────────────────────────

  Widget _buildStatusPill() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: _status.color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _status.label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Mensaje de estado ──────────────────────────────────────

  Widget _buildStatusMessage(ThemeData theme) {
    final name = _config.defaultName.toLowerCase();
    final msg = switch (_status) {
      SensorStatus.low     => 'La $name está por debajo del rango óptimo',
      SensorStatus.normal  => 'La $name está en rango óptimo',
      SensorStatus.warning => 'La $name está por encima del rango óptimo',
      SensorStatus.danger  => 'La $name está en niveles peligrosos',
      SensorStatus.offline => 'Sin conexión con el sensor',
    };
    return Text(
      msg,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.grey[500],
        fontSize: 12,
      ),
    );
  }

  // ── Sección nivel óptimo ───────────────────────────────────

  Widget _buildOptimalSection(ThemeData theme) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nivel óptimo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_config.optimalMin.toStringAsFixed(0)}° - '
              '${_config.optimalMax.toStringAsFixed(0)}°',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _status.color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _status.icon,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined,
              size: 40, color: theme.colorScheme.error),
          const SizedBox(height: 8),
          Text(message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: const Text('Reintentar', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// GAUGE PAINTER WIDGET
// ─────────────────────────────────────────────────────────────

class _GaugePainterWidget extends StatelessWidget {
  const _GaugePainterWidget({
    required this.value,
    required this.config,
    required this.statusColor,
  });

  final double value;
  final SensorConfig config;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GaugePainter(
        value: value,
        config: config,
        statusColor: statusColor,
      ),
      child: const SizedBox.expand(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CUSTOM PAINTER
// ─────────────────────────────────────────────────────────────

class _GaugePainter extends CustomPainter {
  final double value;
  final SensorConfig config;
  final Color statusColor;

  // Arco de 270°: comienza en la esquina inferior-izquierda (135°)
  // y termina en la esquina inferior-derecha (405° = 45°).
  // El punto más alto del arco está en la parte superior (270°).
  static const double _startAngle  = math.pi * 0.75; // 135°
  static const double _sweepTotal  = math.pi * 1.5;  // 270°
  static const double _strokeWidth = 16.0;

  _GaugePainter({
    required this.value,
    required this.config,
    required this.statusColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Centro ligeramente bajo para que el arco inferior tenga espacio
    final center = Offset(size.width / 2, size.height * 0.60);
    final radius = math.min(
      size.width  * 0.40,
      size.height * 0.32, // garantiza que el arco inferior no se recorte
    );

    final range    = config.maxValue - config.minValue;
    final fraction = ((value - config.minValue) / range).clamp(0.0, 1.0);

    // 1 ── Track de fondo ─────────────────────────────────────
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _startAngle, _sweepTotal, false,
      Paint()
        ..color       = const Color(0xFFE0E0E0)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap   = StrokeCap.round,
    );

    // 2 ── Zonas de color (semitransparentes) ─────────────────
    for (final zone in config.zones) {
      final zStart = _startAngle + _sweepTotal * ((zone.start - config.minValue) / range);
      final zSweep = _sweepTotal * ((zone.end  - zone.start)  / range);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        zStart, zSweep, false,
        Paint()
          ..color       = zone.color.withValues(alpha: 0.28)
          ..style       = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap   = StrokeCap.butt,
      );
    }

    // 3 ── Arco de progreso ───────────────────────────────────
    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _startAngle, _sweepTotal * fraction, false,
        Paint()
          ..color       = statusColor
          ..style       = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap   = StrokeCap.round,
      );
    }

    // 4 ── Tick marks ─────────────────────────────────────────
    _drawTicks(canvas, center, radius);

    // 5 ── Aguja ──────────────────────────────────────────────
    // La aguja arranca desde el borde del hub (r=13) para no
    // solaparse con el valor numérico pintado en el centro.
    final needleAngle  = _startAngle + _sweepTotal * fraction;
    final needleLength = radius - _strokeWidth / 2 - 2;
    const double hubEdge = 13.0;
    final needleStart = Offset(
      center.dx + hubEdge * math.cos(needleAngle),
      center.dy + hubEdge * math.sin(needleAngle),
    );
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    canvas.drawLine(
      needleStart, needleTip,
      Paint()
        ..color       = statusColor
        ..strokeWidth = 2.5
        ..strokeCap   = StrokeCap.round,
    );

    // Hub de la aguja
    canvas.drawCircle(center, 7.0, Paint()..color = statusColor);
    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    const int   totalTicks = 20;
    final double innerEdge = radius - _strokeWidth / 2 - 2;
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (int i = 0; i <= totalTicks; i++) {
      final isMajor   = i % 4 == 0;
      final angle     = _startAngle + _sweepTotal * (i / totalTicks);
      final outerR    = innerEdge;
      final innerR    = outerR - (isMajor ? 10.0 : 5.0);

      paint
        ..color       = isMajor ? Colors.grey.shade500 : Colors.grey.shade300
        ..strokeWidth = isMajor ? 1.8 : 1.0;

      canvas.drawLine(
        Offset(center.dx + outerR * math.cos(angle),
               center.dy + outerR * math.sin(angle)),
        Offset(center.dx + innerR * math.cos(angle),
               center.dy + innerR * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.statusColor != statusColor;
}

// ─────────────────────────────────────────────────────────────
// DEMO — eliminar o mover a un fichero de desarrollo en producción
// ─────────────────────────────────────────────────────────────

/// Widget de previsualización de un único sensor.
///
/// Cambia [sensorType] y el valor en [fetchValue] para probar
/// cada tipo antes de conectar la API real.
class SensorGaugeDemo extends StatelessWidget {
  const SensorGaugeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Sensor Gauge — Preview'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 320,
            child: SensorGaugeCard(
              sensorType: SensorType.temperatura, // ← cambia el tipo aquí
              sensorId: 'SEN-042',
              room: 'Aula 101',
              fetchValue: () async {
                await Future.delayed(const Duration(milliseconds: 600));
                return 24.0; // ← cambia el valor de prueba aquí
              },
            ),
          ),
        ),
      ),
    );
  }
}
