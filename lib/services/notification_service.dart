import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;


final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError(); // se inyecta desde main
});

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/logo_app_notification');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPPlugin.initialize(initializationSettings);
    debugPrint("✅ NotificationService inicializado");
    
  }

  Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTimeTZ,
  }) async {
    debugPrint("Scheduling notification with ID: $id, Title: $title, Body: $body, Time: $scheduledTimeTZ");
    await notificationsPPlugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      scheduledTimeTZ,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_reminders',
          'Recordatorios de medicación', 
          channelDescription: 'Notificaciones que te recuerdan tomar tu medicación',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    debugPrint("Notification scheduled with ID: ${id.hashCode} created");
  }

  Future<void> showInstantNotification() async {
    final pending = await notificationsPPlugin.pendingNotificationRequests();
    debugPrint("Pending notifications: ${pending.length}");

    debugPrint("⏰ Intentando mostrar notificación instantánea");

    
    final now = DateTime.now().add(const Duration(seconds: 5));
    final scheduledTime = tz.TZDateTime.from(now, tz.local);
    debugPrint("📆 Programando notificación para: $scheduledTime");

    notificationsPPlugin.zonedSchedule(
      'testInstant5555'.hashCode,
      'Funciona 🎉',
      'Esta es una prueba instantánea',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: null,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}