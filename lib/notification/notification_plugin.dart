import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationPlugin {
  static ensureInitialized() {
    
  }

  factory NotificationPlugin.getInstance() {
    _instance ??= NotificationPlugin._();
    return _instance!;
  }

  static NotificationPlugin? _instance;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationPlugin._() {
    init();
  }

  void init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestPermission();
    }
    initializePlatformSpecifics();
  }

  Future<void> _requestPermission() async {
    final iOSImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iOSImplementation != null) {
      await iOSImplementation.requestPermissions(
        alert: true,
        sound: true,
        badge: true,
      );
    }
  }

  void initializePlatformSpecifics() async {
    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('notification');
    DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings,
            iOS: darwinInitializationSettings,
            macOS: darwinInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {},
    );
  }

  Future<void> scheduleNotification() async {
    var dateTime = tz.TZDateTime.now(tz.UTC).add(Duration(seconds: 5));
    var androidChannelSpecifics = AndroidNotificationDetails(
        channelId: 'channel_id',
        channelName: 'channel_name',
        channelDescription: 'channel_desc',
        importance: Importance.max,
        priority: Priority.high,
        timeoutAfter: 5000);
    var platformChannelSpecifics =
        NotificationDetails(android: androidChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        'title',
        'body',
        dateTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time);
    return Future.value();
  }
}
