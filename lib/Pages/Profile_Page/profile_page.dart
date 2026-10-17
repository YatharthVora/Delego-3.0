import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:delego/Pages/Profile_Page/text_box.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delego/Theme/theme_controller.dart';
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
      case 'non_veg':
      case 'non-veg':
      case 'nonveg':
        return 'Non-Veg';
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
        dateofbirth = 'dd-mm-yyyy';
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Neon.pink,
        centerTitle: true,
        title: Text('Settings',
            style: textTheme.titleLarge?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.person, size: 72, color: Neon.pink),
          _header('My Profile', textTheme),
          MyTextBox(text: firstname ?? 'First Name', sectionName: 'First Name'),
          MyTextBox(text: lastname ?? 'Last Name', sectionName: 'Last Name'),
          MyTextBox(text: email ?? 'Email', sectionName: 'Email'),
          MyTextBox(
              text: contact ?? 'Contact Number',
              sectionName: 'Contact Number'),
          MyTextBox(
              text: dateofbirth ?? 'Date of Birth',
              sectionName: 'Date of Birth'),
          MyTextBox(text: diet ?? 'Not Set', sectionName: 'Food Preference'),
        ],
      ),
    );
  }
}
