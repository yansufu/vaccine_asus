import 'package:flutter/material.dart';
import 'parents/login.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'parents/navbar.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final parentId = prefs.getInt('parent_id');
  final childId = prefs.getInt('child_id');

  runApp(MyApp(
    parentID: parentId,
    childID: childId,
  ));
}

class MyApp extends StatelessWidget {
  final int? parentID;
  final int? childID;
  const MyApp({super.key, this.parentID, this.childID});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ibu Digi',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Urbanist', // Optional: if you want consistent font
      ),
      home: (parentID != null && childID != null)
          ? NavBar_screen(
              parentID: parentID.toString(),
              childID: childID!,
            )
          : LoginParents(),
    );
  }
}
