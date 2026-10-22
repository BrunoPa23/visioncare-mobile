import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/app/router.dart';
import 'package:visioncare_app/core/network/api_client.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:visioncare_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Lima'));
  //imprimir zona horaria actual y hora actual
  debugPrint("Zona horaria actual: ${tz.local.name}");
  debugPrint("Hora actual: ${tz.TZDateTime.now(tz.local)}");

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
        // Si la sesion vence y no se puede renovar, se vuelve al login
        sessionExpiredCallbackProvider.overrideWithValue(() => router.go('/login')),
      ],
      child: VisionCareApp(),
    ),
  );
}

class VisionCareApp extends StatelessWidget {
  const VisionCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router
    );
  }
}