import 'package:flutter/foundation.dart';
import 'package:mobile_app/data/services/token_storage.dart';

class ProfileController extends ChangeNotifier {
  bool _isLoading = true;

  // Campos de información personal (disponibles en TokenStorage)
  String? firstName;
  String? lastName;
  String? email;
  String? role;
  String? profileImageUrl;

  // Campos de información adicional — nulos hasta que el backend los exponga
  String? phone;
  String? birthDate;
  String? gender;
  String? country;
  String? city;
  String? postalCode;
  String? address;

  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        TokenStorage.getFirstName(),
        TokenStorage.getLastName(),
        TokenStorage.getEmail(),
        TokenStorage.getRole(),
        TokenStorage.getProfileImage(),
      ]);

      firstName = results[0];
      lastName = results[1];
      email = results[2];
      role = results[3];
      profileImageUrl = results[4];
    } catch (e) {
      debugPrint('Error cargando perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recarga los datos desde TokenStorage tras una edición exitosa.
  Future<void> refresh() => init();
}
