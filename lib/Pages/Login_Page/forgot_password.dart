import 'package:flutter/material.dart';
import 'package:delego/Pages/Login_Page/my_bottons.dart';
import 'package:delego/Pages/Login_Page/my_textfild.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  // sign user in method
  void signUserUp() {}

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
                  height:200,
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

                const SizedBox(height: 15),

                // sign up button
                MyButton(
                  text: 'Send Mail',
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