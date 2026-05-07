class PasswordValidator {
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }

    // Regla 1: Mínimo 8 caracteres
    if (value.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }
    // Regla 2:  Al menos una mayúcula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }
    // Regla 3: Al menos un número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    // Regla 4: Al menos un carácter especial
    if (!value.contains(RegExp(r'[^a-zA-Z0-9]'))) {
      return 'Debe incluir un carácter especial';
    }

    return null; // Retorna null si cumple todas las reglas
  }
}
