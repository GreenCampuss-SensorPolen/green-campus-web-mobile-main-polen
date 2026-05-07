import 'package:flutter_test/flutter_test.dart';

// Ajusta este import a la ruta real dentro de tu proyecto.
// Opción recomendada (si están en /lib/...):
// import 'package:<TU_PAQUETE>/password_validator.dart';
// import 'package:<TU_PAQUETE>/validators/password_validator.dart';
//
// Opción rápida (si este test está en /test y el archivo en /lib):
import 'package:mobile_app/domain/validators/password_validator.dart';

void main() {
  group('PasswordValidator.validate', () {
    test('devuelve error si es null', () {
      expect(PasswordValidator.validate(null), 'La contraseña es obligatoria');
    });

    test('devuelve error si está vacía', () {
      expect(PasswordValidator.validate(''), 'La contraseña es obligatoria');
    });

    test('regla 1: mínimo 8 caracteres', () {
      expect(
        PasswordValidator.validate('Ab1!'),
        'Debe tener al menos 8 caracteres',
      );
      expect(
        PasswordValidator.validate('Abc12!'),
        'Debe tener al menos 8 caracteres',
      );
    });

    test('regla 2: requiere mayúscula (y respeta el orden de validación)', () {
      // 8+ chars, tiene número y especial, pero NO mayúscula
      expect(
        PasswordValidator.validate('abcd123!'),
        'Debe contener al menos una mayúscula',
      );

      // Si es corta, debe fallar primero por longitud aunque no tenga mayúscula
      expect(
        PasswordValidator.validate('abcd1!'),
        'Debe tener al menos 8 caracteres',
      );
    });

    test('regla 3: requiere número (y respeta el orden de validación)', () {
      // 8+ chars, tiene mayúscula y especial, pero NO número
      expect(
        PasswordValidator.validate('Abcdefg!'),
        'Debe contener al menos un número',
      );
    });

    test(
      'regla 4: requiere carácter especial (y respeta el orden de validación)',
      () {
        // 8+ chars, tiene mayúscula y número, pero NO especial
        expect(
          PasswordValidator.validate('Abcdefg1'),
          'Debe incluir un carácter especial',
        );
      },
    );

    test('acepta contraseña válida', () {
      expect(PasswordValidator.validate('Abcdef1!'), isNull);
      expect(PasswordValidator.validate('Z9@aaaaa'), isNull);
    });
  });
}
