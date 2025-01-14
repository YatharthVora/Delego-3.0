import 'package:flutter/material.dart';
class SponsorPage extends StatelessWidget {
  const SponsorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SPONSORS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.23,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            height: 0.09,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF114C90),
      ),
      backgroundColor: Colors.white,
      body:Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(child: Image.asset("assets/img/lydas_logo.png"),
            height: 250.0,
          ),
          Container(child: Image.asset("assets/img/RiseUp_Logo.png"),
            height: 250.0,
          ),
          Container(child: Image.asset("assets/img/tiirva_logo.png"),
            height: 250.0,
          ),
        ],
      ),
    );
  }
}
