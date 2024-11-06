import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/constants/backend.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:delego/Pages/Login_Page/my_bottons.dart';
import 'package:delego/Pages/Login_Page/my_textfild.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // sign user in method
  void signUserUp() async {
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

    final email = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      // Show a snackbar or alert if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill in all fields."),
      ));
      return;
    }

    if (password != confirmPassword) {
      // Show a snackbar or alert if passwords don't match
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Passwords do not match."),
      ));
      return;
    }

    if (password.length < 8) {
      // Show a snackbar or alert if password is too short
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Password must be at least 8 characters long."),
      ));
      return;
    }

    final body = {
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'password': password,
    };

    try {
      // Send the POST request to the server
      final response = await http.post(
        Uri.parse(Backend.baseUrl + '/mumbaimun/register'),
        body: jsonEncode(body),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Registration successful. Please verify your email."),
          backgroundColor: Colors.green,
        ));
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['detail'].toString()),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      Navigator.of(context).pop();
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

                // FirstName textfild
                MyTextField(
                    controller: firstNameController,
                    hintText: 'First Name',
                    obscureText: false),

                const SizedBox(height: 10),

                // LastName textfild
                MyTextField(
                    controller: lastNameController,
                    hintText: 'Last Name',
                    obscureText: false),

                const SizedBox(height: 10),

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

                // confirm password textfield
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 15),

                // sign up button
                MyButton(
                  text: 'Sign Up',
                  onTap: signUserUp,
                ),

                const SizedBox(height: 30),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    TextButton(
                      // style if needed
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
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
