import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

abstract interface class CeremonyNotificationGateway {
  Future<void> initialize({required bool requestPermission});
  Future<void> cancel(int id);
  Future<void> schedule({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    required String payload,
  });
}

class AndroidCeremonyNotificationGateway
    implements CeremonyNotificationGateway {
  AndroidCeremonyNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize({required bool requestPermission}) async {
    if (!Platform.isAndroid) return;
    if (!_initialized) {
      tz_data.initializeTimeZones();
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      _initialized = true;
    }
    if (requestPermission) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  @override
  Future<void> cancel(int id) async {
    if (!Platform.isAndroid) return;
    await initialize(requestPermission: false);
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    required String payload,
  }) async {
    if (!Platform.isAndroid) return;
    await initialize(requestPermission: false);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'opc_ceremony_reminders',
          'Podsetnici za ceremoniju',
          channelDescription: 'Lokalni podsetnici za predstojeće ceremonije',
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.private,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }
}
