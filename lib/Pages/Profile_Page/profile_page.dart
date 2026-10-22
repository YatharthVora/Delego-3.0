import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/Pages/Login_Page/login_page.dart';
import 'package:delego/Pages/Policy_Page/policy_page.dart';
import 'package:delego/Pages/Profile_Page/text_box.dart';
import 'package:delego/Theme/theme_controller.dart';
import 'package:delego/api/scan_queue.dart';
import 'package:delego/auth/capabilities.dart';
import 'package:delego/constants/backend.dart';
import 'package:delego/widgets/neon.dart';

class ProfilePage extends StatefulWidget {
  final ThemeController controller;
  const ProfilePage({super.key, required this.controller});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? firstname, lastname, email, contact, dateofbirth, diet;

  static String _formatDiet(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Not Set';
    switch (raw.trim().toLowerCase()) {
      case 'veg':
        return 'Veg';
      case 'jain':
        return 'Jain';
      default:
        return raw.trim();
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      firstname = prefs.getString('firstname');
      lastname = prefs.getString('lastname');
      email = prefs.getString('email');
      contact = prefs.getString('contact');
      dateofbirth = prefs.getString('dateofbirth');
      diet = _formatDiet(prefs.getString('diet'));
      if (contact == null || contact!.isEmpty) contact = '-';
      if (dateofbirth == null || dateofbirth!.isEmpty) {
        dateofbirth = '-';
      }
    });

    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    try {
      final mmRes = await http.get(
        Uri.parse('${Backend.baseUrl}/mumbaimun/delegates/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (mmRes.statusCode == 200) {
        final data = json.decode(mmRes.body);
        final serverContact = (data['contact'] ?? '').toString();
        final serverDob = (data['dateofbirth'] ?? '').toString();
        final serverDiet = data['food_preference']?.toString();

        if (serverContact.isNotEmpty) {
          await prefs.setString('contact', serverContact);
        }
        if (serverDob.isNotEmpty) {
          await prefs.setString('dateofbirth', serverDob);
        }
        if (serverDiet != null && serverDiet.isNotEmpty) {
          await prefs.setString('diet', _formatDiet(serverDiet));
        }

        if (!mounted) return;
        setState(() {
          if (serverContact.isNotEmpty) contact = serverContact;
          if (serverDob.isNotEmpty) dateofbirth = serverDob;
          if (serverDiet != null && serverDiet.isNotEmpty) {
            diet = _formatDiet(serverDiet);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> deleteAccount() async {
    final scheme = Theme.of(context).colorScheme;
    final confirmDelete = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to permanently delete your account and associated data? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete || !mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (!mounted) return;
    final queue = context.read<ScanQueue>();
    final caps = context.read<Capabilities>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final response = await http.delete(
        Uri.parse('${Backend.baseUrl}/account'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        await prefs.clear();
        await queue.clearAll();
        caps.clear();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(controller: widget.controller),
          ),
          (Route<dynamic> route) => false,
        );
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String message = 'Could not delete account.';
        try {
          final responseData = json.decode(response.body);
          message = (responseData['detail'] ?? responseData).toString();
        } catch (_) {}
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: scheme.error,
          ),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Error deleting account. Please check your internet connection.',
          ),
          backgroundColor: scheme.error,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Widget _header(String text, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Text(
        text.toUpperCase(),
        style: textTheme.titleSmall?.copyWith(
          color: Neon.pink,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Neon.pink,
        centerTitle: true,
        title: Text('Settings',
            style: textTheme.titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.person, size: 72, color: Neon.pink),
            _header('My Profile', textTheme),
            MyTextBox(
                text: firstname ?? 'First Name', sectionName: 'First Name'),
            MyTextBox(text: lastname ?? 'Last Name', sectionName: 'Last Name'),
            MyTextBox(text: email ?? 'Email', sectionName: 'Email'),
            MyTextBox(text: contact ?? '-', sectionName: 'Contact Number'),
            MyTextBox(text: dateofbirth ?? '-', sectionName: 'Date of Birth'),
            MyTextBox(text: diet ?? 'Not Set', sectionName: 'Food Preference'),
            _header('Legal & Account', textTheme),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.onSurface,
                  side: BorderSide(color: Neon.pink.withValues(alpha: 0.45)),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.privacy_tip_outlined, color: Neon.pink),
                label: const Text('Privacy Policy'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.delete_forever_rounded),
                label: Text(
                  'Delete Account',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: deleteAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
