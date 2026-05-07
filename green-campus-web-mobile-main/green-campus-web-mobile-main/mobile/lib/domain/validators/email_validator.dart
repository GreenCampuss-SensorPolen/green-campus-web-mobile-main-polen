class EmailValidator {
  // Expresión regular para validar formato de email estándar
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }

    if (!_emailRegExp.hasMatch(value)) {
      return 'Ingresa un formato de correo válido';
    }

    // En caso de usar el dominio institucional @greencampus.edu
    // if (!value.endsWith('@greencampus.edu')) {
    //   return 'Solo se permiten correos institucionales';
    // }

    return null;
  }
}
