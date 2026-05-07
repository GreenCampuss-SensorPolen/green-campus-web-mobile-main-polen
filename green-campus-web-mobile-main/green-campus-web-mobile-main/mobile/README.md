# Green Campus — Mobile App

Aplicación móvil Flutter para la plataforma **Green Campus**, un sistema de monitoreo IoT y gestión de instalaciones universitarias.

## Requisitos

- Flutter SDK `^3.10.7`
- Android emulator (o dispositivo físico Android/iOS)
- Backend corriendo en `localhost:3000` (la app apunta a `10.0.2.2:3000` para el emulador Android)

## Primeros pasos

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en emulador/dispositivo
flutter run

# Construir APK de release
flutter build apk
```

## Comandos útiles

```bash
flutter test                              # Todos los tests
flutter test test/email_validator_test.dart  # Un test específico
flutter analyze                           # Análisis estático
dart format lib/ test/                    # Formatear código
flutter clean                             # Limpiar artefactos de build
```

## Arquitectura

Arquitectura en capas con `ChangeNotifier` como sistema de estado (sin BLoC, Riverpod ni GetX).

```
lib/
├── core/        # Colores, bordes, configuración de API y constantes
├── data/        # Servicios HTTP y modelos (DTOs)
├── domain/      # Validadores de negocio
├── logic/       # Controladores (ChangeNotifier)
├── pages/       # Pantallas
└── widgets/     # Componentes reutilizables
```

## Roles de usuario

Definidos en `lib/core/constants/user_roles.dart`:

| Rol                  | Dashboard                        |
|----------------------|----------------------------------|
| `TECNICO`            | Dashboard técnico (sensores IoT) |
| `SERVICIOS_GENERALES`| Dashboard de servicios           |
| `DIRECTIVO`          | En construcción                  |

## Dependencias principales

| Paquete                  | Uso                                      |
|--------------------------|------------------------------------------|
| `http`                   | Llamadas HTTP a la API REST              |
| `flutter_secure_storage` | Almacenamiento seguro del JWT y sesión   |
| `fl_chart`               | Gráficas de lecturas mensuales/anuales   |
