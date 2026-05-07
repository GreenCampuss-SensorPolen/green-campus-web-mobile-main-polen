import 'dart:async';
import 'dart:convert';
import 'package:mobile_app/data/models/technical_data.dart';
import 'package:mobile_app/data/services/technical_services.dart';
import 'package:mobile_app/data/services/token_storage.dart';
import 'package:flutter/foundation.dart';

List<IotNode> _parseNodes(String body) {
  final decoded = jsonDecode(body);
  final List list;
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map) {
    // Soporta respuestas envueltas: {"data":[...]}, {"nodes":[...]}, {"items":[...]}
    list = (decoded['data'] ?? decoded['nodes'] ?? decoded['items'] ?? []) as List;
  } else {
    list = [];
  }
  return list.map((item) => IotNode.fromJson(item as Map<String, dynamic>)).toList();
}

class TechnicalDashboardController extends ChangeNotifier {
  final TechnicalServices _service = TechnicalServices();

  bool _isLoading = true;
  List<IotNode> _nodes = [];
  Timer? _refreshTimer;
  Timer? _countdownTimer;

  /// Segundos hasta el próximo refresco. Solo actualiza el chip, no el dashboard entero.
  final ValueNotifier<int> secondsNotifier = ValueNotifier(30);

  double? _avgTemperatura;
  double? _avgHumedad;
  double? _avgCo2;
  double? _avgEnergia;

  // Variables de perfil para evitar lecturas repetitivas al disco
  String? userEmail;
  String? userName;
  String? lastName;
  String? role;
  String? profileImageUrl;

  // Getters para la interfaz
  bool get isLoading => _isLoading;
  List<IotNode> get nodes => _nodes;
  double? get avgTemperatura => _avgTemperatura;
  double? get avgHumedad => _avgHumedad;
  double? get avgCo2 => _avgCo2;
  double? get avgEnergia => _avgEnergia;

  // Al iniciar, se cargan los datos y se activa el temporizador
  Future<void> init() async {
    await Future.wait([_loadUserProfile(notify: true), fecthDashboardData()]);
    _startAutoRefresh();
  }

  Future<void> _loadUserProfile({bool notify = true}) async {
    try {
      // Se lee todo en paralelo para no bloquear el hilo principal
      final results = await Future.wait([
        TokenStorage.getFirstName(),
        TokenStorage.getEmail(),
        TokenStorage.getProfileImage(),
        TokenStorage.getLastName(),
        TokenStorage.getRole(),
      ]);

      userName = results[0];
      userEmail = results[1];
      profileImageUrl = results[2];
      lastName = results[3];
      role = results[4];

      if (notify) notifyListeners();
    } catch (e) {
      debugPrint("Error cargando perfil $e");
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();

    secondsNotifier.value = 30;

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      secondsNotifier.value = 30;
      fecthDashboardData(showLoading: false);
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsNotifier.value > 0) secondsNotifier.value--;
    });
  }

  Future<void> fecthDashboardData({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // 1. Cargar lista de nodos
      final nodesResponse = await _service.getNodes();
      if (nodesResponse.statusCode == 200) {
        _nodes = await compute(_parseNodes, nodesResponse.body);
      }

      // 2. Filtrar nodos por tipo
      final now = DateTime.now();
      final tempNodes = _nodes.where((n) {
        final s = n.name.toLowerCase() + n.type.toLowerCase();
        return s.contains('tem');
      }).toList();
      final humNodes = _nodes.where((n) {
        final s = n.name.toLowerCase() + n.type.toLowerCase();
        return s.contains('hum');
      }).toList();
      final co2Nodes = _nodes.where((n) {
        final s = n.name.toLowerCase() + n.type.toLowerCase();
        return s.contains('co2') || s.contains('calidad');
      }).toList();
      final energNodes = _nodes.where((n) {
        final s = n.name.toLowerCase() + n.type.toLowerCase();
        return s.contains('energ') || s.contains('potenc') || s.contains('cons');
      }).toList();

      // 3. Obtener la última lectura de cada nodo en paralelo y calcular medias
      await Future.wait([
        _fetchTypeAverage(tempNodes, now, 'temperature'),
        _fetchTypeAverage(humNodes, now, 'humidity'),
        _fetchTypeAverage(co2Nodes, now, 'co2'),
        _fetchTypeAverage(energNodes, now, 'energy'),
      ]);
      

    } catch (e) {
      debugPrint("Error cargando dashboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene la última lectura del día actual para cada nodo del grupo,
  /// calcula la media y la asigna al campo correspondiente.
  Future<void> _fetchTypeAverage(
    List<IotNode> nodes,
    DateTime now,
    String field,
  ) async {
    if (nodes.isEmpty) return;

    final values = <double>[];

    await Future.wait(
      nodes.map((node) async {
        try {
          final response = await _service.getNodeLastReading(node.id);
          if (response.statusCode != 200) return;

          final List<dynamic> data = jsonDecode(response.body);
          if (data.isEmpty) return;

          final item = data.first;

          // Verificar que la lectura sea del día actual
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
            if (readingDay != today) return;
          }

          final raw =
              item[field]?.toString() ?? item['value']?.toString() ?? '';
          final value = double.tryParse(raw);
          if (value != null) values.add(value);
        } catch (e) {
          debugPrint("Error cargando lectura del nodo ${node.id}: $e");
        }
      }),
    );

    if (values.isEmpty) return;
    final avg = values.fold(0.0, (a, b) => a + b) / values.length;

    if (field == 'temperature') {
      _avgTemperatura = avg;
    } else if (field == 'humidity') {
      _avgHumedad = avg;
    } else if (field == 'co2') {
      _avgCo2 = avg;
    } else if (field == 'energy') {
      _avgEnergia = avg;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _countdownTimer?.cancel();
    secondsNotifier.dispose();
    super.dispose();
  }
}
