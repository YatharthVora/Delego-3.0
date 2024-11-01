import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'Login Page/login_page.dart';


void main() {
  runApp(

        MyApp()

      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
