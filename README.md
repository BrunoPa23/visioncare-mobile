# VisionCare Mobile

> **Muestra publica de portafolio.** Version publica y saneada de la app movil de VisionCare, proyecto final del curso Seminario de Investigacion Academica (Ingenieria de Software, UPC, 2025), desarrollado en equipo por Bruno Palomino y William Riega. No incluye claves ni la URL del backend de produccion; se configuran al compilar. El backend esta en [visioncare-backend](https://github.com/BrunoPa23/visioncare-backend).

App en Flutter que ayuda a las personas a gestionar sus medicamentos, con foco en la accesibilidad: escanea la etiqueta de un medicamento con la camara, obtiene su informacion interpretada por IA, la lee en voz alta y programa recordatorios de toma.

## Funcionalidades

- Registro e inicio de sesion con JWT, sesion persistida en almacenamiento seguro y refresco automatico del token
- Escaneo de medicamentos con la camara: OCR en el backend (Azure AI Vision) e interpretacion con OpenAI
- Informacion del medicamento: indicaciones, efectos secundarios y advertencias
- Lectura en voz alta (text to speech) y busqueda por voz (speech to text)
- Recordatorios de toma con notificaciones locales programadas por zona horaria
- Mapa de farmacias cercanas con Google Maps y Places
- Almacenamiento local con SQLite

## Arquitectura

Patron MVVM con Riverpod para el estado y go_router para la navegacion:

```
lib/
├── app/            Router de la aplicacion
├── core/           Configuracion, constantes de estilo y base de datos local
├── models/         Modelos de dominio (usuario, medicamento, horarios)
├── services/       Clientes HTTP del backend, mapas y notificaciones
└── presentation/   Pantallas por funcionalidad, cada una con su view y su viewmodel
```

## Stack

- Flutter y Dart
- Riverpod, go_router
- Dio con manejo de cookies, http
- flutter_secure_storage, jwt_decoder, sqflite
- speech_to_text, flutter_tts
- flutter_local_notifications, timezone
- google_maps_flutter, google_places_flutter, location
- image_picker

## Como ejecutarla

Requisitos: Flutter SDK y el [backend](https://github.com/BrunoPa23/visioncare-backend) corriendo.

1. Instala las dependencias:

```bash
flutter pub get
```

2. Ejecuta la app indicando la URL del backend y tu clave de Google Maps:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5291 --dart-define=GOOGLE_MAPS_API_KEY=<tu clave>
```

`10.0.2.2` apunta al localhost de tu PC desde el emulador de Android.

3. Clave de Google Maps en las plataformas nativas:

- **Android:** agrega `MAPS_API_KEY=<tu clave>` en `~/.gradle/gradle.properties` (fuera del repositorio) o pasala con `-PMAPS_API_KEY=<tu clave>`.
- **iOS:** crea `ios/Flutter/Keys.xcconfig` con `GOOGLE_MAPS_API_KEY=<tu clave>`; ese archivo esta en el `.gitignore`.

## Equipo

- Bruno Palomino ([@BrunoPa23](https://github.com/BrunoPa23))
- William Riega
