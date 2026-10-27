import 'package:flutter_test/flutter_test.dart';
import 'package:visioncare_app/core/validation/credential_validator.dart';

void main() {
  group('correo', () {
    test('acepta dominios largos, subdominios y alias con +', () {
      for (final email in [
        'maria@correo.com',
        'maria.lopez@upc.edu.pe',
        'maria+recetas@gmail.com',
        'contacto@museo.museum',
        'ana_o-neil@empresa.technology',
      ]) {
        expect(CredentialValidator.isValidEmail(email), isTrue, reason: email);
      }
    });

    test('rechaza correos sin @, sin dominio o con espacios', () {
      for (final email in [
        'maria',
        'maria@correo',
        'maria@correo.c',
        '@correo.com',
        'maria@@correo.com',
        'maria lopez@correo.com',
      ]) {
        expect(CredentialValidator.isValidEmail(email), isFalse, reason: email);
      }
    });
  });

  group('contrasena', () {
    test('acepta simbolos, espacios y letras con tilde', () {
      for (final password in ['Prueba123', 'clave#2026!', 'mi clave 12', 'contraseña9', r'P@$$w0rd']) {
        expect(CredentialValidator.isValidPassword(password), isTrue, reason: password);
      }
    });

    test('exige 8 caracteres con al menos una letra y un numero', () {
      for (final password in ['abc123', 'solamenteletras', '12345678', '!!!!####']) {
        expect(CredentialValidator.isValidPassword(password), isFalse, reason: password);
      }
    });
  });
}
