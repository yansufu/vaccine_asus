import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiService{
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //INITIALIZE
  Future<void> initNotification() async{
    if (_isInitialized) return;
    
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    await notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  // NOTIFICATION DETAILS
  NotificationDetails notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          'daily_channel_id',
          'Daily Notifications',
          channelDescription: "try notif",
          importance: Importance.max,
          priority: Priority.high)
    );
  }

  // SHOW NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
}) async{
    print('Showing notification: $title - $body');
    await notificationsPlugin.show(id, title, body, notificationDetails());
    print('Notification requested');
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  // ON NOTI TAP
}