import 'package:flutter/material.dart';
import 'package:mobile_app/data/services/profile_service.dart';
import 'package:mobile_app/data/services/token_storage.dart';

class EditProfileController extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get success => _success;

  /// Precarga los valores actuales en los campos del formulario.
  Future<void> init() async {
    try {
      final results = await Future.wait([
        TokenStorage.getFirstName(),
        TokenStorage.getLastName(),
      ]);
      firstNameController.text = results[0] ?? '';
      lastNameController.text = results[1] ?? '';
    } catch (e) {
      debugPrint('Error cargando datos de edición: $e');
    }
  }

  Future<void> saveChanges() async {
    _isLoading = true;
    _errorMessage = null;
    _success = false;
    notifyListeners();

    try {
      final password = passwordController.text.trim();
      final response = await _service.updateProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        password: password.isEmpty ? null : password,
      );

      if (response.statusCode == 200) {
        await Future.wait([
          TokenStorage.updateFirstName(firstNameController.text.trim()),
          TokenStorage.updateLastName(lastNameController.text.trim()),
        ]);
        passwordController.clear();
        _success = true;
      } else {
        _errorMessage = 'No se pudieron guardar los cambios. Inténtalo de nuevo.';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Comprueba tu red.';
      debugPrint('Error guardando perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
