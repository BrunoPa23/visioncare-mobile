import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visioncare_app/presentation/login/view/login_page.dart';
import 'package:visioncare_app/presentation/register/view/register_page.dart';

import '../../helpers/test_fonts.dart';

void main() {
  setUp(useBundledGoogleFonts);

  Future<void> pump(WidgetTester tester, Widget page, {double textScale = 1.0}) async {
    SharedPreferences.setMockInitialValues({'text_scale': textScale});
    await tester.pumpWidget(ProviderScope(child: MaterialApp(home: page)));
    await tester.pumpAndSettle();
  }

  Future<void> expectGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  group('login', () {
    testWidgets('cumple las guias de accesibilidad', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const LoginPage());
      await expectGuidelines(tester);
      handle.dispose();
    });

    testWidgets('no se desborda con el texto al doble de tamano', (tester) async {
      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await pump(tester, const LoginPage(), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });

  group('registro', () {
    testWidgets('cumple las guias de accesibilidad', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const RegisterPage());
      await expectGuidelines(tester);
      handle.dispose();
    });

    testWidgets('el titulo es un encabezado y los campos tienen etiqueta', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const RegisterPage());

      expect(
        tester.getSemantics(find.text('REGÍSTRATE')),
        matchesSemantics(label: 'REGÍSTRATE', isHeader: true),
      );
      for (final label in ['Nombre', 'Apellido', 'Correo electrónico', 'Contraseña', 'Fecha de nacimiento']) {
        expect(find.bySemanticsLabel(RegExp(label)), findsWidgets, reason: label);
      }
      expect(find.bySemanticsLabel(RegExp('Grado de discapacidad visual')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('no se desborda con el texto al doble de tamano', (tester) async {
      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await pump(tester, const RegisterPage(), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });
  });
}
