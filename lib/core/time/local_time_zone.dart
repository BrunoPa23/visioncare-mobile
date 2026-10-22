import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Zona que se usa si no se puede leer la del dispositivo (la app se penso para Peru).
const fallbackTimeZone = 'America/Lima';

/// Configura `tz.local` con la zona horaria del dispositivo para que los recordatorios
/// suenen a la hora local de la persona. Si el dispositivo no la informa o no es valida,
/// usa [fallbackTimeZone].
///
/// [readDeviceTimeZone] se inyecta para poder probarlo sin el plugin nativo.
Future<String> configureLocalTimeZone(Future<String> Function() readDeviceTimeZone) async {
  tz_data.initializeTimeZones();

  String name;
  try {
    name = await readDeviceTimeZone();
    tz.getLocation(name);
  } catch (e) {
    debugPrint('No se pudo usar la zona horaria del dispositivo ($e); se usa $fallbackTimeZone');
    name = fallbackTimeZone;
  }

  tz.setLocalLocation(tz.getLocation(name));
  return name;
}
