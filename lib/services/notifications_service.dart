import 'package:flutter/material.dart' as colors;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_10y.dart' as tz;

class NotificationService {
  final notificationService = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/launcher_icon");
    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );
    //when app is closed
    final details = await notificationService.getNotificationAppLaunchDetails();
    if (details!.didNotificationLaunchApp) {
      final payload = details.notificationResponse!.payload;
      onNotificationClick.add(payload);
    }

    await notificationService.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<NotificationDetails> notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.max,
      color: colors.Colors.orange,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
    return notificationDetails;
  }

  Future<void> showScheduledNotifications({
    required int id,
    required String title,
    required String body,
    required scheduledDate,
  }) async {
    final details = await notificationDetails();
    await notificationService.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload!.isNotEmpty) {
      onNotificationClick.add(payload);
    }
  }
}
