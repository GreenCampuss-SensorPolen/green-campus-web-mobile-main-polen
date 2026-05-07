# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/email_validator_test.dart

# Static analysis
flutter analyze

# Format code
dart format lib/ test/

# Build Android APK
flutter build apk

# Clean build artifacts
flutter clean
```

## Architecture

Flutter mobile app for Green Campus — an IoT monitoring and facility management platform. Layered architecture with `ChangeNotifier` for state management (no BLoC, Riverpod, or GetX).

### Layers

```
lib/
├── core/        # Constants, colors, borders, API config (AppConfig)
├── data/        # Services (HTTP) and models (DTOs)
├── domain/      # Business logic validators
├── logic/       # Controllers (ChangeNotifier)
├── pages/       # UI screens
└── widgets/     # Reusable UI components
```

### State Management

Controllers in `lib/logic/` extend `ChangeNotifier`. Pages consume them via `ListenableBuilder`. Each feature has its own controller. Use `ValueNotifier` for high-frequency UI updates that should NOT rebuild the entire page (e.g., the countdown chip in `TechnicalDashboardController.secondsNotifier`).

### Routing

Named routes in `main.dart`. Routes that pass data do so via `ModalRoute.of(context)!.settings.arguments`.

| Route | Page | Notes |
|---|---|---|
| `/`, `/login` | `LoginPage` | |
| `/forgot-password` | `RequestResetPage` | |
| `/new-password` | `NewPasswordPage` | |
| `/dashboard-tecnico` | `TechnicalDashboardPage` | |
| `/dashboard-servicios` | `FacilityManagementDashboardPage` | |
| `/dashboard-directivo` | placeholder | not yet implemented |
| `/profile`, `/edit-profile` | `ProfilePage`, `EditProfilePage` | |
| `/notifications` | `NotificationsPage` | |
| `/device-id` | `DeviceIdSearchPage` | filtro por nombre y tipo (chips); RASPBERRY/ARDUINO → `/hardware-device-details`, sensores → `/device-details`; ambos reciben `IotNode` como argumento |
| `/device-details` | `SensorDetailPage` | receives `IotNode` as argument |
| `/sensor-temperatura` | `TemperatureSensorPage` | receives `List<IotNode>` as argument |
| `/sensor-humedad` | `HumiditySensorPage` | receives `List<IotNode>` as argument |
| `/sensor-CO2` | `Co2SensorPage` | receives `List<IotNode>` as argument |
| `/hardware-device-details` | placeholder | Raspberry Pi / Arduino detail, not yet implemented |

### API Layer

All endpoints centralized in `lib/core/config/app_config.dart`. Base URL: `https://10.0.2.2:3000/v1` (Android emulator → localhost). Services use `IOClient` with `badCertificateCallback` for self-signed certs in dev.

Authentication: JWT Bearer tokens via `flutter_secure_storage`. `TokenStorage` in `lib/data/services/token_storage.dart` manages read/write with in-memory caching.

### Roles

`TECNICO`, `SERVICIOS_GENERALES`, `DIRECTIVO` — defined in `lib/core/constants/user_roles.dart`. Post-login navigation branches by role.

### Key Patterns

**Sensor pages (temperatura, humedad, CO2):**
- Receive `List<IotNode>` from the dashboard via route arguments
- Filter relevant nodes internally in their controller by concatenating `node.name + node.type` (both lowercased) and checking `contains('tem')`, `contains('hum')`, `contains('co2')`
- Each controller fetches `getNodeLastReading(nodeId)` (endpoint: `/nodes/{id}/readings?skip=0&take=1`) per node in parallel, verifies the timestamp is from **today**, and stores the value. If no data for today → returns `null` → UI shows `--`
- The header average (`averageTemperature` / `averageHumidity` / `averageCo2`) is `double?` — `null` when no node has a reading today; the header card then shows `'--'` and a neutral "Sin datos hoy" state instead of a value
- Annual bar-chart history uses `_fetchAnnualHistory()` which calls `TechnicalServices.getNodeTypeReadingByYear(nodeId, year)` (endpoint: `/nodes/{nodeId}/readings/annual?year={year}`). Response items have Spanish month abbreviations (`Ene`…`Dic`) and `avg` or `value` fields.

**Last-reading fetch (critical):**
The endpoint `nodeLastReadingEndpoint` returns `[{ timestamp/createdAt/date, temperature/humidity/co2/value, ... }]` in descending order. Parsers try field names in fallback order. If the reading date ≠ today (UTC-aware), the value is discarded.

**Auto-refresh:**
- `TechnicalDashboardController`: two timers — `_refreshTimer` (30s, fires data fetch) and `_countdownTimer` (1s, decrements `secondsNotifier`). The `ValueNotifier<int> secondsNotifier` is consumed by `ValueListenableBuilder` in the live chip widget, so only the chip rebuilds each second.
- `TemperaturaController` / `HumedadController` / `Co2Controller`: single 30s `Timer.periodic` that silently refreshes `_nodeValues` and average without showing a loading spinner.
- All timers must be cancelled in `dispose()`.

**Parallel loading:** `Future.wait([...])` for concurrent API calls in all dashboard controllers.

**Background JSON parsing:** `compute()` for heavy JSON decoding (node list) off the main isolate.

**Charts:** `fl_chart` — `PieChart` (donut gauge in sensor headers), `BarChart` (annual history in accordion cards via `SensorBarChart` widget).

**SensorType enum** (`lib/pages/dashboard/technical/sensors_view/view_sensor.dart`): `temperatura`, `humedad`, `calidadAire`, `matrizTermica`. `SensorDetailPage` maps `node.type` to this enum to pick the correct gauge config from `kSensorConfigs`.

**Theme:** Material 3, seed color `AppColors.accentGreen` (`#22C55E`). `_appTheme` computed once at startup outside the widget tree to avoid re-running the expensive HCT algorithm.

### Known Broken Endpoints

Do not use — always return 100%:
- `AppConfig.nodeTypeByMonth`
- `AppConfig.nodeTypeByYear`

### Pending / Not Yet Implemented

- `SensorDetailPage` (`/device-details`) uses `node.lastTelemetry` as a placeholder; real API calls are marked with `// ← reemplazar por llamada real a la API`. `SensorControlPanel` renders `SensorHealthData.simulated()` — health data is not from the API.
- `/dashboard-directivo` and `/hardware-device-details` are scaffold placeholders.
- `SplashPage` exists at `lib/pages/splash/splash_page.dart` but is commented out in `main.dart`. It checks `TokenStorage` for a saved token and redirects to the role-based dashboard or `/login`.
- Node CRUD endpoints (`AppConfig.nodeAdd`, `nodeEdit(id)`, `nodeDelete(id)`) are defined but not yet wired to any UI.

### Tests

Two test files: `test/email_validator_test.dart` and `test/password_validator.dart`, covering `EmailValidator` and `PasswordValidator` in `lib/domain/validators/`.
