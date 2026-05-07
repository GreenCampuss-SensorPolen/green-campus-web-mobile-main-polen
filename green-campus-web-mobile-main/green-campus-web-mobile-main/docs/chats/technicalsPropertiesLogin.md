Prompt 1:
"Genera las especificaciones técnicas en Pencil para los inputs de la pantalla de Login, integrándolos en la arquitectura del proyecto mobile/lib/.

1. Ubicación de Archivos:

Los componentes visuales deben definirse para ser creados como archivos independientes en lib/widgets/.

Las constantes de estilo (colores, tipografía, bordes de 8px) deben referenciar abstractamente a lo que se encuentre en lib/core/.

2. EmailTextField (ID: email_input):

UX: Teclado emailAddress, acción next, y activación de AutofillHints.email.

Validación: El componente debe estar preparado para que la lógica de validación se inyecte desde un caso de uso en lib/domain/.

3. PasswordTextField (ID: password_input):

UX: obscureText: true, botón de visibilidad (ojo) y acción done.

Validación fuerte: 8+ caracteres, Mayúscula, Minúscula, Número y Carácter especial.

4. Orquestación y Estado:

Indica que estos inputs serán gestionados por un Form en lib/pages/login/login_page.dart.

La captura de datos y el estado de error deben ser comunicados a la capa lib/logic/, evitando que la vista (Pencil/Flutter) contenga lógica de negocio."

Respuesta 1:
Las especificaciones técnicas están completas en Pencil. Aqui el resumen de lo generado:

Documento: "Login Inputs - Technical Spec" (360x740 mobile)

Secciones diseñadas:
1. Ubicacion de Archivos - Arbol de directorios con colores por capa:

lib/widgets/ (verde) - email_text_field.dart, password_text_field.dart
lib/core/ (amarillo) - app_colors, app_typography, app_borders (radius 8px)
lib/pages/login/ (azul) - login_page.dart
lib/domain/ (rosa) - validators/ (UseCases)
lib/logic/ (purpura) - login/ (State Management)
2. EmailTextField (email_input) - Visual del input + estados:

UX: keyboardType: emailAddress, textInputAction: next, AutofillHints.email
Validacion inyectada via validator: String? Function(String?) desde domain/
Estado de error visual con borde rojo y mensaje
3. PasswordTextField (password_input) - Visual con boton ojo:

UX: obscureText: true (toggle), textInputAction: done, suffixIcon: eye/eye-off
Validacion fuerte: 8+ chars, mayuscula, minuscula, numero, caracter especial
Estado de error visual con mensaje descriptivo
4. Orquestacion y Estado - Diagrama de 3 capas:

Vista (azul) - Form en login_page.dart orquesta los widgets
Logica (purpura) - LoginState gestiona errores y estado de carga
Dominio (rosa) - ValidateEmail / ValidatePassword como casos de uso
Estilos (amarillo) - Constantes centralizadas en core/
Principios Clave: UI sin logica de negocio, validadores inyectados, estado en logic/, estilos en core/.



Prompt 2:
"Actualiza las especificaciones técnicas en login_flutter.pen para completar la pantalla de Login, omitiendo cualquier opción de registro de usuario.

1. PrimaryButton (ID: login_submit_btn):

Ubicación: lib/widgets/primary_button.dart.

Estados Técnicos: * Idle: Texto 'Iniciar Sesión', estilo según lib/core/app_typography.dart . * Loading: Mostrar CircularProgressIndicator cuando el estado en lib/logic/login/ sea 'submitting' . * Disabled: Bloquear interacción si los validadores de lib/domain/ devuelven errores .
+2

2. ForgotPasswordLink (ID: forgot_password_link):

Tipo: TextButton o GestureDetector.

Ubicación: Justo debajo del PasswordTextField.

Comportamiento: Disparar navegación hacia la lógica de recuperación de contraseña (fuera de este flujo).

3. Restricciones de Arquitectura:

IMPORTANTE: No incluir ningún componente de 'Registro' o 'Crear Cuenta'. * Asegurar que el botón de login esté vinculado al FormState definido en lib/pages/login/login_page.dart . * Definir que los mensajes de error globales (ej. 'Credenciales incorrectas') se gestionen mediante un SnackBar que escuche a lib/logic/ ."

Respuesta 2:
Nuevas secciones en el documento:
5. ForgotPasswordLink (forgot_password_link)

Tipo: TextButton | GestureDetector
Posicion: Justo debajo del PasswordTextField, alineado a la derecha
Visual: "\u00bfOlvidaste tu contrasena?" con estilo subrayado verde
Comportamiento: Dispara navegacion hacia flujo de recuperacion (fuera del scope de login). No requiere validacion de Form ni modifica estado en logic/
6. PrimaryButton (login_submit_btn)

Archivo: lib/widgets/primary_button.dart
3 estados tecnicos con visual:
Idle: Boton verde "Iniciar Sesion" (estilo desde core/app_typography.dart)
Loading: Boton con opacidad 0.8 + spinner + "Cargando..." (cuando state.isSubmitting)
Disabled: Boton gris deshabilitado (cuando validators devuelven errores)
7. Restricciones de Arquitectura

Alerta roja prominente: SIN COMPONENTE DE REGISTRO (ni enlaces, botones ni referencias a Sign Up)
Regla de FormState: login_submit_btn invoca _formKey.currentState!.validate() antes de despachar
Regla de SnackBar: Errores globales ("Credenciales incorrectas") via SnackBar que escucha lib/logic/login/
Secciones actualizadas:
File tree: Agregado primary_button.dart en widgets/
Orquestacion: Vista ahora incluye ForgotPasswordLink, PrimaryButton(isLoading), y listener de SnackBar
LoginState: Agregado campo globalError: String? para SnackBar
Principios Clave: 3 nuevas reglas (cero registro, SnackBar, FormState.validate)

Prompt 3:
"Actualiza las especificaciones técnicas en login_flutter.pen para blindar la usabilidad de la pantalla de Login contra errores comunes de dispositivos móviles:

1. Responsividad y Prevención de Overflow:

Especifica que el layout principal en lib/pages/login/login_page.dart debe estar contenido en un SingleChildScrollView.

Añade el requisito de usar un Padding dinámico o SafeArea para garantizar que los elementos no queden ocultos bajo el teclado o el notch del dispositivo.

2. Gestión de Foco Inteligente (FocusNodes): * Define que la página debe gestionar instancias de FocusNode para los componentes email_input y password_input.
+1

Establece el flujo: el foco debe iniciarse en el correo y saltar automáticamente a la contraseña al terminar (vía FocusScope.of(context).requestFocus). * Añade la regla de UX: El teclado debe ocultarse automáticamente (unfocus) cuando el login_submit_btn  cambie al estado 'Loading'.

3. Mejora de la Orquestación: * En la sección de 'Orquestación y Estado' , indica que la validación del FormState  debe ocurrir antes de que los campos pierdan el foco para proporcionar feedback inmediato al usuario.
+1

Asegura que estas reglas mantengan la consistencia con los IDs y la estructura de carpetas ya declarada."

Respuesta 3:
Las especificaciones tecnicas en login_flutter.pen han sido actualizadas con las 3 secciones de blindaje de usabilidad movil. Resumen:

Nuevas secciones agregadas:
8. Responsividad y Prevencion de Overflow

Widget tree completo: Scaffold > SafeArea > SingleChildScrollView > Padding > Form
SafeArea: Proteccion contra notch, Dynamic Island, barra de estado y navegacion del sistema en todos los dispositivos
SingleChildScrollView: Previene RenderFlex overflow cuando el teclado virtual se abre; garantiza accesibilidad en pantallas < 5"
9. Gestion de Foco Inteligente

Declaracion de _emailFocus y _passwordFocus en login_page.dart con dispose() obligatorio
Diagrama visual del flujo: email_input (autofocus) -> password_input (requestFocus) -> submit (done -> unfocus)
3 reglas numeradas del flujo de foco
Regla critica de Auto-Unfocus en Loading: FocusScope.of(context).unfocus() al cambiar a estado submitting (oculta teclado automaticamente)
Secciones actualizadas:
Orquestacion (Vista): Codigo actualizado con SafeArea, SingleChildScrollView, FocusNode por campo, y autovalidateMode: onUserInteraction
Orquestacion (Logica): Notas de autovalidateMode para feedback inmediato
Nueva nota verde: "Validacion con Feedback Inmediato" - la validacion ocurre ANTES de perder foco, mostrando errores en tiempo real
Principios Clave: 3 nuevas reglas (purpura): SafeArea+Scroll obligatorios, FocusNodes con dispose, auto-unfocus en Loading