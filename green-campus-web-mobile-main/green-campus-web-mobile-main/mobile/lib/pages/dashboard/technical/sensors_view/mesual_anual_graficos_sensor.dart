// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  WIDGETS REUTILIZABLES - GreenCampus                                    ║
// ║                                                                         ║
// ║  Componentes para visualizar datos de sensores desde API externa.       ║
// ║  Todos los datos son parámetros — no hay datos hardcodeados.            ║
// ║                                                                         ║
// ║  Clases públicas:                                                       ║
// ║    1. SensorColors        → 4 niveles (verde/amarillo/naranja/rojo)     ║
// ║    2. SensorDato          → Modelo de medición individual               ║
// ║    3. SensorEstado        → Badge + descripción + referencia            ║
// ║    4. SensorCardWidget    → Widget principal (gráfico + info)           ║
// ║    5. DonutSensorGrafico  → Gráfico donut pluggable (sin emojis)       ║
// ║    6. MiniStat            → Estadística Mín/Prom/Máx                   ║
// ║    7. LeyendaGrafico      → Leyenda de gráfico                         ║
// ║                                                                         ║
// ║  Integración con API — ejemplo con FutureBuilder:                       ║
// ║    FutureBuilder<MisDatos>(                                             ║
// ║      future: miApi.fetchDatos(),                                        ║
// ║      builder: (ctx, snap) => SensorCardWidget(                          ║
// ║        grafico: DonutSensorGrafico(                                     ║
// ║          valor: snap.data?.aqi?.toDouble() ?? 0,                        ║
// ║          cargando: !snap.hasData,                                       ║
// ║          max: 500, color: SensorColors.colorPorAqi(snap.data?.aqi ?? 0),║
// ║          etiquetaCentro: 'AQI',                                         ║
// ║        ),                                                               ║
// ║        estado: snap.hasData ? SensorEstado(...) : null,                 ║
// ║        mediciones: snap.hasData                                         ║
// ║          ? [SensorDato(nombre: 'PM2.5', valor: '${snap.data!.pm25}',...)]║
// ║          : [SensorDato.cargando(nombre: 'PM2.5', ...)],                 ║
// ║      ),                                                                 ║
// ║    )                                                                    ║
// ║                                                                         ║
// ║  Dependencias: fl_chart ^0.69.2                                         ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  1. PALETA DE COLORES — 4 NIVELES              ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class SensorColors {
  // ── 4 niveles de contaminación/estado ──────────────────────────────────
  static const Color nivel1 = Color(0xFF70B74A);    // Verde claro  – Bueno
  static const Color nivel2 = Color(0xFFFFD600);    // Amarillo     – Moderado
  static const Color nivel3 = Color(0xFFFF7E00);    // Naranja      – Elevado
  static const Color nivel4 = Color(0xFFC2002F);    // Rojo marca   – Crítico

  // ── Colores de marca GreenCampus ────────────────────────────────────────
  // Fuente: identidad visual (Verde oscuro #268D38, Verde claro #70B74A, Rojo #C2002F)
  static const Color verde      = Color(0xFF268D38);  // Verde oscuro (primario)
  static const Color verdeClaro = Color(0xFF70B74A);  // Verde claro (secundario)
  static const Color rojo       = Color(0xFFC2002F);  // Rojo de marca

  // ── Colores de interfaz ─────────────────────────────────────────────────
  static const Color fondoCard = Colors.white;
  static const Color textoP    = Color(0xFF333333);  // Texto principal
  static const Color textoS    = Color(0xFF757575);  // Texto secundario
  static const Color fondo     = Color(0xFFF5F5F5);  // Fondo general
  static const Color acento    = Color(0xFF268D38);  // Acento = verde primario

  /// Color por porcentaje del rango [0, max], dividido en 4 cuartiles.
  /// Para sensores con escala propia (temperatura, humedad, etc.).
  static Color colorPorRango(double valor, double max) {
    final p = (valor / max).clamp(0.0, 1.0);
    if (p <= 0.25) return nivel1;
    if (p <= 0.50) return nivel2;
    if (p <= 0.75) return nivel3;
    return nivel4;
  }

  /// Etiqueta de texto para el nivel según rango.
  static String etiquetaPorRango(double valor, double max) {
    final p = (valor / max).clamp(0.0, 1.0);
    if (p <= 0.25) return 'Bueno';
    if (p <= 0.50) return 'Moderado';
    if (p <= 0.75) return 'Elevado';
    return 'Crítico';
  }

  /// Color para el índice AQI (escala 0–500 → 4 niveles).
  /// ≤50 verde | ≤100 amarillo | ≤150 naranja | >150 rojo.
  static Color colorPorAqi(int aqi) {
    if (aqi <= 50)  return nivel1;
    if (aqi <= 100) return nivel2;
    if (aqi <= 150) return nivel3;
    return nivel4;
  }

  /// Etiqueta de texto para el nivel AQI.
  static String etiquetaPorAqi(int aqi) {
    if (aqi <= 50)  return 'Buena';
    if (aqi <= 100) return 'Moderada';
    if (aqi <= 150) return 'Insalubre (sensibles)';
    return 'Insalubre';
  }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  2. MODELOS DE DATOS                                                    ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

/// Modelo para una medición individual de sensor.
///
/// Usa [valor] nullable para representar el estado de carga:
///   - valor = null   → dato pendiente de API (muestra skeleton)
///   - valor = String → dato disponible (muestra el valor)
///
/// Usa [destacado] = true para que aparezca como card grande en la primera fila.
class SensorDato {
  final String nombre;      // "PM2.5", "CO₂", "Temperatura"...
  final String? valor;      // null mientras carga desde API
  final String unidad;      // "µg/m³", "ppm", "°C"...
  final IconData icono;     // Icono Material representativo
  final Color color;        // Color del estado según umbrales del sensor
  final bool destacado;     // true → card grande, false → card pequeña en grid

  const SensorDato({
    required this.nombre,
    required this.valor,
    required this.unidad,
    required this.icono,
    required this.color,
    this.destacado = false,
  });

  /// Constructor para el estado de carga mientras la API responde.
  factory SensorDato.cargando({
    required String nombre,
    required String unidad,
    required IconData icono,
    bool destacado = false,
  }) =>
      SensorDato(
        nombre: nombre,
        valor: null,
        unidad: unidad,
        icono: icono,
        color: const Color(0xFFE0E0E0),
        destacado: destacado,
      );
}

/// Configuración del bloque de estado visible bajo el gráfico:
/// badge de nivel + descripción + recuadro de referencia óptima.
///
/// Pasa null en [SensorCardWidget.estado] para mostrar el skeleton de carga.
class SensorEstado {
  final String badgeTexto;        // "Buena", "Moderada", "Crítico"...
  final Color  badgeColor;        // Color del badge (SensorColors.nivelX)
  final String descripcion;       // Texto descriptivo bajo el badge
  final String referenciaLabel;   // "Nivel óptimo", "Umbral WHO"...
  final String referenciaValor;   // "< 50 AQI", "< 15 µg/m³"...
  final IconData referenciaIcono; // Icono del recuadro de referencia
  final Color  referenciaColor;   // Color del icono de referencia

  const SensorEstado({
    required this.badgeTexto,
    required this.badgeColor,
    required this.descripcion,
    required this.referenciaLabel,
    required this.referenciaValor,
    this.referenciaIcono = Icons.check_circle,
    this.referenciaColor = SensorColors.verde,
  });
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  3. WIDGET PRINCIPAL REUTILIZABLE                                       ║
// ║                                                                         ║
// ║  Estructura visual:                                                     ║
// ║  ┌───────────────────────────────────────────────────────────┐          ║
// ║  │  etiquetaTop (p.ej. "VALOR ACTUAL")                       │          ║
// ║  │  ┌─────────────────────────────────────────────────────┐  │          ║
// ║  │  │          grafico  (cualquier Widget)                │  │          ║
// ║  │  └─────────────────────────────────────────────────────┘  │          ║
// ║  │  [badge de estado]    descripcion                         │          ║
// ║  │  ┌─────────────────────────────────────────────────────┐  │          ║
// ║  │  │  referenciaLabel | referenciaValor          [icon]  │  │          ║
// ║  │  └─────────────────────────────────────────────────────┘  │          ║
// ║  └───────────────────────────────────────────────────────────┘          ║
// ║  ┌───────────────────────────────────────────────────────────┐          ║
// ║  │  [CardGrande]  [CardGrande]                               │          ║
// ║  │  [Card] [Card] [Card]                                     │          ║
// ║  │  [Card] [Card] [Card]                                     │          ║
// ║  └───────────────────────────────────────────────────────────┘          ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class SensorCardWidget extends StatelessWidget {
  /// Gráfico a mostrar: [DonutSensorGrafico], LineChart, BarChart, o cualquier
  /// Widget personalizado. Se renderiza centrado en el bloque superior.
  final Widget grafico;

  /// Etiqueta encima del gráfico. Por defecto: 'VALOR ACTUAL'.
  final String etiquetaTop;

  /// Estado del sensor (badge + descripción + referencia).
  /// Pasa null para mostrar el skeleton de carga mientras la API responde.
  final SensorEstado? estado;

  /// Lista de mediciones para la cuadrícula inferior.
  /// Los que tengan [SensorDato.destacado] = true aparecen como cards grandes.
  final List<SensorDato> mediciones;

  /// Mensaje de error de API. Si no es null, reemplaza el estado con un panel
  /// de error rojo. Útil para manejar el caso snapshot.hasError del FutureBuilder.
  final String? errorMensaje;

  const SensorCardWidget({
    super.key,
    required this.grafico,
    this.etiquetaTop = 'VALOR ACTUAL',
    this.estado,
    this.mediciones = const [],
    this.errorMensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Bloque superior: gráfico + estado / skeleton / error ──
        _CardGraficoEstado(
          grafico: grafico,
          etiquetaTop: etiquetaTop,
          estado: estado,
          errorMensaje: errorMensaje,
        ),
        if (mediciones.isNotEmpty) ...[
          const SizedBox(height: 16),
          // ── Bloque inferior: cuadrícula de mediciones ──
          _CardMediciones(mediciones: mediciones),
        ],
      ],
    );
  }
}

// ── Card del gráfico + bloque de estado ──────────────────────────────────────

class _CardGraficoEstado extends StatelessWidget {
  final Widget grafico;
  final String etiquetaTop;
  final SensorEstado? estado;
  final String? errorMensaje;

  const _CardGraficoEstado({
    required this.grafico,
    required this.etiquetaTop,
    this.estado,
    this.errorMensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SensorColors.fondoCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Etiqueta superior "VALOR ACTUAL" (o la que se pase)
          Text(
            etiquetaTop,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: SensorColors.textoS,
            ),
          ),
          const SizedBox(height: 20),

          // Gráfico pluggable (DonutSensorGrafico, LineChart, BarChart, etc.)
          grafico,
          const SizedBox(height: 16),

          // Panel inferior condicional
          if (errorMensaje != null)
            _PanelError(mensaje: errorMensaje!)
          else if (estado == null)
            const _PanelCargando()
          else
            _PanelEstado(estado: estado!),
        ],
      ),
    );
  }
}

// ── Panel de estado: badge + descripción + recuadro de referencia ─────────────

class _PanelEstado extends StatelessWidget {
  final SensorEstado estado;
  const _PanelEstado({required this.estado});

  @override
  Widget build(BuildContext context) {
    // Texto oscuro sobre fondos claros (nivel1/nivel2), blanco sobre oscuros
    final Color textoBadge = estado.badgeColor.computeLuminance() > 0.5
        ? SensorColors.textoP
        : Colors.white;

    return Column(
      children: [
        // Badge de estado (pill redondeado con color del nivel)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: estado.badgeColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            estado.badgeTexto,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textoBadge,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Descripción contextual
        Text(
          estado.descripcion,
          style: const TextStyle(fontSize: 13, color: SensorColors.textoS),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Recuadro de referencia óptima (nivel óptimo, umbral WHO, etc.)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SensorColors.fondo,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estado.referenciaLabel,
                      style: const TextStyle(
                          fontSize: 11, color: SensorColors.textoS),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      estado.referenciaValor,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: SensorColors.textoP,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: estado.referenciaColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  estado.referenciaIcono,
                  color: estado.referenciaColor,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Panel de carga (skeleton mientras la API responde) ────────────────────────

class _PanelCargando extends StatelessWidget {
  const _PanelCargando();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SkeletonBox(width: 130, height: 38, radius: 20),
        const SizedBox(height: 12),
        _SkeletonBox(width: 200, height: 14, radius: 7),
        const SizedBox(height: 16),
        const _SkeletonBox(width: double.infinity, height: 62, radius: 12),
      ],
    );
  }
}

// ── Panel de error ────────────────────────────────────────────────────────────

class _PanelError extends StatelessWidget {
  final String mensaje;
  const _PanelError({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SensorColors.nivel4.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SensorColors.nivel4.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: SensorColors.nivel4, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(fontSize: 13, color: SensorColors.textoP),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cuadrícula de mediciones ──────────────────────────────────────────────────

class _CardMediciones extends StatelessWidget {
  final List<SensorDato> mediciones;
  const _CardMediciones({required this.mediciones});

  @override
  Widget build(BuildContext context) {
    final destacados = mediciones.where((d) => d.destacado).toList();
    final normales   = mediciones.where((d) => !d.destacado).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SensorColors.fondoCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila de cards grandes (destacado=true)
          if (destacados.isNotEmpty)
            Row(
              children: [
                for (int i = 0; i < destacados.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: _CardMedicionGrande(dato: destacados[i])),
                ],
              ],
            ),
          if (destacados.isNotEmpty && normales.isNotEmpty)
            const SizedBox(height: 12),

          // Grid de cards pequeñas (destacado=false)
          if (normales.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: normales.length,
              itemBuilder: (_, i) => _CardMedicionPequena(dato: normales[i]),
            ),
        ],
      ),
    );
  }
}

// ── Card grande de medición ───────────────────────────────────────────────────

class _CardMedicionGrande extends StatelessWidget {
  final SensorDato dato;
  const _CardMedicionGrande({required this.dato});

  @override
  Widget build(BuildContext context) {
    final bool cargando = dato.valor == null;
    final Color colorIcono = dato.color.computeLuminance() > 0.5
        ? SensorColors.verde
        : dato.color;
    final Color colorNombre = dato.color.computeLuminance() > 0.5
        ? SensorColors.textoP
        : dato.color;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dato.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dato.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono + nombre del parámetro
          Row(
            children: [
              Icon(dato.icono, size: 18,
                  color: cargando ? SensorColors.textoS : colorIcono),
              const SizedBox(width: 6),
              Text(
                dato.nombre,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cargando ? SensorColors.textoS : colorNombre,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Valor + unidad (o skeleton si está cargando)
          if (cargando)
            _SkeletonBox(width: 80, height: 28, radius: 6)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dato.valor!,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: SensorColors.textoP,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    dato.unidad,
                    style: const TextStyle(
                        fontSize: 12, color: SensorColors.textoS),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Card pequeña de medición ──────────────────────────────────────────────────

class _CardMedicionPequena extends StatelessWidget {
  final SensorDato dato;
  const _CardMedicionPequena({required this.dato});

  @override
  Widget build(BuildContext context) {
    final bool cargando = dato.valor == null;
    final Color colorIcono = dato.color.computeLuminance() > 0.5
        ? SensorColors.verde
        : dato.color;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SensorColors.fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(dato.icono, size: 20,
              color: cargando ? SensorColors.textoS : colorIcono),
          const SizedBox(height: 4),

          // Valor numérico (o skeleton si cargando)
          if (cargando)
            _SkeletonBox(width: 38, height: 16, radius: 4)
          else
            FittedBox(
              child: Text(
                dato.valor!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SensorColors.textoP,
                ),
              ),
            ),

          Text(dato.unidad,
              style: const TextStyle(fontSize: 9, color: SensorColors.textoS)),
          Text(dato.nombre,
              style: const TextStyle(
                  fontSize: 10,
                  color: SensorColors.textoS,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Placeholder de carga (skeleton box) ──────────────────────────────────────

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  4. GRÁFICO DONUT PLUGGABLE (sin emojis)                                ║
// ║                                                                         ║
// ║  Representa un valor como arco proporcional a su máximo.                ║
// ║  Úsalo como el parámetro `grafico` de SensorCardWidget, o en            ║
// ║  cualquier otro contexto.                                               ║
// ║                                                                         ║
// ║  Ejemplo:                                                               ║
// ║    DonutSensorGrafico(                                                  ║
// ║      valor: 42,                                                         ║
// ║      max: 500,                                                          ║
// ║      color: SensorColors.colorPorAqi(42),                              ║
// ║      etiquetaCentro: 'AQI',                                             ║
// ║    )                                                                    ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

class DonutSensorGrafico extends StatelessWidget {
  /// Valor actual del sensor.
  final double valor;

  /// Valor máximo del rango (define el 100 % del arco).
  final double max;

  /// Color del arco activo. Usa [SensorColors.colorPorAqi] o
  /// [SensorColors.colorPorRango] según el tipo de sensor.
  final Color color;

  /// Texto bajo el número en el centro ("AQI", "ppm", "°C"...).
  /// Déjalo vacío para mostrar solo el número.
  final String etiquetaCentro;

  /// Tamaño (width = height) del widget. Por defecto 200.
  final double size;

  /// true → muestra el gráfico vacío con placeholder (cargando desde API).
  final bool cargando;

  const DonutSensorGrafico({
    super.key,
    required this.valor,
    required this.max,
    required this.color,
    this.etiquetaCentro = '',
    this.size = 200,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    final double porcentaje =
        cargando ? 0.0 : (valor / max).clamp(0.0, 1.0);

    // Formato numérico: sin decimales si ≥10, 1 decimal si <10
    final String valorTexto = cargando
        ? '--'
        : (valor >= 10
            ? valor.toInt().toString()
            : valor.toStringAsFixed(1));

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Anillo donut (fl_chart PieChart) ──
          PieChart(
            PieChartData(
              startDegreeOffset: -90,         // Inicia en las 12 en punto
              sectionsSpace: 0,
              centerSpaceRadius: size * 0.35, // Radio del hueco central
              sections: [
                // Arco coloreado: porcentaje del valor sobre el máximo
                PieChartSectionData(
                  value: porcentaje * 100,
                  color: cargando ? Colors.grey.shade200 : color,
                  radius: size * 0.11,        // Grosor del arco activo
                  showTitle: false,
                ),
                // Arco gris: porcentaje restante
                PieChartSectionData(
                  value: (1 - porcentaje) * 100,
                  color: Colors.grey.shade200,
                  radius: size * 0.09,        // Ligeramente más fino
                  showTitle: false,
                ),
              ],
            ),
          ),

          // ── Centro: número + etiqueta de unidad (sin emojis) ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valorTexto,
                style: TextStyle(
                  fontSize: size * 0.24,
                  fontWeight: FontWeight.bold,
                  color: cargando ? SensorColors.textoS : SensorColors.textoP,
                  height: 1,
                ),
              ),
              if (etiquetaCentro.isNotEmpty)
                Text(
                  etiquetaCentro,
                  style: const TextStyle(
                    fontSize: 14,
                    color: SensorColors.textoS,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  5. HELPERS PÚBLICOS PARA CABECERAS DE GRÁFICOS                         ║
// ║                                                                         ║
// ║  Úsalos al construir LineChart, BarChart u otros gráficos               ║
// ║  personalizados que quieras pasar al parámetro `grafico`.               ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

/// Mini estadística para encabezados de gráficos (punto de color + label + valor).
///
/// Uso típico:
/// ```dart
/// Row(children: [
///   MiniStat(label: 'Mín', valor: '14', color: SensorColors.nivel1),
///   SizedBox(width: 16),
///   MiniStat(label: 'Prom', valor: '19', color: SensorColors.acento),
///   SizedBox(width: 16),
///   MiniStat(label: 'Máx', valor: '26', color: SensorColors.nivel3),
/// ])
/// ```
class MiniStat extends StatelessWidget {
  final String label;   // "Mín", "Prom", "Máx"
  final String valor;   // Valor ya formateado como String
  final Color color;    // Color del punto y del texto del valor

  const MiniStat({
    super.key,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label: ',
            style: const TextStyle(fontSize: 11, color: SensorColors.textoS)),
        Text(valor,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

/// Leyenda de gráfico: línea de color (sólida o punteada) + texto descriptivo.
///
/// Uso típico:
/// ```dart
/// Row(children: [
///   LeyendaGrafico(color: SensorColors.verde, texto: 'PM2.5'),
///   SizedBox(width: 20),
///   LeyendaGrafico(color: Colors.orange, texto: 'Límite WHO', dashed: true),
/// ])
/// ```
class LeyendaGrafico extends StatelessWidget {
  final Color color;
  final String texto;
  final bool dashed;    // true = línea punteada (para referencias/límites)

  const LeyendaGrafico({
    super.key,
    required this.color,
    required this.texto,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: dashed ? Colors.transparent : color,
            border: dashed ? Border.all(color: color, width: 1) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(texto,
            style: const TextStyle(fontSize: 10, color: SensorColors.textoS)),
      ],
    );
  }
}

// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  GRÁFICOS TEMPORALES                                                     ║
// ║                                                                         ║
// ║  Clases públicas:                                                       ║
// ║    DailyReading      → Lectura diaria (día + valor)                     ║
// ║    MonthlyAverage    → Promedio mensual (label + avg)                   ║
// ║    MonthlyActivityCard → Gráfico línea 30 días                          ║
// ║    AnnualHistoryCard   → Gráfico barras 12 meses                        ║
// ╚═══════════════════════════════════════════════════════════════════════════╝

// ── Modelos ───────────────────────────────────────────────────────────────────

class DailyReading {
  final int day;       // 1..30
  final double value;

  const DailyReading({required this.day, required this.value});

  /// Genera 30 lecturas simuladas centradas en [center] con variación [spread].
  static List<DailyReading> simulated({
    double center = 23.0,
    double spread = 4.0,
    int seed = 42,
  }) {
    final rng = math.Random(seed);
    return List.generate(30, (i) {
      final noise = (rng.nextDouble() * 2 - 1) * spread;
      final v = double.parse((center + noise).toStringAsFixed(1));
      return DailyReading(day: i + 1, value: v);
    });
  }
}

class MonthlyAverage {
  final String label; // 'Ene', 'Feb', ...
  final double avg;

  const MonthlyAverage({required this.label, required this.avg});

  static const List<MonthlyAverage> simulated = [
    MonthlyAverage(label: 'Ene', avg: 12),
    MonthlyAverage(label: 'Feb', avg: 13),
    MonthlyAverage(label: 'Mar', avg: 16),
    MonthlyAverage(label: 'Abr', avg: 19),
    MonthlyAverage(label: 'May', avg: 22),
    MonthlyAverage(label: 'Jun', avg: 27),
    MonthlyAverage(label: 'Jul', avg: 31),
    MonthlyAverage(label: 'Ago', avg: 30),
    MonthlyAverage(label: 'Sep', avg: 26),
    MonthlyAverage(label: 'Oct', avg: 21),
    MonthlyAverage(label: 'Nov', avg: 15),
    MonthlyAverage(label: 'Dic', avg: 10),
  ];
}

// ── MonthlyActivityCard ────────────────────────────────────────────────────────

class MonthlyActivityCard extends StatelessWidget {
  final List<DailyReading>? readings;
  final double optimalMin;
  final double optimalMax;
  final String unit;
  final String sensorName;

  const MonthlyActivityCard({
    super.key,
    this.readings,
    this.optimalMin = 18,
    this.optimalMax = 26,
    this.unit = '°C',
    this.sensorName = 'Temperatura',
  });

  @override
  Widget build(BuildContext context) {
    final data     = readings ?? DailyReading.simulated();
    final values   = data.map((r) => r.value).toList();
    final minVal   = values.reduce(math.min);
    final maxVal   = values.reduce(math.max);
    final avgVal   = values.fold(0.0, (a, b) => a + b) / values.length;

    final yMin      = ((minVal - 5) / 5).floor() * 5.0;
    final yMax      = ((maxVal + 5) / 5).ceil()  * 5.0;
    final yInterval = ((yMax - yMin) / 4).ceilToDouble();

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
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Etiqueta de sección ────────────────────────────
          const Text(
            'ACTIVIDAD MENSUAL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBDBDBD),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          // ── Título + badge de unidad ───────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  '$sensorName — Últimos 30 días',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '*$unit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF388E3C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ── Min / Prom / Máx ───────────────────────────────
          Row(
            children: [
              MiniStat(
                label: 'Min',
                valor: minVal.toStringAsFixed(0),
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 12),
              Text(
                'Prom: ${avgVal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFBDBDBD),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              MiniStat(
                label: 'Máx',
                valor: maxVal.toStringAsFixed(0),
                color: const Color(0xFFF44336),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Gráfico de línea ───────────────────────────────
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 30,
                minY: yMin,
                maxY: yMax,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFF5F5F5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: yInterval,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final v = value.toInt();
                        if (v == 1 || v == 5 || v == 10 ||
                            v == 15 || v == 20 || v == 25 || v == 30) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$v',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFFBDBDBD),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                // Banda de rango óptimo
                betweenBarsData: [
                  BetweenBarsData(
                    fromIndex: 0,
                    toIndex: 1,
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                  ),
                ],
                lineBarsData: [
                  // Borde inferior del rango (transparente)
                  LineChartBarData(
                    spots: [FlSpot(1, optimalMin), FlSpot(30, optimalMin)],
                    color: Colors.transparent,
                    barWidth: 0,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Borde superior del rango (transparente)
                  LineChartBarData(
                    spots: [FlSpot(1, optimalMax), FlSpot(30, optimalMax)],
                    color: Colors.transparent,
                    barWidth: 0,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // Datos reales
                  LineChartBarData(
                    spots: data
                        .map((r) => FlSpot(r.day.toDouble(), r.value))
                        .toList(),
                    isCurved: true,
                    curveSmoothness: 0.1,
                    color: const Color(0xFF4CAF50),
                    barWidth: 1.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, pct, barData, idx) {
                        final v = spot.y;
                        final c = v < optimalMin
                            ? const Color(0xFF2196F3)  // por debajo → azul
                            : v > optimalMax
                                ? const Color(0xFFF44336) // por encima → rojo
                                : const Color(0xFF4CAF50); // en rango → verde
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: c,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: avgVal,
                      color: const Color(0xFFFFB300),
                      strokeWidth: 1.5,
                      dashArray: [5, 5],
                    ),
                  ],
                ),
                lineTouchData: const LineTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // ── Leyenda ───────────────────────────────────────
          Row(
            children: [
              LeyendaGrafico(
                color: const Color(0xFF4CAF50),
                texto: sensorName,
              ),
              const SizedBox(width: 16),
              LeyendaGrafico(
                color: const Color(0xFFFFB300),
                texto: 'Rango óptimo (${avgVal.toStringAsFixed(0)}°)',
                dashed: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── AnnualHistoryCard ──────────────────────────────────────────────────────────

class AnnualHistoryCard extends StatelessWidget {
  final List<MonthlyAverage>? data;
  final double optimalMin;
  final double optimalMax;
  final String unit;
  final String sensorName;
  final int? year;

  const AnnualHistoryCard({
    super.key,
    this.data,
    this.optimalMin = 18,
    this.optimalMax = 26,
    this.unit = '°C',
    this.sensorName = 'Temperatura',
    this.year,
  });

  static Color _barColor(double temp, double optMin, double optMax) {
    if (temp < optMin - 5) return const Color(0xFF90CAF9); // frío → azul
    if (temp < optMin)     return const Color(0xFF81C784); // bajo óptimo → verde claro
    if (temp <= optMax)    return const Color(0xFF4CAF50); // óptimo → verde
    if (temp < optMax + 5) return const Color(0xFFFFB300); // sobre óptimo → ámbar
    return const Color(0xFFF44336);                         // calor → rojo
  }

  @override
  Widget build(BuildContext context) {
    final monthData    = data ?? MonthlyAverage.simulated;
    final values       = monthData.map((m) => m.avg).toList();
    final minVal       = values.reduce(math.min);
    final maxVal       = values.reduce(math.max);
    final avgVal       = values.fold(0.0, (a, b) => a + b) / values.length;
    final displayYear  = year ?? DateTime.now().year;
    final maxY         = ((maxVal + 5) / 5).ceil() * 5.0;

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
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Etiqueta de sección ────────────────────────────
          const Text(
            'HISTÓRICO ANUAL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFBDBDBD),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          // ── Título + badge de año ──────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  '$sensorName Promedio Mensual',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$displayYear',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF388E3C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // ── Min / Prom / Máx ───────────────────────────────
          Row(
            children: [
              MiniStat(
                label: 'Min',
                valor: '${minVal.toStringAsFixed(0)}°',
                color: const Color(0xFF90CAF9),
              ),
              const SizedBox(width: 12),
              MiniStat(
                label: 'Prom',
                valor: '${avgVal.toStringAsFixed(0)}°',
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 12),
              MiniStat(
                label: 'Máx',
                valor: '${maxVal.toStringAsFixed(0)}°',
                color: const Color(0xFFF44336),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Gráfico de barras ─────────────────────────────
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFF5F5F5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 10,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= monthData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            monthData[idx].label,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: monthData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.avg,
                        color: _barColor(
                          entry.value.avg, optimalMin, optimalMax,
                        ),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                barTouchData: BarTouchData(enabled: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: (optimalMin + optimalMax) / 2,
                      color: const Color(0xFFFFB300),
                      strokeWidth: 1.5,
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
