import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future initNotifications() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('shizen_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.example.shizen_app' : 'com.example.shizen_app',
      'Shizen Notification',
      channelDescription: 'Notification for Shizen App',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        await flutterLocalNotificationsPlugin.show(
            0,
            message.notification!.title,
            message.notification!.body,
            platformChannelSpecifics,
            payload: 'test');
      }
    });
  }

  Future getPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotificationRequests;
  }

  Future cancelNotification(id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> showNotification(
      String id, String title, String body, DateTime dateTime) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(
          seconds: DateTime.now().difference(dateTime).inSeconds.abs())),
      const NotificationDetails(
        // Android details
        android: AndroidNotificationDetails(
          'todo_channel',
          'To Do Tasks',
          channelDescription: "Notifications for To Do Tasks",
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
        ),
        // iOS details
        iOS: IOSNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'todo,$id',
      // Type of time interpretation
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle:
          true, // To show notification even when the app is closed
    );
  }

  Future<void> showTrackerDailyNotification(
      String id, String title, String body, DateTime dateTime) async {
    final now = DateTime.now();
    if (dateTime.isBefore(now)) {
      dateTime.add(Duration(days: 1));
    }
    tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(
        Duration(seconds: DateTime.now().difference(dateTime).inSeconds.abs()));
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id.hashCode,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          // Android details
          android: AndroidNotificationDetails(
            'tracker_channel',
            'Daily Tracker',
            channelDescription: "Notifications for Daily Tracker",
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
          ),
          // iOS details
          iOS: IOSNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'trackers,$id',
        // Type of time interpretation
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle:
            true, // To show notification even when the app is closed
        matchDateTimeComponents: DateTimeComponents.time);
  }
}
