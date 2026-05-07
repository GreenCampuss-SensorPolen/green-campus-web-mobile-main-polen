import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/models/technical_data.dart';
import 'package:mobile_app/data/services/technical_services.dart';
import 'package:mobile_app/data/services/token_storage.dart';

// ── Datos de prueba para cuando la API no esté disponible ─────────────────────
const String _mockReadingsJson = '''
[
  { "timestamp": "2026-03-16T00:00:00Z", "consumo_w": 10.5, "temp_c": 16.8 },
  { "timestamp": "2026-03-16T03:00:00Z", "consumo_w": 11.2, "temp_c": 16.5 },
  { "timestamp": "2026-03-16T06:00:00Z", "consumo_w": 14.8, "temp_c": 17.1 },
  { "timestamp": "2026-03-16T09:00:00Z", "consumo_w": 12.4, "temp_c": 17.2 },
  { "timestamp": "2026-03-16T12:00:00Z", "consumo_w": 13.1, "temp_c": 17.8 },
  { "timestamp": "2026-03-16T15:00:00Z", "consumo_w": 15.3, "temp_c": 18.2 },
  { "timestamp": "2026-03-16T18:00:00Z", "consumo_w": 11.9, "temp_c": 17.6 },
  { "timestamp": "2026-03-16T21:00:00Z", "consumo_w": 10.2, "temp_c": 16.9 }
]
''';

// ── Página principal del Dashboard IoT ───────────────────────────────────────
//
// Recibe un [IotNode] con la información actual del dispositivo y obtiene
// las lecturas históricas de las últimas 24h desde la API de lecturas.
// Si la API no está disponible, carga datos de prueba como fallback.
//
// Navegación: '/iot-dashboard' con arguments: IotNode
class IoTDashboardPage extends StatefulWidget {
  final IotNode node;

  const IoTDashboardPage({super.key, required this.node});

  @override
  State<IoTDashboardPage> createState() => _IoTDashboardPageState();
}

class _IoTDashboardPageState extends State<IoTDashboardPage> {
  String _userName = 'Usuario';
  List<IotReading> _readings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _fetchUserName(),
      _fetchReadings(),
    ]);

    if (!mounted) return;
    setState(() {
      _userName = results[0] as String;
      _readings = results[1] as List<IotReading>;
      _loading = false;
    });
  }

  Future<String> _fetchUserName() async {
    final firstName = await TokenStorage.getFirstName();
    final lastName = await TokenStorage.getLastName();
    if (firstName == null && lastName == null) return 'Usuario';
    return [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');
  }

  Future<List<IotReading>> _fetchReadings() async {
    try {
      final response = await TechnicalServices().getNodeReadings(widget.node.id, limit: 24);
      if (response.statusCode == 200) {
        final List<dynamic> raw = jsonDecode(response.body);
        return raw.map((e) => IotReading.fromJson(e)).toList();
      }
      return _mockReadings();
    } catch (_) {
      return _mockReadings();
    }
  }

  List<IotReading> _mockReadings() {
    final raw = jsonDecode(_mockReadingsJson) as List<dynamic>;
    return raw.map((e) => IotReading.fromJson(e)).toList();
  }

  // ── Reglas de color (misma lógica que el proyecto prueba) ─────────────────

  Color _batteryColor(int pct) {
    if (pct >= 70) return AppColors.statusOnline;
    if (pct >= 25) return AppColors.statusWarning;
    return const Color.fromARGB(255, 239, 68, 68);
  }

  // ≤1.5 kW verde, >1.5 kW rojo
  Color _energyColor(double val) =>
      val <= 1.5 ? AppColors.statusOnline : AppColors.statusOffline;

  Color _humidityColor(double pct) {
    if (pct >= 30 && pct <= 60) return AppColors.statusOnline;
    if (pct >= 20 && pct <= 70) return AppColors.statusWarning;
    return AppColors.statusOffline;
  }

  Color _tempColor(double t) =>
      t <= 65 ? AppColors.statusOnline : AppColors.statusOffline;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6F5),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F5),
        body: Center(child: Text('Error: $_error')),
      );
    }

    final node = widget.node;
    final telemetry = node.lastTelemetry;
    final energy = telemetry?.energy ?? 0.0;
    final temp = telemetry?.temperature ?? 0.0;
    final humidity = telemetry?.humidity ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: Column(
        children: [
          _Header(userName: _userName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DeviceCard(node: node),
                  const SizedBox(height: 20),
                  const Text(
                    'Datos generales',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MetricsGrid(
                    battery: node.battery,
                    energy: energy,
                    humidity: humidity,
                    temperature: temp,
                    batteryColor: _batteryColor(node.battery),
                    energyColor: _energyColor(energy),
                    humidityColor: _humidityColor(humidity),
                    tempColor: _tempColor(temp),
                  ),
                  const SizedBox(height: 24),
                  _ChartCard(readings: _readings),
                  const SizedBox(height: 16),
                  _BackBtn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Color(0xFF1A2E1A), size: 22),
          const SizedBox(width: 8),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 8),
          const Text(
            'Green Campus',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            userName,
            style: const TextStyle(fontSize: 11, color: Color(0xFF111111)),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.accentGreen,
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta del dispositivo ───────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final IotNode node;
  const _DeviceCard({required this.node});

  @override
  Widget build(BuildContext context) {
    final isOnline = node.status.toUpperCase() == 'ONLINE';
    final dotColor = isOnline ? AppColors.statusOnline : AppColors.statusOffline;
    final badgeBg = isOnline ? AppColors.statusOnlineBg : const Color(0xFFFEE2E2);
    final textColor = isOnline ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ID del dispositivo',
                    style: TextStyle(color: Color(0xFF777777), fontSize: 11),
                  ),
                  Text(
                    node.id,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      node.status,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE5EDE8), height: 20),
          const Text(
            'Ubicación',
            style: TextStyle(color: Color(0xFF777777), fontSize: 11),
          ),
          Text(
            node.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE5EDE8), height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 13, color: Color(0xFF8E9E93)),
              const SizedBox(width: 5),
              Text(
                '${node.planta} – ${node.edificio}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Grid de métricas ──────────────────────────────────────────────────────────

class _MetricsGrid extends StatelessWidget {
  final int battery;
  final double energy;
  final double humidity;
  final double temperature;
  final Color batteryColor;
  final Color energyColor;
  final Color humidityColor;
  final Color tempColor;

  const _MetricsGrid({
    required this.battery,
    required this.energy,
    required this.humidity,
    required this.temperature,
    required this.batteryColor,
    required this.energyColor,
    required this.humidityColor,
    required this.tempColor,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _BatteryCard(pct: battery.toDouble(), color: batteryColor),
        _IconMetricCard(
          label: 'Consumo',
          value: '${energy.toStringAsFixed(1)} W',
          icon: Icons.flash_on,
          statusColor: energyColor,
        ),
        _IconMetricCard(
          label: 'Estado',
          value: '${humidity.toStringAsFixed(1)}%',
          icon: Icons.wifi,
          statusColor: humidityColor,
        ),
        _IconMetricCard(
          label: 'Temperatura',
          value: '${temperature.toStringAsFixed(1)} °C',
          icon: Icons.thermostat,
          statusColor: tempColor,
        ),
      ],
    );
  }
}

// ── Tarjeta batería con anillo ─────────────────────────────────────────────────

class _BatteryCard extends StatelessWidget {
  final double pct;
  final Color color;
  const _BatteryCard({required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _RingPainter(
                progress: pct / 100,
                color: color,
                bgColor: color.withValues(alpha: 0.25),
              ),
              child: Center(
                child: Text(
                  '${pct.toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Batería',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta métrica con icono ─────────────────────────────────────────────────

class _IconMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color statusColor;

  const _IconMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      backgroundColor: statusColor.withValues(alpha: 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gráfica de rendimiento 24h ────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final List<IotReading> readings;
  const _ChartCard({required this.readings});

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rendimiento últimas 24h',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _dot(AppColors.accentGreen, 'Consumo energético'),
              const SizedBox(width: 14),
              _dot(AppColors.statusWarning, 'Temperatura'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: readings.isEmpty
                ? const Center(
                    child: Text(
                      'Sin lecturas disponibles',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      barGroups: readings.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.consumoW ?? 0,
                              color: AppColors.accentGreen,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: e.value.tempC ?? 0,
                              color: AppColors.statusWarning,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: const FlTitlesData(show: false),
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: Color(0xFFE8F0EC),
                          strokeWidth: 1,
                        ),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

// ── Botón Volver ──────────────────────────────────────────────────────────────

class _BackBtn extends StatelessWidget {
  const _BackBtn();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back, color: Color(0xFF6B7280), size: 18),
        label: const Text(
          'Volver',
          style:
              TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE5E7EB),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ── Wrapper de tarjeta ────────────────────────────────────────────────────────

class _CardWrapper extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const _CardWrapper({
    required this.child,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Anillo de batería (CustomPainter) ─────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.13;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
