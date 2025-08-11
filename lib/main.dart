import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaccine_app/roleSelect.dart';
import 'parents/navbar.dart';
import 'provider/navbar.dart';
import 'parents/noti_service.dart';

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