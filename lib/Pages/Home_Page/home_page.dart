import 'package:delego/Pages/Login_Page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:delego/Pages/Home_Page/my_drawer.dart';
import 'package:delego/Pages/Profile_Page/profile_page.dart';
import 'package:delego/Pages/Room_Page/room_page.dart';
import 'package:delego/Pages/Schedule_Page/schedule_page.dart';
import 'package:delego/Pages/Study Guides/study_guidespage.dart';
import 'package:delego/Pages/Qr_Page/Qr_code.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/Theme/theme_controller.dart';

class HomePage extends StatefulWidget {
  final ThemeController controller;
  const HomePage({super.key, required this.controller});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(controller: widget.controller),
      ),
    );
  }

  void goToRoomPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RoomPage()));
  }

  void goToSchedulePage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SchedulePage()));
  }

  void goToQRPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => QrCode()));
  }

  void goToStugyguids() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => StudyGuidespage()));
  }

  Future<void> Signout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("id");
    await prefs.remove("firstname");
    await prefs.remove("lastname");
    await prefs.remove("email");
    await prefs.remove("contact");
    await prefs.remove("dateOfBirth");
    await prefs.remove("gender");
    await prefs.remove("qr");

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(controller: widget.controller)),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          elevation: 0.0,
          foregroundColor: scheme.onSurface,
        ),
        drawer: MyDrawer(
          onProfileTap: goToProfilePage,
          onSignoutTap: () async => await Signout(),
        ),
        body: Center(
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 2, 10),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 3, 6),
                                child: Text(
                                  'Mumbai',
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: scheme.onSurface,
                                    fontFamily: 'Poppins-Bold',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(3, 0, 0, 6),
                                child: Text(
                                  'MUN',
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: scheme.onSurface,
                                    fontFamily: 'Poppins-Bold',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(2, 10, 0, 0),
                          child: Text(
                            '2025',
                            style: textTheme.titleLarge?.copyWith(
                              color: scheme.onSurface,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 6, 0),
                      height: 85,
                      width: 85,
                      child: Image.asset('assets/icons/logo.png'),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                width: 357.39,
                height: 4.37,
                decoration: ShapeDecoration(
                  color: scheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(33.84),
                  ),
                ),
              ),
              _HomeCard(
                indexText: '01.',
                titleLeft: 'Study',
                titleRight: 'Guides',
                imageAsset: 'assets/icons/book_icon.png',
                onTap: goToStugyguids,
              ),
              _HomeCard(
                indexText: '02.',
                titleLeft: 'My',
                titleRight: 'QR',
                imageAsset: 'assets/icons/qr_logo.png',
                onTap: goToQRPage,
              ),
              _HomeCard(
                indexText: '03.',
                titleLeft: 'Rooms',
                titleRight: '',
                imageAsset: 'assets/icons/location.png',
                onTap: goToRoomPage,
              ),
              _HomeCard(
                indexText: '04.',
                titleLeft: 'Schedule',
                titleRight: '',
                imageAsset: 'assets/icons/schedule.png',
                onTap: goToSchedulePage,
              ),
              // Uncomment and adjust as needed for sponsor row:
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
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String indexText;
  final String titleLeft;
  final String titleRight;
  final String imageAsset;
  final VoidCallback onTap;

  const _HomeCard({
    required this.indexText,
    required this.titleLeft,
    required this.titleRight,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        padding: const EdgeInsets.all(25),
        width: 357.39,
        height: 135.82,
        decoration: ShapeDecoration(
          color: scheme.primary,
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
                SizedBox(
                  width: 61.02,
                  height: 16.10,
                  child: Text(
                    indexText,
                    style: textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                  child: Row(
                    children: [
                      Text(
                        titleLeft,
                        style: textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (titleRight.isNotEmpty)
                        Text(
                          ' ${titleRight}',
                          style: textTheme.titleLarge?.copyWith(
                            color: scheme.onPrimary,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 80,
              width: 80,
              child: Image.asset(imageAsset),
            ),
          ],
        ),
      ),
    );
  }
}
