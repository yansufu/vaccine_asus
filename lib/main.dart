import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaccine_app/roleSelect.dart';
import 'parents/navbar.dart';
import 'provider/navbar.dart';
import 'parents/noti_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const fetchVaccinationTask = "fetchVaccinationTask";
const String fetchVaccinationTaskUniqueName = "fetchVaccinationTaskUniqueName";

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == fetchVaccinationTask || taskName == "testOneOffTask") {
      print("⚙️ Background task triggered with taskName: $taskName");
      if (taskName == fetchVaccinationTask) {
        final childId = inputData?['childId'];
        print("👶 Child ID from inputData: $childId");
        if (childId == null) return Future.value(false);

        // Initialize notifications plugin
        print("🔔 Initializing notifications plugin");
        const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        const initSettings =
        InitializationSettings(android: androidInitSettings);
        await flutterLocalNotificationsPlugin.initialize(initSettings);

        try {
          print("🌐 Fetching vaccination status for child $childId");
          // Fetch vaccination status
          final response = await http.get(
              Uri.parse('http://10.0.2.2:8000/api/child/$childId/vaccinations/status'));
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            final notCompleted = data.where((item) => item['status'] == false).toList();

            if (notCompleted.isNotEmpty) {
              final missingNames = notCompleted.map((item) => item['name']).join(', ');
              print("🔔 Showing notification with missing: $missingNames");


              // Show notification
              const androidDetails = AndroidNotificationDetails(
                'daily_channel_id',
                'Daily Notifications',
                channelDescription: 'Vaccination reminders',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
              );
              const notificationDetails = NotificationDetails(android: androidDetails);

              await flutterLocalNotificationsPlugin.show(
                0,
                'Vaccination Reminder',
                '$missingNames is missing for your child',
                notificationDetails,
              );
            }
          }
        } catch (e) {
          print('Error in background task: $e');
          return Future.value(false);
        }

        return Future.value(true);
      }
    }

    return Future.value(false);
  });
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init notif
  await NotiService().initNotification();

  final prefs = await SharedPreferences.getInstance();

  final parentIdInt = prefs.getInt('parent_id');
  final parentId = parentIdInt != null ? parentIdInt.toString() : null;
  final childId = prefs.getInt('child_id');
  final provID = prefs.getInt('provID');

  print("parentId: $parentId");
  print("childId: $childId");
  print("provID: $provID");


  await Workmanager().registerOneOffTask(
    "testOneOffTask",
    fetchVaccinationTask,
    inputData: {'childId': childId},
  );

  if (childId != null) {
    try {
      await Workmanager().registerPeriodicTask(
        "fetchVaccinationTaskUniqueName",  // unique name
        fetchVaccinationTask,              // task name from callbackDispatcher
        inputData: {'childId': childId},
        frequency: const Duration(hours: 24),
        initialDelay: const Duration(seconds: 10),
        constraints: Constraints(networkType: NetworkType.connected),
      );
      print('Background task registered');
    } catch (e) {
      print('Error registering periodic task: $e');
    }
  }

  runApp(MyApp(
    parentID: parentId,
    childID: childId,
    provID: provID,
  ));
}

class MyApp extends StatelessWidget {
  final String? parentID;
  final int? childID;
  final int? provID;

  const MyApp({
    super.key,
    required this.parentID,
    required this.childID,
    required this.provID,
  });

  @override
  Widget build(BuildContext context) {
    late Widget homeScreen;

    if (parentID != null && childID != null) {
      print("Navigating to parent navbar");
      homeScreen = NavBar_screen(parentID: parentID!, childID: childID!);
    } else if (provID != null) {
      print("Navigating to provider navbar");
      homeScreen = NavBar_prov(provID: provID!);
    } else {
      print("Navigating to role selection");
      homeScreen = const roleSelect();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ibu Digi',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Urbanist',
      ),
      home: homeScreen,
    );
  }
}