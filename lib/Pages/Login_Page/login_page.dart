import 'package:flutter/material.dart';
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
  void signUserIn() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Complete Profile Page',
      style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.grey.shade700,
      action: SnackBarAction(label: "Goto Profile", textColor: Colors.blue,
          onPressed:() {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ProfilePage()));
          }  ),),
    );
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
                              context, MaterialPageRoute(builder: (context) => ForgotPassword()));
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
