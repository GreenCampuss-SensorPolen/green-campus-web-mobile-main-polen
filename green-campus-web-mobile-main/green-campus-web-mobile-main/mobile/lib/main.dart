import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/data/models/technical_data.dart';
import 'package:mobile_app/pages/dashboard/facility_management/facility_management_dashboard_page.dart';
import 'package:mobile_app/pages/dashboard/technical/technical_dashboard_page.dart';
import 'package:mobile_app/pages/dashboard/technical/temperature_sensor_page.dart';
import 'package:mobile_app/pages/dashboard/technical/humidity_sensor_page.dart';
import 'package:mobile_app/pages/dashboard/technical/sensors_view/view_sensor.dart';
import 'package:mobile_app/pages/dashboard/technical/co2_sensor_page.dart';
import 'package:mobile_app/pages/dashboard/technical/energy_sensor_page.dart';
import 'package:mobile_app/pages/forgot_password/new_password_page.dart';
import 'package:mobile_app/pages/forgot_password/request_reset_page.dart';
import 'package:mobile_app/pages/login/login_page.dart';
import 'package:mobile_app/pages/profile/edit_profile_page.dart';
import 'package:mobile_app/pages/profile/profile_page.dart';
import 'package:mobile_app/pages/notifications/notifications_page.dart';
import 'package:mobile_app/pages/dashboard/technical/device_id_search_page.dart';
import 'package:mobile_app/pages/IoT/iot_dashboard_page.dart';
// import 'package:mobile_app/pages/splash/splash_page.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const GreenCampusApp());
  } catch (e) {
    debugPrint("Error crítico en main: $e");
  }
}

// ThemeData se crea una única vez al arrancar: ColorScheme.fromSeed
// es costoso (algorítmo HCT de Material 3) y no debe recalcularse en cada build.
final _appTheme = ThemeData(
  useMaterial3: true,
  primaryColor: AppColors.accentGreen,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.accentGreen,
    primary: AppColors.accentGreen,
    error: Colors.red,
  ),
  scaffoldBackgroundColor: AppColors.bgPage,
);

class GreenCampusApp extends StatelessWidget {
  const GreenCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Campus',
      debugShowCheckedModeBanner: false,

      // Tema pre-computado para evitar recalcular el esquema de colores M3
      theme: _appTheme,

      // Se define la ruta de inicio (Login)
      initialRoute: '/',

      // Sistema de rutas nombradas para una navegación escalable
      routes: {
        '/': (context) =>
            const LoginPage(), // Pantalla de inicio con logo y redirección por rol

        '/login': (context) => const LoginPage(), // Pantalla de login principal

        '/forgot-password': (context) =>
            const RequestResetPage(), // Pantalla para solicitar el código de verificación

        '/new-password': (context) =>
            const NewPasswordPage(), // Pantalla para restablcer la contraseña

        '/dashboard-directivo': (context) => const Scaffold(
          body: Center(child: Text('Dashboard Directivo - En construcción')),
        ),

        '/dashboard-servicios': (context) =>
            const FacilityManagementDashboardPage(), // Dashboard inicial de servicios generales

        '/dashboard-tecnico': (context) =>
            const TechnicalDashboardPage(), // Dashboard inicial del técnico

        '/profile': (context) => const ProfilePage(),

        '/edit-profile': (context) => const EditProfilePage(),
        '/notifications': (context) =>
            const NotificationsPage(), // Pantalla de notificaciones (TECNICO y SERVICIOS_GENERALES)

        '/device-id': (context) =>
            const DeviceIdSearchPage(), // Buscar dispositivo por ID → abre /device-details

        '/device-details': (context) {
          final node = ModalRoute.of(context)!.settings.arguments as IotNode;
          return SensorDetailPage(node: node);
        },
        // Dashboard IoT (pantalla principal de dispositivo: métricas + gráfico 24h)
        '/iot-dashboard': (context) {
          final node =
              ModalRoute.of(context)!.settings.arguments as IotNode;
          return IoTDashboardPage(node: node);
        },
        '/sensor-temperatura': (context) => const TemperatureSensorPage(),
        '/sensor-humedad': (context) => const HumiditySensorPage(),
        '/sensor-CO2': (context) => const Co2SensorPage(),
        '/sensor-energia': (context) => const EnergySensorPage(),

        '/hardware-device-details': (context) => const Scaffold(
          body: Center(
            child: Text(
              'Aquí van los detalles de los nodos IoT RASPBERRY y ARDUINO',
            ),
          ),
        ),
      },
    );
  }
}
