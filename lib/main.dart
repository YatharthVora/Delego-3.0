import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Pages/Login_Page/login_page.dart';
import 'Pages/Home_Page/home_page.dart';

// Centralized theming imports
import 'Theme/app_theme.dart';
import 'Theme/theme_controller.dart';

void main() {
  runApp(MyApp(controller: ThemeController()));
}

class MyApp extends StatefulWidget {
  final ThemeController controller;
  const MyApp({super.key, required this.controller});

  @override
  State<MyApp> createState() => _MyAppState();
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
    final String? token = prefs.getString('token');

    if (!mounted) return;
    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
    });

    // Keep the timed splash dismissal (3s) from your updated code
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        showLaunchScreen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          themeMode: widget.controller.mode,
          home: showLaunchScreen
              ? LaunchScreen(onLaunchComplete: _onLaunchComplete)
              : (isLoggedIn == true
              ? HomePage(controller: widget.controller)
              : LoginPage(controller: widget.controller)),
        );
      },
    );
  }

  void _onLaunchComplete() {
    if (!mounted) return;
    setState(() {
      showLaunchScreen = false;
    });
  }
}

class LaunchScreen extends StatefulWidget {
  final VoidCallback onLaunchComplete;
  const LaunchScreen({super.key, required this.onLaunchComplete});

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

    _logoController =
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..forward();

    _textController1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _textController2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

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
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoController,
              child: Image.asset(
                // Use your new updated asset if needed; keeping prior themed version:
                'assets/icons/logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _textController1,
              child: Text(
                'MumbaiMUN 2025',
                style: textTheme.titleLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _textController2,
              child: RichText(
                text: TextSpan(
                  style: textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    TextSpan(
                      text: 'REDEFINING THE NORM',
                      // Primary color adapts to light/dark and your brand palette
                      style: TextStyle(color: scheme.primary),
                    ),
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
