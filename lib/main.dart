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
    _initializeApp();
  }


  Future<void> _initializeApp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); 

    setState(() {
      isLoggedIn = token != null && token.isNotEmpty; 
    });


    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        showLaunchScreen = false; 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: showLaunchScreen
          ? LaunchScreen(onLaunchComplete: _onLaunchComplete) 
          : (isLoggedIn == true ? HomePage() : LoginPage()),
    );
  }

  void _onLaunchComplete() {
    setState(() {
      showLaunchScreen = false;
    });
  }
}

class LaunchScreen extends StatefulWidget {
  final Function onLaunchComplete; 

  LaunchScreen({required this.onLaunchComplete});

  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController1;
  late AnimationController _textController2;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..forward();

    _textController1 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _textController2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

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

    _textController2.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 500), () {
          widget.onLaunchComplete(); 
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
                'assets/icons/logo.png',
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
