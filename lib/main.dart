import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/Login_Page/login_page.dart';
import 'Pages/Home_Page/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool showLaunchScreen = true;
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _startLaunchScreen();
  }

  Future<void> _startLaunchScreen() async {
    await Future.delayed(
        Duration(seconds: 5)); // Duration for the launch screen
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
      showLaunchScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: showLaunchScreen
          ? LaunchScreen(
              onLaunchComplete: _startHomePage) // Pass function for transition
          : (isLoggedIn == true ? HomePage() : LoginPage()),
    );
  }

  void _startHomePage() {
    setState(() {
      showLaunchScreen = false;
    });
  }
}

class LaunchScreen extends StatefulWidget {
  final Function
      onLaunchComplete; // Callback for when the launch screen animation finishes

  LaunchScreen({required this.onLaunchComplete});

  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController1;
  late AnimationController _textController2;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..forward();

    // "MumbaiMUN 2024" text animation controller
    _textController1 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    // "DEFINING THE NORM" text animation controller
    _textController2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    // Start text animations in sequence
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textController1.forward();
      }
    });

    _textController1.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textController2.forward();
      }
    });

    // After all animations, navigate to the next page
    _textController2.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Introduce a delay after animations to make the transition smooth
        Future.delayed(Duration(milliseconds: 500), () {
          widget
              .onLaunchComplete(); // Trigger the callback to transition to HomePage
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController1.dispose();
    _textController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoController,
              child: Image.asset(
                'assets/icons/Blue_outline_logo.png', // Ensure logo is in assets folder
                height: 100,
              ),
            ),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _textController1,
              child: Text(
                'MumbaiMUN 2024',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _textController2,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                        text: 'REDEFINING THE NORM',
                        style: TextStyle(color: Colors.blue.shade900)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
