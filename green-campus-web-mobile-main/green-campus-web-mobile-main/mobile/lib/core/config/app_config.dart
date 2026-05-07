class AppConfig {
  // Se obtiene al compilar. Si no se pasa, usa el valor por defecto (Local)
  /*static const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue:
      'https://10.0.2.2:3000/v1', // IP estándar para el emulador de Android a localhost
);
*/
  static const String apiUrl = 'https://10.0.2.2:3000/v1';
  // Centralización de Endpoints (Evita hilos sueltos en los servicios)

  // POST
  // Endpoint para hacer login
  static const loginEndpoint = '$apiUrl/auth/login';

  // POST
  // Endpoint para solicitar enviar un correo para recuperar contraseña con código de 6 dígitos
  static const String forgotPasswordEndpoint = '$apiUrl/auth/forgot-password';

  // POST
  // Endpoint para resetear la contraseña
  static const String resetPasswordEndpoint = '$apiUrl/auth/reset-password';

  // POST
  // Endpoint para hacer cerrar sesión
  static const String logoutEndpoint = '$apiUrl/auth/logout';

  // PATCH
  // Endpoint para editar el perfil
  static const String profileEndpoint = '$apiUrl/user/profile';

  // Technical Endpoints

  // GET
  // Endpoint pora obtener todos los nodos IoT (Sin las lecturas)
  static const String nodesEndpoint = '$apiUrl/technical/nodes';

  // GET
  // Endpoint para obtener un nodo por ID (Sin las lecturas)
  static String nodeIdEndpoint(String id) =>
      '$apiUrl/technical/nodes/$id'; // ---> Aquí se requerirá un cambio

  // GET
  // Endpoint para obtener todas las lecturas de un nodo por id (Se debe especificar la cantidad de lecturas que se desean), las devuelve
  // en orden descendente
  
  static String nodeReadingsEndpoint(String id) =>
      '$apiUrl/technical/nodes/$id/readings';

  // GET
  // Endpoint para obtener la última lectura puntual de un nodo (no la media diaria)
  // Devuelve un array con 1 elemento en orden descendente (la más reciente)
  static String nodeLastReadingEndpoint(String id) =>
      '$apiUrl/technical/nodes/$id/readings?skip=0&take=1';


  // GET
  // Endpoint para obtener la media que marco un sensor al día durate un mes entero
  // Filtrado por id (id del nodo), mes y año (años váidos 2025 en adelante)
  static String nodeReadingByMonth(String id, int year, int month) =>
      '$apiUrl/technical/nodes/$id/readings/monthly?year=$year&month=$month';

  // GET
  // Endpoint para obtener la media que marcaron todos los sensores al día durante un mes entero
  // Filtrado por tipo de nodo, mes y año (años válidos 2025 en adelante)
  static String nodeTypeReadingByMonthEndpoint(
    String type,
    int year,
    int month,
  ) => '$apiUrl/technical/nodes/$type/readings/monthly?year=$year&month=$month';

  // GET
  // Endpoint para obtener la media que marcó un sensor en un mes durante un año entero
  // Filtrado por id (id del nodo) y año (años válidos 2025 en adelante)
  static String nodeReadingByYear(String id, int year) =>
      '$apiUrl/technical/nodes/$id/readings/annual?year=$year';

  // GET
  // Endpoint para obtener la media que marcó un sensor en un mes durante un año entero
  // Filtrado por tipo de nodo y año (años válidos 2025 en adelante)
  static String nodeTypeReadingByYear(String type, int year) =>
      '$apiUrl/technical/nodes/$type/readings/annual?year=$year';

  // Endpoint siempre devuelve 100% ¡¡¡ NO USAR !!!
  static const String nodeTypeByMonth =
      '$apiUrl/technical/nodes/{type}/time-on/monthly';
  // Endpoint siempre devuelve 100% ¡¡¡ NO USAR !!!
  static const String nodeTypeByYear =
      '$apiUrl/technical/nodes/{type}/time-on/annual';

  // POST
  // Endpoint para añadir un nuevo nodo
  static const String nodeAdd = '$apiUrl/technical/nodes';

  // PATCH
  // Endpoint para editar un nodo por ID
  static String nodeEdit(String id) => '$apiUrl/technical/nodes/$id';

  // DELETE
  // Endpoint para borrar un nodo por ID
  static String nodeDelete(String id) => '$apiUrl/technical/nodes/$id';
}
