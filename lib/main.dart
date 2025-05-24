import 'package:flutter/material.dart';
import 'parents/registerParents.dart'; // Make sure this matches your file name

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ibu Digi',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Urbanist', // Optional: if you want consistent font
      ),
      home: const RegisterParents(),
    );
  }
}
