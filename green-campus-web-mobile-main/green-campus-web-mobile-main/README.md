# green-campus-web-mobile
Este repositorio contiene la lógica frontend de la aplicación Green Campus, tanto de aplicación movil como web.

## ESTRUCTURA DETALLADA DE DIRECTORIOS DE MÓVIL (FLUTTER)

```
lib/
├── main.dart                              → Punto de entrada + sistema de rutas
│
├── core/
│   ├── app_colors.dart                    → Paleta de colores centralizada
│   ├── app_borders.dart                   → Radio de borde global (8px)
│   ├── config/
│   │   └── app_config.dart                → URLs base y endpoints de la API
│   └── constants/
│       └── user_roles.dart                → Constantes de roles de usuario
│
├── data/
│   ├── models/
│   │   ├── login_response.dart            → DTO de respuesta de login
│   │   ├── technical_data.dart            → IotNode + TelemetryData
│   │   └── facility_management_data.dart  → HabitabilityStats + ZoneConfort + PreventiveTask
│   └── services/
│       ├── auth_service.dart              → Login, logout, recuperación de contraseña
│       ├── technical_services.dart        → Nodos IoT y telemetría
│       ├── facility_management_service.dart → KPIs, zonas, tareas de mantenimiento
│       ├── profile_service.dart           → Actualización de perfil
│       └── token_storage.dart             → Persistencia segura del JWT y datos de sesión
│
├── domain/
│   └── validators/
│       ├── email_validator.dart           → Validación de formato de email (RFC)
│       └── password_validator.dart        → Reglas de complejidad de contraseña
│
├── logic/
│   ├── login/
│   │   └── login_controller.dart         → Flujo de autenticación
│   ├── forgot_password/
│   │   ├── forgot_password_request_controller.dart → Paso 1: solicitud de código OTP
│   │   └── new_password_controller.dart            → Paso 2: verificación OTP + nueva clave
│   ├── dashboard/
│   │   ├── technical_dashboard_controller.dart      → Estado del dashboard técnico
│   │   └── facility_management_controller.dart      → Estado del dashboard de servicios
│   └── profile/
│       ├── profile_controller.dart        → Lectura del perfil del usuario
│       └── edit_profile_controller.dart   → Edición de nombre, apellido y contraseña
│
├── pages/
│   ├── splash/
│   │   └── splash_page.dart              → Pantalla de carga + lógica de redirección (actualmente comentada en main.dart)
│   ├── login/
│   │   └── login_page.dart               → Formulario de inicio de sesión
│   ├── forgot_password/
│   │   ├── request_reset_page.dart        → Paso 1: introducir email
│   │   └── new_password_page.dart         → Paso 2: OTP + nueva contraseña
│   ├── dashboard/
│   │   ├── technical/
│   │   │   ├── technical_dashboard_page.dart         → Dashboard del rol TECNICO
│   │   │   ├── device_id_search_page.dart            → Listado y búsqueda de dispositivos
│   │   │   └── sensors_view/
│   │   │       ├── main_sensor.dart                  → Entry point aislado para preview
│   │   │       ├── view_sensor.dart                  → Página de detalle de un nodo IoT
│   │   │       ├── panel_control_sensor.dart         → Panel de control y salud del sensor
│   │   │       ├── valor_gauge_sensor.dart            → Widget gauge radial + configuración
│   │   │       └── mesual_anual_graficos_sensor.dart  → Gráficos mensuales/anuales del sensor
│   │   └── facility_management/
│   │       └── facility_management_dashboard_page.dart → Dashboard del rol SERVICIOS_GENERALES
│   ├── profile/
│   │   ├── profile_page.dart              → Visualización del perfil del usuario
│   │   └── edit_profile_page.dart         → Edición del perfil
│   └── notifications/
│       └── notifications_page.dart        → Pantalla de notificaciones (placeholder)
│
└── widgets/
    ├── common_app_header.dart             → Header/AppBar común con campana y avatar
    ├── common_app_drawer.dart             → Drawer lateral adaptativo por rol
    ├── primary_button.dart                → Botón primario estándar con estado de carga
    ├── email_text_field.dart              → Campo de email reutilizable
    ├── password_text_field.dart           → Campo de contraseña con visibilidad toggle
    ├── otp_input_field.dart               → Entrada OTP de 6 dígitos con navegación automática
    └── photo_picker_bottom_sheet.dart     → Bottom sheet para selección de foto de perfil
```

## Pasos para clonar el repositorio
- Paso 1: Crear una carpeta donde se trabajará en a nivel local.
- Paso 2: Abrir el bash de Git y clonar el repositorio https://github.com/GreenCampusNebrija/green-campus-web-mobile.git en la carpeta creada anteriormente.
- Paso 3: Una vez clonado el repositorio comprobar a dónde está apuntando el repositorio local con git remote -v.
- Paso 4: Si todo está okey hasta este paso, crear una rama a nivel local donde se va a trabajar y moverse a esa rama.
- Paso 5: Una vez en la rama hacer un pequeño cambio a este archivo (ej. poner prueba nombre_de_la_persona)
- Paso 6: Hacer el commit en la correspondiente rama.
- Paso 7: Una vez realizado el commit en la rama nunca se debe ejecutar este comando ¡¡¡"git push origin main"!!!, en ves de ese comando se debe ejecutar "git push origin <nombre-de-la-persona>". Esto lo que hace es crear vuestra propia rama aquí en GitHub.
- Paso 8: Comprobar en esta plataforma si teneis un pull-request que realizar.
- Paso 9: Crear un pull-request para que se ejecute el CI, que comporbará que todo va bien.
- Paso 10: Si todo está okey hasta el momento, es decir, que ha pasado el CI con éxito (debería salir un check en todas las pruebas). Pues en este punto podeis confirmar el mergeo a Main.
- Cuidado: Si hay un conflicto se debe solucionar antes de hacer cualquier mergeo, lo podeis realizar desde aquí o en vuestro IDE (mejor opción).

## Esta será la forma de trabajo:
- Primero se completa una funcionalidad a nivel local.
- Segundo una vez completada la funcionalidad se sube a vuestra propia rama (NO a main).
- Tercero se pide el pull-request y esperad a que se realizen los tests de CI.
- Cuarto si ha ido todo bien aplicar el mergeo a main si no hay conflicto, si lo hay solucionarlo y volver al paso 2.