import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/Pages/Login_Page/my_bottons.dart';
import 'package:delego/Pages/Login_Page/my_textfild.dart';
import 'package:delego/Pages/Login_Page/register_pege.dart';
import 'package:delego/Pages/Home_Page/home_page.dart';
import 'package:delego/constants/backend.dart';
import 'package:delego/Pages/Login_Page/my_bottons.dart';
import 'package:delego/Pages/Login_Page/my_textfild.dart';
import 'package:delego/pages/Login_Page/register_pege.dart';
import 'package:delego/Pages/Home_Page/home_page.dart';
import 'package:delego/Pages/Profile_Page/profil_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/Pages/Login_Page/forgot_password.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  setfirsttime_login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
// Save an boolean value to 'repeat' key.
    await prefs.setBool('ftl', true);
  }

  getfirsttime_login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? ftl = prefs.getBool('ftl');
    return ftl;
  }

  // sign user in method
  void signUserIn() async {
    // Get the values from the text fields
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    // Check if the fields are not empty
    if (email.isEmpty || password.isEmpty) {
      // Show a snackbar or alert if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill in both fields."),
      ));
      return;
    }

    // Prepare the body of the POST request

    final body = {
      'grant_type':
          'password', // Example: password grant type, adjust if necessary
      'username': email,
      'password': password,
      'scope': '', // Adjust if necessary (e.g., 'read', 'write', etc.)
      'client_id': 'your_client_id', // Provide actual client ID
      'client_secret': 'your_client_secret', // Provide actual client secret
    };

    try {
      // Send the POST request to the server
      final response = await http.post(
        Uri.parse(Backend.baseUrl + '/login'),
        body: body,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        encoding: Encoding.getByName('utf-8'),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final String token = responseData['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);

        // Navigate to the HomePage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        final String errorCode = responseData['detail'].split(':')[0];
        final String errorMessage = responseData['detail'].split(':')[1];

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$errorMessage : Error $errorCode"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("An error occurred. Please check your internet connection."),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Container(
                  margin: EdgeInsets.all(0),
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/icons/Blue_outline_logo.png"),
                ),

                // text
                Text(
                  'DELEGO',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // username textfield
                MyTextField(
                  controller: usernameController,
                  hintText: 'Email ID',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        // style if needed
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword()));
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // sign in button
                MyButton(
                  text: 'Login',
                  onTap: signUserIn,
                ),

                const SizedBox(height: 50),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    TextButton(
                      // style if needed
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ));
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
