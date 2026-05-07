// Punto de entrada para previsualización aislada del módulo de sensores.
// Para ejecutarlo sin pasar por el login:
//   flutter run -t lib/pages/dashboard/technical/sensors_view/main_sensor.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/technical_data.dart';
import 'view_sensor.dart';
// import 'sensorCalidadAire.dart'; // ← descomentar al restaurar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SensorDetailPage(
        // Nodo de ejemplo para preview — reemplazar con datos reales en producción
        node: IotNode(
          id: 'SEN-042',
          name: 'Sensor Temperatura',
          location: 'Aula 101',
          type: 'sensor de temperatura',
          status: 'ONLINE',
          battery: 85,
          edificio: 'Edificio Principal',
          planta: 'Baja',
          lastTelemetry: TelemetryData(temperature: 21.0),
        ),
      ),
    );
  }
}
