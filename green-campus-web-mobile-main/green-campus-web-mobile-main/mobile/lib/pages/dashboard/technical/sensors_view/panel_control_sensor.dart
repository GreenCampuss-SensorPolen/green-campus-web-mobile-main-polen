import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Model
// ─────────────────────────────────────────────────────────────────────────────

class SensorHealthData {
  final String estado;
  final String conectividad;
  final int bateriaPct;
  final int rssiDbm;
  final DateTime? ultimaVez;
  final Duration uptime;
  final int linkQualityPct;
  final int intervalMuestraSeg;

  const SensorHealthData({
    required this.estado,
    required this.conectividad,
    required this.bateriaPct,
    required this.rssiDbm,
    this.ultimaVez,
    required this.uptime,
    required this.linkQualityPct,
    required this.intervalMuestraSeg,
  });

  factory SensorHealthData.simulated() => SensorHealthData(
        estado: 'OK',
        conectividad: 'Online',
        bateriaPct: 12,
        rssiDbm: -65,
        ultimaVez: DateTime.now().subtract(const Duration(minutes: 2)),
        uptime: const Duration(hours: 24),
        linkQualityPct: 92,
        intervalMuestraSeg: 30,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Main Widget
// ─────────────────────────────────────────────────────────────────────────────

class SensorControlPanel extends StatefulWidget {
  final SensorHealthData? healthData;

  const SensorControlPanel({super.key, this.healthData});

  @override
  State<SensorControlPanel> createState() => _SensorControlPanelState();
}

class _SensorControlPanelState extends State<SensorControlPanel> {
  bool _isOn = true;

  SensorHealthData get _data =>
      widget.healthData ?? SensorHealthData.simulated();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildControlHeader(),
          const SizedBox(height: 20),
          _buildHealthSection(),
        ],
      ),
    );
  }

  // ── Control header ──────────────────────────────────────────────────────────

  Widget _buildControlHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PANEL DE CONTROL DEL DISPOSITIVO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF424242),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _OutlinedActionButton(
              label: '↓  Bajar',
              onPressed: () {},
            ),
            const SizedBox(width: 10),
            _OutlinedActionButton(
              label: '↑  Subir',
              onPressed: () {},
            ),
            const SizedBox(width: 10),
            _PowerButton(
              isOn: _isOn,
              onPressed: () => setState(() => _isOn = !_isOn),
            ),
          ],
        ),
      ],
    );
  }

  // ── Health section ──────────────────────────────────────────────────────────

  Widget _buildHealthSection() {
    final d = _data;
    final lastSeen = _formatLastSeen(d.ultimaVez);
    final uptimeStr = _formatUptime(d.uptime);

    // Estado color
    final isOk = d.estado.toUpperCase() == 'OK';
    final estadoBg = isOk ? const Color(0xFFE8F5E9) : const Color(0xFFFFCDD2);
    final estadoValue = isOk ? '${d.estado}  ✓' : '${d.estado}  ✗';

    // Conectividad color
    final conLower = d.conectividad.toLowerCase();
    final Color conectBg;
    if (conLower == 'online') {
      conectBg = const Color(0xFFE8F5E9);
    } else if (conLower == 'degraded' || conLower == 'degradada') {
      conectBg = const Color(0xFFFFF9C4);
    } else {
      conectBg = const Color(0xFFFFCDD2);
    }

    // Battery color
    final Color battBg;
    if (d.bateriaPct <= 20) {
      battBg = const Color(0xFFFFCDD2);
    } else if (d.bateriaPct <= 50) {
      battBg = const Color(0xFFFFF9C4);
    } else {
      battBg = const Color(0xFFE8F5E9);
    }

    // RSSI color
    final Color rssiBg;
    if (d.rssiDbm < -80) {
      rssiBg = const Color(0xFFFFCDD2);
    } else if (d.rssiDbm < -65) {
      rssiBg = const Color(0xFFFFF9C4);
    } else {
      rssiBg = const Color(0xFFE8F5E9);
    }

    // Link Quality color
    final Color linkBg;
    if (d.linkQualityPct < 50) {
      linkBg = const Color(0xFFFFCDD2);
    } else if (d.linkQualityPct < 75) {
      linkBg = const Color(0xFFFFF9C4);
    } else {
      linkBg = const Color(0xFFE8F5E9);
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado y salud del dispositivo',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBDBDBD),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Row 1
          Row(
            children: [
              _HealthCard(
                label: 'Estado',
                value: estadoValue,
                bgColor: estadoBg,
              ),
              const SizedBox(width: 8),
              _HealthCard(
                label: 'Conectividad',
                value: d.conectividad,
                bgColor: conectBg,
              ),
              const SizedBox(width: 8),
              _HealthCard(
                label: 'Batería',
                value: '${d.bateriaPct}%',
                bgColor: battBg,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2
          Row(
            children: [
              _HealthCard(
                label: 'Señal RSSI',
                value: '${d.rssiDbm} dBm',
                bgColor: rssiBg,
              ),
              const SizedBox(width: 8),
              _HealthCard(
                label: 'Última vez',
                value: lastSeen,
                bgColor: Colors.white,
              ),
              const SizedBox(width: 8),
              _HealthCard(
                label: 'Uptime',
                value: uptimeStr,
                bgColor: const Color(0xFFE0F7FA),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 3
          Row(
            children: [
              _HealthCard(
                label: 'Link Quality',
                value: '${d.linkQualityPct}%',
                bgColor: linkBg,
              ),
              const SizedBox(width: 8),
              _HealthCard(
                label: 'Intervalo muestra',
                value: '${d.intervalMuestraSeg} seg',
                bgColor: Colors.white,
              ),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _formatLastSeen(DateTime? dt) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'hace ${diff.inSeconds} seg';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }

  String _formatUptime(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '${h}h ${m}m';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _OutlinedActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlinedActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF424242),
          side: const BorderSide(color: Color(0xFFBDBDBD), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _PowerButton extends StatelessWidget {
  final bool isOn;
  final VoidCallback onPressed;

  const _PowerButton({required this.isOn, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bg = isOn ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0);
    final fg = isOn ? Colors.white : const Color(0xFF757575);

    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOn ? Icons.toggle_on : Icons.toggle_off,
                size: 22,
                color: fg,
              ),
              const SizedBox(width: 4),
              Text(
                isOn ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bgColor;

  const _HealthCard({
    required this.label,
    required this.value,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Demo (para preview rápido)
// ─────────────────────────────────────────────────────────────────────────────

class SensorControlPanelDemo extends StatelessWidget {
  const SensorControlPanelDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 360,
            child: SensorControlPanel(
              healthData: SensorHealthData.simulated(),
            ),
          ),
        ),
      ),
    );
  }
}
