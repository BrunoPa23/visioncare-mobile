/// Configuracion de la app que se define al compilar con --dart-define.
///
/// Ejemplo:
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5291 --dart-define=GOOGLE_MAPS_API_KEY=tu_clave
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5291',
  );

  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
}
