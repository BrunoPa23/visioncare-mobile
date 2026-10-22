import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visioncare_app/core/network/api_exception.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/presentation/home/view/home_page.dart';
import 'package:visioncare_app/presentation/scanning/view/results_page.dart';
import 'package:visioncare_app/presentation/scanning/view/scanning_page.dart';
import 'package:visioncare_app/presentation/scanning/viewmodel/results_view_model.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/speech_view_model.dart';

import '../../helpers/fake_tts.dart';
import '../../helpers/test_fonts.dart';

void main() {
  setUp(useBundledGoogleFonts);

  final image = XFile('caja.jpg');

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    double textScale = 1.0,
    List<Override> overrides = const [],
  }) async {
    SharedPreferences.setMockInitialValues({'text_scale': textScale});
    await tester.pumpWidget(ProviderScope(overrides: overrides, child: MaterialApp(home: page)));
    await tester.pumpAndSettle();
  }

  Future<void> expectGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  Override resultWith(Medicines medicine) =>
      resultViewModelProvider.overrideWith((ref, file) async => medicine);

  testWidgets('inicio cumple las guias de accesibilidad', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const HomePage(), overrides: [
      speechViewModelProvider.overrideWith((ref) => FakeSpeechViewModel()),
    ]);
    await expectGuidelines(tester);
    expect(find.bySemanticsLabel(RegExp('Hablar: di escanear')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('escaneo cumple las guias de accesibilidad', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const ScanningPage());
    await expectGuidelines(tester);
    handle.dispose();
  });

  testWidgets('escaneo no se desborda con el texto al doble de tamano', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pump(tester, const ScanningPage(), textScale: 2.0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el resultado cumple las guias de accesibilidad', (tester) async {
    final handle = tester.ensureSemantics();
    final tts = FakeTtsViewModel();
    await pump(tester, ResultsPage(imageFile: image), overrides: [
      resultWith(Medicines(name: 'Paracetamol', expirationDate: '12/2027')),
      ttsOverride(tts),
    ]);
    await expectGuidelines(tester);
    handle.dispose();
  });

  testWidgets('un error del backend muestra el motivo y permite reintentar o volver', (tester) async {
    await pump(tester, ResultsPage(imageFile: image), overrides: [
      resultViewModelProvider.overrideWith((ref, file) async => throw const ApiException('La imagen no es válida')),
      ttsOverride(FakeTtsViewModel()),
    ]);

    expect(find.text('NO SE PUDO LEER EL MEDICAMENTO'), findsOneWidget);
    expect(find.text('La imagen no es válida'), findsOneWidget);
    expect(find.text('INTENTAR DE NUEVO'), findsOneWidget);
    expect(find.text('VOLVER'), findsOneWidget);
  });
}
