import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // Instancia única del almacenamiento cifrado
  static const _storage = FlutterSecureStorage();

  static String? _cachedToken;
  static String? _cachedEmail;
  static String? _cachedFirstName;
  static String? _cachedProfileImage;

  // Claves para identificar los datos
  static const _keyToken = 'jwt_token';
  static const _keyRole = 'user_role';
  static const _keyEmail = 'email';
  static const _keyProfileImage = 'profile_image_url';
  static const _keyFirstName = 'first_name';
  static const _keyLastName = 'last_name';

  // Guardar el token y el rol tras el login
  static Future<void> saveSession({
    required String token,
    required String role,
    required String email,
    required String profileImage,
    required String firstName,
    required String lastName,
  }) async {
    _cachedToken = token;
    _cachedEmail = email;
    _cachedFirstName = firstName;
    _cachedProfileImage = profileImage;

    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRole, value: role);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyProfileImage, value: profileImage);
    await _storage.write(key: _keyFirstName, value: firstName);
    await _storage.write(key: _keyLastName, value: lastName);
  }

  // Leer el token para futuras peticiones a la API
  static Future<String?> getToken() async =>
      _cachedToken ??= await _storage.read(key: _keyToken);
  // Leer el rol para lógica de permisos en la UI
  static Future<String?> getRole() async => await _storage.read(key: _keyRole);
  // Leer el nombre de usuario para mostrar en la UI
  static Future<String?> getEmail() async =>
      _cachedEmail ??= await _storage.read(key: _keyEmail);
  // Leer la URL de la imagen de perfil para mostrar en la UI
  static Future<String?> getProfileImage() async =>
      _cachedProfileImage ??= await _storage.read(key: _keyProfileImage);
  static Future<String?> getFirstName() async =>
      _cachedFirstName ??= await _storage.read(key: _keyFirstName);
  static Future<String?> getLastName() async =>
      await _storage.read(key: _keyLastName);

  // Actualizar nombre y apellido tras guardar el perfil
  static Future<void> updateFirstName(String firstName) async {
    _cachedFirstName = firstName;
    await _storage.write(key: _keyFirstName, value: firstName);
  }

  static Future<void> updateLastName(String lastName) async {
    await _storage.write(key: _keyLastName, value: lastName);
  }

  // Borrar todo (Cerrar sesión)
  static Future<void> clearSession() async {
    _cachedToken = null;
    _cachedEmail = null;
    _cachedFirstName = null;
    _cachedProfileImage = null;
    await _storage.deleteAll();
  }
}
