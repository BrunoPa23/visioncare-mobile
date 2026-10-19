import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visioncare_app/presentation/login/view/login_page.dart';

void main() {
  setUp(() {
    // Sin red en los tests: las fuentes usan la de respaldo
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder textField(String label) => find.descendant(
        of: find.bySemanticsLabel(label),
        matching: find.byType(TextField),
      );

  // El view model activa Entrar en el frame siguiente al cambio de texto
  Future<void> typeIn(WidgetTester tester, String label, String text) async {
    await tester.enterText(textField(label), text);
    await tester.pump();
    await tester.pump();
  }

  ElevatedButton loginButton(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Entrar'));

  testWidgets('muestra el formulario de inicio de sesion', (tester) async {
    await pumpLogin(tester);

    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Crear cuenta nueva'), findsOneWidget);
    expect(find.text('Escuchar'), findsOneWidget);
  });

  testWidgets('Entrar se activa solo con correo y contrasena', (tester) async {
    await pumpLogin(tester);
    expect(loginButton(tester).onPressed, isNull);

    await typeIn(tester, 'Correo electrónico', 'maria@correo.com');
    expect(loginButton(tester).onPressed, isNull);

    await typeIn(tester, 'Contraseña', 'clave1234');
    expect(loginButton(tester).onPressed, isNotNull);
  });

  testWidgets('el boton del ojo muestra y oculta la contrasena', (tester) async {
    await pumpLogin(tester);
    TextField password() => tester.widget<TextField>(textField('Contraseña'));

    expect(password().obscureText, isTrue);
    await tester.tap(find.bySemanticsLabel('Mostrar la contraseña'));
    await tester.pump();
    expect(password().obscureText, isFalse);
  });

  testWidgets('un correo invalido muestra el error y conserva el correo', (tester) async {
    await pumpLogin(tester);

    await typeIn(tester, 'Correo electrónico', 'maria-correo');
    await typeIn(tester, 'Contraseña', 'clave1234');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.textContaining('El correo no es válido'), findsOneWidget);
    expect(find.text('maria-correo'), findsOneWidget);
  });

  testWidgets('el boton de tema cambia a modo oscuro', (tester) async {
    await pumpLogin(tester);
    Color background() => tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor!;

    expect(background(), const Color(0xFFFFFFFF));
    await tester.tap(find.byTooltip('Cambiar a modo oscuro'));
    await tester.pumpAndSettle();
    expect(background(), const Color(0xFF0E0E0E));
  });
}
