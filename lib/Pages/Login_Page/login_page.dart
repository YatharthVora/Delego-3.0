import 'package:delego/Pages/Profile_Page/profil_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/Pages/Login_Page/my_buttons.dart';
import 'package:delego/Pages/Login_Page/my_textfield.dart';
import 'package:delego/Pages/Login_Page/register_page.dart';
import 'package:delego/Pages/Home_Page/home_page.dart';
import 'package:delego/constants/backend.dart';
import 'package:delego/Pages/Login_Page/forgot_password.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> fetchAndStoreImage(String id) async {
    try {
      final response =
          await http.get(Uri.parse(Backend.baseUrl + '/qr?id=$id'));

      if (response.statusCode == 200) {
        // Convert image bytes to base64
        String base64Image = base64Encode(response.bodyBytes);

        // Store base64 string in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('qr', base64Image);
        print("Image stored in SharedPreferences.");
      } else {
        print("Failed to fetch image: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching or storing image: $e");
    }
  }

  setLoggedInBefore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lib', true);
  }

  getLoggedInBefore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? ftl = prefs.getBool('lib');
    return ftl;
  }

  clearPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // sign user in method
  void signUserIn() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dialog from closing on outside tap
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Get the values from the text fields
    final email = usernameController.text.trim();
    final password = passwordController.text.trim();

    // Check if the fields are not empty
    if (email.isEmpty || password.isEmpty) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill in both fields."),
      ));
      return;
    }

    // Prepare the body of the POST request

    final body = {
      'username': email,
      'password': password,
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
        await prefs.setString('token', token);

        final response = await http.get(
          Uri.parse(Backend.baseUrl + '/delegates/me'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        final data = json.decode(response.body);

        if (data['detail'] == 'Please verify your email!') {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['detail']),
            backgroundColor: Colors.red,
          ));
          return;
        }

        final id = data['id'] ?? '';
        final firstname = data['firstname'] ?? '';
        final lastname = data['lastname'] ?? '';
        final email = data['email'] ?? '';
        final contact = data['contact'] ?? '';
        final dateofbirth = data['dateofbirth'] ?? '';
        final gender = data['gender'] ?? '';
        await prefs.setString('id', id);
        await prefs.setString('firstname', firstname);
        await prefs.setString('lastname', lastname);
        await prefs.setString('email', email);
        await prefs.setString('contact', contact);
        await prefs.setString('dateofbirth', dateofbirth);
        await prefs.setString('gender', gender);

        await fetchAndStoreImage(id);

        // Navigate to the HomePage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        if (await getLoggedInBefore() != true) {
          setLoggedInBefore();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Update Info',
              ),
              backgroundColor: Colors.grey.shade700,
              action: SnackBarAction(
                  label: "Profile",
                  textColor: Colors.lightBlue,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  }),
            ),
          );
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['detail'].toString()),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      Navigator.of(context).pop();
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
