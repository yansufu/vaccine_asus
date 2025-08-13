import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotiService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }


  Future<void> showMissingVaccination({
    required String childName,
    required List<String> missingNames,
    required int id,
  }) async {
    final title = "Vaccination reminder";
    final body = "$childName is missing ${missingNames.join(", ")}.";
    await _showNotification(id, title, body);
  }

  Future<void> _showNotification(int id, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'vaccination_channel',
      'Vaccination Notifications',
      channelDescription: 'Reminders for vaccinations',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}
