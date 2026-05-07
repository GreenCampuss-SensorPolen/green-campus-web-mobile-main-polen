// Funciones de parseo aisladas para usar con 'compute' y no bloquear la UI
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile_app/data/models/facility_management_data.dart';
import 'package:mobile_app/data/services/facility_management_service.dart';
import 'package:mobile_app/data/services/token_storage.dart';

HabitabilityStats _parseStats(String body) =>
    HabitabilityStats.fromJson(jsonDecode(body));
List<ZoneConfort> _parseZones(String body) {
  final List list = jsonDecode(body);
  return list.map((item) => ZoneConfort.fromJson(item)).toList();
}

List<PreventiveTask> _parseTasks(String body) {
  final List list = jsonDecode(body);
  return list.map((item) => PreventiveTask.fromJson(item)).toList();
}

class FacilityManagementController extends ChangeNotifier {
  final FacilityManagementService _service = FacilityManagementService();

  bool _isLoading = true;
  HabitabilityStats? _stats;
  List<ZoneConfort> _zones = [];
  List<PreventiveTask> _tasks = [];
  Timer? _refreshTimer;

  String? userEmail;
  String? userName;
  String? lastName;
  String? role;
  String? profileImageUrl;

  bool get isLoading => _isLoading;
  HabitabilityStats? get stats => _stats;
  List<ZoneConfort> get zones => _zones;
  List<PreventiveTask> get tasks => _tasks;

  Future<void> init() async {
    // Carga paralela de perfil y datos operativos
    await Future.wait([_loadUserProfile(), fetchManagementData()]);
    _startAutoRefresh();
  }

  Future<void> _loadUserProfile() async {
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

      notifyListeners();
    } catch (e) {
      debugPrint("Error cargando perfil $e");
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchManagementData(showLoading: false); // Refresco silencioso
    });
  }

  Future<void> fetchManagementData({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _service.getHabitabilityStats(),
        _service.getZonesStatus(),
        _service.getPreventiveTasks(),
      ]);

      if (results[0].statusCode == 200) {
        _stats = await compute(_parseStats, results[0].body);
      }
      if (results[1].statusCode == 200) {
        _zones = await compute(_parseZones, results[1].body);
      }
      if (results[2].statusCode == 200) {
        _tasks = await compute(_parseTasks, results[2].body);
      }
    } catch (e) {
      debugPrint("Error en Dashboard de Gestión: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
