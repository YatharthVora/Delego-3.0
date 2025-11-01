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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SponsorPage()),
    );
  }

  void openPolicy(String policyName) {
    Navigator.pop(context);

    final pdfAsset = (policyName == 'POSH Policy')
        ? 'assets/pdfs/POSH.pdf'
        : 'assets/pdfs/ConferencePolicy.pdf';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(pdfAsset: pdfAsset),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // HEADER
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: scheme.primaryContainer),
              currentAccountPicture: CircleAvatar(
                backgroundColor: scheme.primary,
                child: Icon(Icons.person, color: scheme.onPrimary, size: 40),
              ),
              accountName: Text(
                'Welcome!',
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
              accountEmail: null,
            ),

            // MAIN LIST
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  MyListTile(
                    icon: Icons.home,
                    text: 'HOME',
                    onTap: () => Navigator.pop(context),
                  ),
                  MyListTile(
                    icon: Icons.person,
                    text: 'SETTINGS',
                    onTap: widget.onProfileTap,
                  ),
                  MyListTile(
                    icon: Icons.handshake,
                    text: 'SPONSORS',
                    onTap: goToSponsorsPage,
                  ),

                  // POLICIES (Dropdown simplified)
                  ListTile(
                    leading: Icon(Icons.policy, color: scheme.onSurface),
                    title: Text('POLICIES', style: TextStyle(color: scheme.onSurface)),
                    trailing: PopupMenuButton<String>(
                      icon: Icon(Icons.arrow_drop_down, color: scheme.onSurface),
                      color: scheme.surface,
                      onSelected: openPolicy,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'POSH Policy',
                          child: Text('POSH Policy'),
                        ),
                        const PopupMenuItem(
                          value: 'Conference Policy',
                          child: Text('Conference Policy'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // LOGOUT BUTTON (bottom aligned)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.errorContainer,
                  foregroundColor: scheme.onErrorContainer,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('LOGOUT'),
                onPressed: widget.onSignoutTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
