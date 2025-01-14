import 'package:delego/Pages/Login_Page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:delego/Pages/Home_Page/my_drawer.dart';
import 'package:delego/Pages/Profile_Page/profil_page.dart';
import 'package:delego/Pages/Room_Page/room_page.dart';
import 'package:delego/Pages/Schedule_Page/schedule_page.dart';
import 'package:delego/Pages/Study Guides/study_guidespage.dart';
import 'package:delego/Pages/Qr_Page/Qr_code.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Navigate to profile page
  void goToProfilePage() {
    // pop the menu
    Navigator.pop(context);
    //naviget to Profile Page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  void goToRoomPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RoomPage()));
  }

  void goToSchedulePage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SchedulePage()));
  }

  void goToQRPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => QrCode()));
  }

  void goToStugyguids() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => StudyGuidespage()));
  }

  Signout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("id");
    prefs.remove("firstname");
    prefs.remove("lastname");
    prefs.remove("email");
    prefs.remove("contact");
    prefs.remove("dateOfBirth");
    prefs.remove("gender");
    prefs.remove("qr");

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
            drawer: MyDrawer(
              onProfileTap: goToProfilePage,
              onSignoutTap: () async {
                await Signout();
              },
            ),
            body: Center(
              child: ListView(children: [
                Container(
                    margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 285,
                              height: 30,
                              margin: EdgeInsets.fromLTRB(0, 0, 2, 10),
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0,0,3,0),
                                    child: Text(
                                      'MUMBAI',
                                      style: TextStyle(
                                        color: Color(0xFF114C90),
                                        fontSize: 32,
                                        fontFamily: 'Poppins-Bold',
                                        fontWeight: FontWeight.bold,
                                        height: 0.03,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                                    child: Text(
                                      'MUN',
                                      style: TextStyle(
                                        color: Color(0xFF114C90),
                                        fontSize: 32,
                                        fontFamily: 'Poppins-Bold',
                                        fontWeight: FontWeight.bold,
                                        height: 0.03,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 100,
                              height: 20,
                              margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                              child: Text(
                                '2024',
                                style: TextStyle(
                                  color: Color(0xFF114C90),
                                  fontSize: 24,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  height: 0.03,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.zero,
                          height: 80,
                          width: 80,
                          child:
                              Image.asset('assets/icons/Blue_outline_logo.png'),
                        )
                      ],
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(6, 2, 6, 2),
                  width: 357.39,
                  height: 4.37,
                  decoration: ShapeDecoration(
                    color: Color(0xFF114C90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(33.84),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: goToStugyguids,
                  child: Container(
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
                            Container(
                              width: 61.02,
                              height: 16.10,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
                              child: Text(
                                '01.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  height: 0.09,
                                ),
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                    child: Text(
                                      'Study',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        height: 0.06,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(3, 0, 0, 0),
                                    child: Text(
                                      'Guides',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        height: 0.06,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Container(
                          height: 80,
                          width: 80,
                          child: Image.asset('assets/icons/book_icon.png'),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: goToQRPage,
                  child: Container(
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
                            Container(
                              width: 61.02,
                              height: 16.10,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
                              child: Text(
                                '02.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  height: 0.09,
                                ),
                              ),
                            ),

                            Container(
                              width: 176.35,
                              height: 50,
                              margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                              child: Text(
                                'My QR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                          child: Image.asset('assets/icons/qr_logo.png'),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: goToRoomPage,
                  child: Container(
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
                            Container(
                              width: 61.02,
                              height: 16.10,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
                              child: Text(
                                '03.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  height: 0.09,
                                ),
                              ),
                            ),

                            Container(
                              width: 176.35,
                              height: 50,
                              margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                              child: Text(
                                'Rooms',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                ),
                GestureDetector(
                  onTap: goToSchedulePage,
                  child: Container(
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
                            Container(
                              width: 61.02,
                              height: 16.10,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
                              child: Text(
                                '04.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  height: 0.09,
                                ),
                              ),
                            ),
                            Container(
                              width: 176.35,
                              height: 50,
                              margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                              child: Text(
                                'Schedule',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
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
                          child: Image.asset('assets/icons/schedule.png'),
                        )
                      ],
                    ),  
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.fromLTRB(12, 2, 12, 2),
                //   height: 73,
                //   width: 73,
                //   child: Row(
                //     children: [
                //       Text('Sponsored By:',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           fontFamily: 'Poppins'
                //         ),
                //       ),
                //       Container(
                //         margin: EdgeInsets.fromLTRB(6, 0, 3, 0),
                //           child: Image.asset('assets/icons/RiseUp_Logo.png')
                //       ),
                //     Container(
                //         margin: EdgeInsets.fromLTRB(6, 0, 3, 0),
                //           child: Image.asset('assets/icons/LytAds_Logo.png')
                //       ),
                //       Container(
                //         height: 25,
                //         margin: EdgeInsets.fromLTRB(6, 0, 3, 0),
                //           child: Image.asset('assets/icons/Sultan_deli_Logo.png')
                //       ),
                //     ],
                //   ),
                // )
              ]
              ),
            )
        )
    );
  }
}
