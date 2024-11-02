import 'package:flutter/material.dart';

class RoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Rooms'),
      ),
       body:  Center(
        child: ListView(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            padding: EdgeInsets.all(25),
            width: 357.39,
            height: 135.82,
            decoration: ShapeDecoration(
              color: Color(0xFF114C90),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.92),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //name
                    SizedBox(
                      width: 70.02,
                      height: 30.10,
                      child: Text(
                        'AIPPM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.23,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          height: 0.09,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    SizedBox(
                      width: 70.02,
                      height: 30.10,
                      child: Text(
                        'CR 203',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.23,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 0.09,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 70.35,
                      height: 17.80,
                      child: Text(
                        'Floor 2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19.65,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 0.06,
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  height: 70,
                  width: 70,
                  child: Image.asset('assets/icons/location.png'),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            padding: EdgeInsets.all(25),
            width: 357.39,
            height: 135.82,
            decoration: ShapeDecoration(
              color: Color(0xFF114C90),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.92),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //name
                    SizedBox(
                      width: 70.02,
                      height: 30.10,
                      child: Text(
                        'AIPPM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.23,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          height: 0.09,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    SizedBox(
                      width: 70.02,
                      height: 30.10,
                      child: Text(
                        'CR 203',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.23,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 0.09,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 70.35,
                      height: 17.80,
                      child: Text(
                        'Floor 2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19.65,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 0.06,
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  height: 70,
                  width: 70,
                  child: Image.asset('assets/icons/location.png'),
                )
              ],
            ),
          ),
        ],
    ),)
    );
  }
}