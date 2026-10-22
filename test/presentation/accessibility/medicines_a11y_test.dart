import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visioncare_app/core/network/api_client.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/models/medicines_time.dart';
import 'package:visioncare_app/presentation/medicines/view/medicines_page.dart';
import 'package:visioncare_app/presentation/medicines/viewmodel/medicines_view_model.dart';
import 'package:visioncare_app/presentation/notifications/view/notifications_choose_days.dart';
import 'package:visioncare_app/presentation/notifications/view/notifications_choose_time.dart';
import 'package:visioncare_app/presentation/notifications/view/notifications_created.dart';
import 'package:visioncare_app/presentation/notifications/viewmodel/notifications_viewmodel.dart';
import 'package:visioncare_app/services/medication_service.dart';
import 'package:visioncare_app/services/notification_service.dart';

import '../../helpers/fake_http.dart';
import '../../helpers/fake_tts.dart';
import '../../helpers/test_fonts.dart';

void main() {
  setUp(useBundledGoogleFonts);

  late NotificationsViewModel notificationsVM;
  late FakeTtsViewModel tts;

  setUp(() {
    tts = FakeTtsViewModel();
    // Sin red: el servicio de medicinas usa un adaptador falso que nunca se llama en estas pantallas
    final api = ApiClient(
      tokenStorage: InMemoryTokenStorage(),
      baseUrl: 'http://backend.test',
      adapter: FakeAdapter((_) => const FakeResponse(500)),
    );
    notificationsVM = NotificationsViewModel(NotificationService(), MedicationService(api));
  });

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    double textScale = 1.0,
    List<Override> overrides = const [],
    bool settle = true,
  }) async {
    SharedPreferences.setMockInitialValues({'text_scale': textScale});
    await tester.pumpWidget(ProviderScope(
      overrides: [
        notificationsViewModelProvider.overrideWith((ref) => notificationsVM),
        ttsOverride(tts),
        ...overrides,
      ],
      child: MaterialApp(home: page),
    ));
    // El indicador de carga gira sin fin, asi que esas pantallas solo avanzan unos cuadros
    settle ? await tester.pumpAndSettle() : await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> expectGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  final medicines = [
    Medicines(
      id: '1',
      name: 'Paracetamol',
      expirationDate: '12/2027',
      notifications: [MedicinesTime(medicineId: '1', day: 'Lunes', typeRemember: 0, specificTime: '08:00:00')],
    ),
    Medicines(id: '2', name: 'Ibuprofeno', notifications: []),
  ];

  group('medicinas', () {
    testWidgets('cumple las guias de accesibilidad', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const MedicinesPage(), overrides: [
        getAllMedicinesProvider.overrideWith((ref) async => medicines),
      ]);
      await expectGuidelines(tester);
      handle.dispose();
    });

    testWidgets('los botones dicen de que medicina se trata', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const MedicinesPage(), overrides: [
        getAllMedicinesProvider.overrideWith((ref) async => medicines),
      ]);

      expect(find.bySemanticsLabel('Eliminar Paracetamol'), findsOneWidget);
      expect(find.bySemanticsLabel('Ver la información de Ibuprofeno'), findsOneWidget);
      expect(find.text('Días: Lunes'), findsOneWidget);
      expect(find.text('Hora: 08:00'), findsOneWidget);
      expect(find.text('Sin días seleccionados'), findsOneWidget);
      handle.dispose();
    });
  });

  group('recordatorios', () {
    testWidgets('elegir dias cumple las guias de accesibilidad', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const NotificationsChooseDays());
      await expectGuidelines(tester);
      handle.dispose();
    });

    testWidgets('elegir hora cumple las guias y no se desborda con el texto grande', (tester) async {
      final handle = tester.ensureSemantics();
      notificationsVM.setSelectedTime(const TimeOfDay(hour: 8, minute: 30));
      await pump(tester, const NotificationsChooseTime());
      await expectGuidelines(tester);
      expect(find.bySemanticsLabel('Hora elegida: 08:30'), findsOneWidget);
      handle.dispose();

      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await pump(tester, const NotificationsChooseTime(), textScale: 2.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el recordatorio creado cumple las guias y se anuncia por voz', (tester) async {
      final handle = tester.ensureSemantics();
      notificationsVM.medicationNameController.text = 'Ibuprofeno';
      notificationsVM.isLoading = false;
      notificationsVM.isError = false;

      await pump(tester, const NotificationsCreated());

      await expectGuidelines(tester);
      expect(tts.spoken, ['Recordatorio creado. Te avisaremos cuando debas tomar Ibuprofeno.']);
      handle.dispose();
    });

    testWidgets('con lector de pantalla la confirmacion va por SemanticsService', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(accessibleNavigation: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      notificationsVM.medicationNameController.text = 'Ibuprofeno';
      notificationsVM.isLoading = false;

      await pump(tester, const NotificationsCreated());

      expect(
        tester.takeAnnouncements(),
        contains(isAccessibilityAnnouncement('Recordatorio creado. Te avisaremos cuando debas tomar Ibuprofeno.')),
      );
      expect(tts.spoken, isEmpty);
    });

    testWidgets('no anuncia nada mientras guarda y avisa si falla', (tester) async {
      notificationsVM.medicationNameController.text = 'Ibuprofeno';
      notificationsVM.isLoading = true;

      await pump(tester, const NotificationsCreated(), settle: false);
      expect(tts.spoken, isEmpty);

      notificationsVM.isLoading = false;
      notificationsVM.isError = true;
      notificationsVM.notifyListeners();
      await tester.pumpAndSettle();

      expect(tts.spoken, ['No se pudo guardar el recordatorio. Vuelve e inténtalo otra vez.']);
    });
  });
}
