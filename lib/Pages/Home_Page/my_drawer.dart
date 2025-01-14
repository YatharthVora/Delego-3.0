import 'package:flutter/material.dart';
import 'package:delego/Pages/Home_Page/my_list_tile.dart';
import 'package:delego/Pages/Sponsors_Page/sponsor_page.dart';

class MyDrawer extends StatefulWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignoutTap;

  const MyDrawer(
      {super.key, required this.onProfileTap, required this.onSignoutTap});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {


  void goToSponsorsPage() {
    // pop the menu
    Navigator.pop(context);
    //naviget to Profile Page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SponsorPage()));
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // header
              DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              //home list tile
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),
              // Profile list tile
              MyListTile(
                  icon: Icons.person,

                  text: 'P R O F I L E',
                  onTap: widget.onProfileTap),
              MyListTile(
                icon: Icons.handshake,
                text: 'S P O N S O R S',
                onTap: goToSponsorsPage,
              ),

                  text: 'S E T T I N G S',
                  onTap: widget.onProfileTap),

            ],
          ),
          // Logout tile
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: MyListTile(
                icon: Icons.logout, text: 'L O G O U T', onTap: widget.onSignoutTap),
          )
        ],
      ),
    );
  }
}
