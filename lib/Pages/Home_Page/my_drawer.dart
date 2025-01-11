import 'package:flutter/material.dart';
import 'package:delego/Pages/Home_Page/my_list_tile.dart';

class MyDrawer extends StatefulWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignoutTap;

  const MyDrawer(
      {super.key, required this.onProfileTap, required this.onSignoutTap});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {

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
