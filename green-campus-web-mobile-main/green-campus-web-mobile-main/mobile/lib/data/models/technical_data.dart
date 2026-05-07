// Modelo para los sensores de tiempo real
class TelemetryData {
  final double? temperature;
  final double? humidity;
  final int? co2;
  final double? energy;

  TelemetryData({this.temperature, this.humidity, this.co2, this.energy});

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      co2: json['co2'],
      energy: json['energy']?.toDouble(),
    );
  }
}

// Modelo para las lecturas históricas de un nodo IoT
class IotReading {
  final DateTime timestamp;
  final double? consumoW;
  final double? tempC;

  IotReading({required this.timestamp, this.consumoW, this.tempC});

  factory IotReading.fromJson(Map<String, dynamic> json) => IotReading(
    timestamp: DateTime.parse(json['timestamp']),
    consumoW:
        (json['consumo_w'] ?? json['energy'])?.toDouble(),
    tempC:
        (json['temp_c'] ?? json['temperature'])?.toDouble(),
  );
}

// Modelo para el inventario de hardware
class IotNode {
  final String id;
  final String name; // (EJ. RPI 01)
  final String location;
  final String
  type; // Raspberry Pi, Arduino, sensor de temperatura, sensor de humedad, sensor de calidad de aire, sensor de matriz de calor.
  final String status;
  final int battery;
  final String edificio;
  final String planta;
  final TelemetryData? lastTelemetry; // Métricas específicas de este nodo

  IotNode({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.status,
    required this.battery,
    required this.edificio,
    required this.planta,
    this.lastTelemetry,
  });

  factory IotNode.fromJson(Map<String, dynamic> json) {
    return IotNode(
      id: (json['nodeId'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'OFFLINE',
      battery: json['battery'] ?? 0,
      edificio: json['edificio'] ?? 'Edificio Principal',
      planta: json['planta'] ?? 'Baja',
      lastTelemetry: json['lastTelemetry'] != null
          ? TelemetryData.fromJson(json['lastTelemetry'])
          : null,
    );
  }
}
