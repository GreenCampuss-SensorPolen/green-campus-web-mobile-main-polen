// Modelo para el semáforo de habitabilidad (KPIs globales)
class HabitabilityStats {
  final double averageTemp;
  final double averageHumidity;
  final int averageCo2;

  HabitabilityStats({
    required this.averageTemp,
    required this.averageHumidity,
    required this.averageCo2,
  });

  factory HabitabilityStats.fromJson(Map<String, dynamic> json) {
    return HabitabilityStats(
      averageTemp: json['averageTemp']?.toDouble() ?? 0.0,
      averageHumidity: json['averageHumidity']?.toDouble() ?? 0.0,
      averageCo2: json['averageCo2'] ?? 0,
    );
  }
}

// Modelo para el diagnóstico rápido por zonas
class ZoneConfort {
  final String id;
  final String name;
  final String status;
  final double temp;
  final double humidity;

  ZoneConfort({
    required this.id,
    required this.name,
    required this.status,
    required this.temp,
    required this.humidity,
  });

  factory ZoneConfort.fromJson(Map<String, dynamic> json) {
    return ZoneConfort(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'OPTIMO',
      temp: json['temp']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
    );
  }
}

// Modelo para el mantenimiento preventivo (Gestión de incidencias)
class PreventiveTask {
  final String id;
  final String title;
  final String location;
  final int daysRemaining; // La cuenta atrás que pediste
  final String priority; // CRITICAL, MEDIUM, LOW

  PreventiveTask({
    required this.id,
    required this.title,
    required this.location,
    required this.daysRemaining,
    required this.priority,
  });

  factory PreventiveTask.fromJson(Map<String, dynamic> json) {
    return PreventiveTask(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      daysRemaining: json['daysRemaining'] ?? 0,
      priority: json['priority'] ?? 'MEDIUM',
    );
  }
}
