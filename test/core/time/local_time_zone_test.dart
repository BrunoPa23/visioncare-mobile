import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:visioncare_app/core/time/local_time_zone.dart';

void main() {
  test('usa la zona horaria del dispositivo', () async {
    final name = await configureLocalTimeZone(() async => 'Europe/Madrid');

    expect(name, 'Europe/Madrid');
    expect(tz.local.name, 'Europe/Madrid');
  });

  test('usa America/Lima si el dispositivo no informa su zona', () async {
    final name = await configureLocalTimeZone(() async => throw Exception('sin plugin'));

    expect(name, fallbackTimeZone);
    expect(tz.local.name, 'America/Lima');
  });

  test('usa America/Lima si la zona del dispositivo no existe en la base de datos', () async {
    final name = await configureLocalTimeZone(() async => 'Marte/Olympus_Mons');

    expect(name, fallbackTimeZone);
    expect(tz.local.name, 'America/Lima');
  });
}
