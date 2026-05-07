import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/data/models/technical_data.dart';
import 'package:mobile_app/data/services/technical_services.dart';

class TemperaturaController extends ChangeNotifier {
  final TechnicalServices _service = TechnicalServices();
  bool _isLoading = true;
  List<IotNode> _nodes = [];
  double? _averageTemperature;
  Timer? _timer;

  // Última lectura puntual del día actual para cada nodo
  final Map<String, double> _nodeValues = {};
  // Histórico mensual para las gráficas de barras
  final Map<String, List<double>> _historyCache = {};

  bool get isLoading => _isLoading;
  List<IotNode> get nodes => _nodes;
  double? get averageTemperature => _averageTemperature;

  /// Recibe los nodos del Dashboard y lanza la carga inicial + auto-refresh.
  void init(List<IotNode> allNodes) {
    _isLoading = true;
    notifyListeners();

    _nodes = allNodes.where((n) {
      final search = n.name.toLowerCase() + n.type.toLowerCase();
      return search.contains('tem');
    }).toList();

    _loadData();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  /// Actualización silenciosa (sin spinner) cada 30 segundos.
  Future<void> _refresh() async {
    final now = DateTime.now();
    await Future.wait(_nodes.map((node) => _fetchLastReading(node.id, now)));
    _calculateAverage();
    notifyListeners();
  }

  Future<void> _loadData() async {
    try {
      final now = DateTime.now();
      await Future.wait(
        _nodes.map((node) => Future.wait([
          _fetchLastReading(node.id, now),
          _fetchAnnualHistory(node.id, now.year),
        ])),
      );
      _calculateAverage();
    } catch (e) {
      debugPrint("Error cargando datos de temperatura: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateAverage() {
    final values = _nodeValues.values.toList();
    if (values.isEmpty) {
      _averageTemperature = null;
      return;
    }
    final sum = values.fold(0.0, (a, b) => a + b);
    _averageTemperature = sum / values.length;
  }

  /// Obtiene la última lectura puntual del día actual para un nodo concreto.
  Future<void> _fetchLastReading(String nodeId, DateTime now) async {
    try {
      final response = await _service.getNodeLastReading(nodeId);
      if (response.statusCode != 200) return;

      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) return;

      final item = data.first;

      // Verificar que la lectura es del día actual
      final rawDate =
          item['timestamp']?.toString() ??
          item['createdAt']?.toString() ??
          item['date']?.toString() ??
          '';
      if (rawDate.isNotEmpty) {
        final readingDate = DateTime.tryParse(rawDate);
        if (readingDate == null) return;
        final today = DateTime(now.year, now.month, now.day);
        final readingDay = DateTime(
          readingDate.year,
          readingDate.month,
          readingDate.day,
        );
        if (readingDay != today) return; // Lectura de otro día → no mostrar
      }

      // Extraer el valor de temperatura
      final raw =
          item['temperature']?.toString() ??
          item['value']?.toString() ??
          '';
      final value = double.tryParse(raw);
      if (value != null) _nodeValues[nodeId] = value;
    } catch (e) {
      debugPrint("Error cargando lectura del nodo $nodeId: $e");
    }
  }

  /// Histórico anual (12 medias mensuales) para la gráfica de barras.
  Future<void> _fetchAnnualHistory(String nodeId, int year) async {
    try {
      final response = await _service.getNodeTypeReadingByYear(nodeId, year);
      List<double> yearData = List.filled(12, 0.0);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        const monthMap = {
          'Ene': 0, 'Feb': 1, 'Mar': 2, 'Abr': 3,
          'May': 4, 'Jun': 5, 'Jul': 6, 'Ago': 7,
          'Sep': 8, 'Oct': 9, 'Nov': 10, 'Dic': 11,
        };
        for (final item in data) {
          final idx = monthMap[item['month']?.toString() ?? ''];
          if (idx != null) {
            yearData[idx] = double.tryParse(
                  item['avg']?.toString() ?? item['value']?.toString() ?? '',
                ) ??
                0.0;
          }
        }
      }
      _historyCache[nodeId] = yearData;
    } catch (e) {
      debugPrint("Error cargando histórico del nodo $nodeId: $e");
    }
  }

  /// Última medición del día actual para este sensor.
  /// Devuelve null si no hay dato disponible para hoy.
  double? temperatureOf(IotNode node) => _nodeValues[node.id];

  /// Histórico mensual para la gráfica de barras de un nodo.
  List<double> monthlyHistory(String nodeId) => _historyCache[nodeId] ?? [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
