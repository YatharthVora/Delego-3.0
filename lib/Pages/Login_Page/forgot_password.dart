import 'package:delego/constants/backend.dart';
import 'package:flutter/material.dart';
import 'package:delego/Pages/Login_Page/my_bottons.dart';
import 'package:delego/Pages/Login_Page/my_textfild.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final usernameController = TextEditingController();

  Future<void> sendEmail() async {
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
    if (email.isEmpty) {
      Navigator.of(context).pop(); // Close loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in the email.")),
      );
      return;
    }

    try {
      // Send email
      final response = await http.get(
        Uri.parse('${Backend.baseUrl}/forgot_password?email=$email'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      // Close loading indicator
      Navigator.of(context).pop();

      // Parse response data
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message']?.toString() ??
                'Email sent successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (responseData['detail'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['error']?.toString() ??
                  'Please try again later.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['detail']?.toString() ??
                'An error occurred. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if there's an exception
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An error occurred. Please try again later."),
            backgroundColor: Colors.red),
      );
      print("Error in sendEmail: $e"); // Logging error for debugging
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

                // email textfield
                MyTextField(
                  controller: usernameController,
                  hintText: 'Email ID',
                  obscureText: false,
                ),

                const SizedBox(height: 15),

                // send email button
                MyButton(
                  text: 'Send Email',
                  onTap: () async {
                    await sendEmail();
                  },
                ),

                const SizedBox(height: 30),

                // already a member? login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    TextButton(
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
