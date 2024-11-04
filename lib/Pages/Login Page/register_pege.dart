import 'package:flutter/material.dart';
import 'package:delego/pages/Login%20Page/my_bottons.dart';
import 'package:delego/pages/Login%20Page/my_textfild.dart';



class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  // text editing controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController =TextEditingController();
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
                const SizedBox(height: 30),

                // logo
                Icon(
                  Icons.lock,
                  color: Colors.blue.shade900,
                  size: 100,
                ),

                const SizedBox(height: 20),

                // text
                Text(
                  'DELEGO',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 50),

                // FirstName textfild
                MyTextField(controller: firstNameController,
                    hintText: 'First Name',
                    obscureText: false),

                const SizedBox(height: 10),

                // LastName textfild
                MyTextField(controller: lastNameController ,
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
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700]),
                    ),
                    TextButton(
                      // style if needed
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child:Text(
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
