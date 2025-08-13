import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
  final AndroidNotificationChannel dailyChannel = const AndroidNotificationChannel(
    'daily_channel_id',
    'Daily Notifications',
    description: 'Daily vaccine reminders',
    importance: Importance.max,
  );

  // Initialize notifications
  Future<void> initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await localNotifications.initialize(initSettings);

    final androidPlatform = localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlatform?.createNotificationChannel(dailyChannel);
  }

  // Schedule notifications 7-1 days before next period
  Future<void> scheduleVaccineNotifications({
    required DateTime nextPeriod,
    required List<dynamic> missingVaccines,
    required String childName,
  }) async {
    if (missingVaccines.isEmpty) return;

    for (int i = 7; i >= 1; i--) {
      final scheduledDate = nextPeriod.subtract(Duration(days: i));
      if (scheduledDate.isBefore(DateTime.now())) continue;

      final missingNames = missingVaccines.map((v) => v['name']).join(', ');

      await localNotifications.zonedSchedule(
        i, // unique ID per notification
        'Vaccination Reminder',
        '$missingNames for $childName is missing. Scheduled in $i days.',
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            dailyChannel.id,
            dailyChannel.name,
            channelDescription: dailyChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
}
