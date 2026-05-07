import 'package:flutter_test/flutter_test.dart';

// Ajusta este import a la ruta real dentro de tu proyecto.
// Opción recomendada (si están en /lib/...):
// import 'package:<TU_PAQUETE>/email_validator.dart';
// import 'package:<TU_PAQUETE>/validators/email_validator.dart';
//
// Opción rápida (si este test está en /test y el archivo en /lib):
import 'package:mobile_app/domain/validators/email_validator.dart';

void main() {
  group('EmailValidator.validate', () {
    test('devuelve error si es null', () {
      expect(
        EmailValidator.validate(null),
        'El correo electrónico es obligatorio',
      );
    });

    test('devuelve error si está vacío', () {
      expect(
        EmailValidator.validate(''),
        'El correo electrónico es obligatorio',
      );
    });

    test('devuelve error si el formato es inválido', () {
      expect(
        EmailValidator.validate('hola'),
        'Ingresa un formato de correo válido',
      );
      expect(
        EmailValidator.validate('hola@'),
        'Ingresa un formato de correo válido',
      );
      expect(
        EmailValidator.validate('hola@dominio'),
        'Ingresa un formato de correo válido',
      );
      expect(
        EmailValidator.validate('hola@dominio.'),
        'Ingresa un formato de correo válido',
      );
      expect(
        EmailValidator.validate('hola@dominio.c'),
        'Ingresa un formato de correo válido',
      ); // TLD 1 char
      expect(
        EmailValidator.validate('hola dominio@ejemplo.com'),
        'Ingresa un formato de correo válido',
      ); // espacios
    });

    test('acepta emails válidos comunes', () {
      expect(EmailValidator.validate('test@example.com'), isNull);
      expect(EmailValidator.validate('user.name@example.com'), isNull);
      expect(EmailValidator.validate('user+tag@sub.example.co'), isNull);
      expect(EmailValidator.validate('a_b-c.1@foo-bar.baz'), isNull);
    });
  });
}
