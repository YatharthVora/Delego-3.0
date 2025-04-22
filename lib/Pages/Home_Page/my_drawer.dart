import 'package:flutter/material.dart';
import 'package:delego/Pages/Home_Page/my_list_tile.dart';
import 'package:delego/Pages/Sponsors_Page/sponsor_page.dart';
import 'package:delego/Pages/Policy_Page/policy_page.dart';

class MyDrawer extends StatefulWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignoutTap;

  const MyDrawer({
    Key? key,
    required this.onProfileTap,
    required this.onSignoutTap,
  }) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  void goToSponsorsPage() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => SponsorPage()));
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
              // Drawer Header
              DrawerHeader(
                child: Icon(Icons.person, color: Colors.white, size: 64),
              ),
              // HOME
              MyListTile(
                icon: Icons.home,
                text: 'HOME',
                onTap: () => Navigator.pop(context),
              ),
              // SETTINGS
              MyListTile(
                icon: Icons.person,
                text: 'SETTINGS',
                onTap: widget.onProfileTap,
              ),
              // SPONSORS
              MyListTile(
                icon: Icons.handshake,
                text: 'SPONSORS',
                onTap: goToSponsorsPage,
              ),

              MyListTile(
                icon: Icons.policy_sharp,
                text: 'POLICIES',
                onTap: () {},
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: const [
                      DropdownMenuItem(
                        value: 'POSH Policy',
                        child: Text('POSH Policy', style: TextStyle(color: Colors.black)),
                      ),
                      DropdownMenuItem(
                        value: 'Conference Policy',
                        child: Text('Conference Policy', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {

                        Navigator.pop(context);

                        final pdfAsset = (value == 'POSH Policy')
                            ? 'assets/pdfs/Mumbai MUN 2024 POSH Policy.pdf'
                            : 'assets/pdfs/Mumbai MUN 2024 Conference Policy.pdf';

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerPage(pdfAsset: pdfAsset),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: MyListTile(
              icon: Icons.logout,
              text: 'LOGOUT',
              onTap: widget.onSignoutTap,
            ),
          ),
        ],
      ),
    );
  }
}
