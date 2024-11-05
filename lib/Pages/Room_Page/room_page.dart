import 'package:flutter/material.dart';

class RoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 203',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
            //2nd room
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
                        width: 80.02,
                        height: 30.10,
                        child: Text(
                          'H.UNGA',
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 204',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
                        width: 80.02,
                        height: 30.10,
                        child: Text(
                          'UNGA',
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 204',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
            // 3rd room
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
                          'ILC',
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 205',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
            //4th room
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
                          'UNDP',
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 206',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
//5th room
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
                        width: 190.02,
                        height: 30.10,
                        child: Text(
                          'UNFCCC-COP',
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 207',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
//6th room
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
                          'UNHRC',
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 208',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
//7th room
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
                          'UNODC',
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 301',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
//8th room
//9th room
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
                          'WHO',
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 303',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
                          'UNSC',
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 302',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
//10th room
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
                        width: 190.02,
                        height: 30.10,
                        child: Text(
                          'World Bank',
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
                        width: 75.02,
                        height: 30.10,
                        child: Text(
                          'CR 304',
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
                        width: 70.35,
                        height: 17.80,
                        child: Text(
                          'Floor 3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.65,
                            fontFamily: 'Poppins',
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
        ),
      ),
    );

  }
}