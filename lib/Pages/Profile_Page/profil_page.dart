import 'package:delego/Pages/Login_Page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:delego/constants/backend.dart';
import 'package:delego/Pages/Profile_Page/text_box.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? id, firstname, lastname, email, contact, dateofbirth, gender;

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id');
      firstname = prefs.getString('firstname');
      lastname = prefs.getString('lastname');
      email = prefs.getString('email');
      contact = prefs.getString('contact');
      dateofbirth = prefs.getString('dateofbirth');
      gender = prefs.getString('gender');

      if (contact == '') {
        contact = '98*******2';
      }

      if (gender == '') {
        gender = 'Prefer not to say';
      }

      if (dateofbirth == '') {
        dateofbirth = 'dd-mm-yyyy';
      }
    });
  }

  // Save the updated data in SharedPreferences and send to backend
  Future<void> updateUserData(String field, String newValue) async {
    switch (field) {
      case 'First Name':
        field = 'firstname';
        break;
      case 'Last Name':
        field = 'lastname';
        break;
      case 'Contact Number':
        field = 'contact';
        break;
      case 'Date of Birth':
        field = 'dateofbirth';
        break;
      case 'Gender':
        field = 'gender';
        break;
    }

    print("Field: $field, Value: $newValue");

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(field, newValue);

    final token = prefs.getString('token');

    // Send PATCH request
    try {
      final response = await http.patch(
        Uri.parse('${Backend.baseUrl}/delegates/$id?$field=$newValue'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token}',
        },
        body: [],
      );

      final responseData = json.decode(response.body);

      print("Response: $responseData");

      if (response.statusCode == 200) {
        // field to Sentence case
        switch (field) {
          case 'firstname':
            field = 'First Name';
            break;
          case 'lastname':
            field = 'Last Name';
            break;
          case 'contact':
            field = 'Contact Number';
            break;
          case 'dateofbirth':
            field = 'Date of Birth';
            break;
          case 'gender':
            field = 'Gender';
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("$field updated successfully!"),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData.toString(),
                  style: TextStyle(color: Colors.red))),
        );
      }
    } catch (e) {
      print("Error updating $field: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error updating $field."),
            backgroundColor: Colors.red),
      );
    }
  }

  // Delete account function
  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Show confirmation dialog
    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete Account"),
            content: Text(
                "Are you sure you want to delete your account? This action cannot be undone."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDelete) {
      try {
        final response = await http.delete(
          Uri.parse('${Backend.baseUrl}/account'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          await prefs.clear();

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Account deleted successfully."),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("Failed to delete account: ${responseData['detail']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting account."),
            backgroundColor: Colors.red,
          ),
        );
        print("Error deleting account: $e");
      }
    }
  }

  // Display dialog to edit specific field
  Future<void> editField(String field, String currentValue) async {
    String newValue = currentValue;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue.shade900,
        title: Text(
          "Edit $field",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText:
                field == 'Date of Birth' ? "dd-mm-yyyy" : "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Check for Date of Birth format if applicable
              if (field == 'Date of Birth') {
                final datePattern = RegExp(
                    r"^(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-(\d{4})$");
                if (!datePattern.hasMatch(newValue)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Invalid date format. Use dd-mm-yyyy."),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                // Split the date and validate day, month, and year
                final dateParts = newValue.split('-');
                final day = int.parse(dateParts[0]);
                final month = int.parse(dateParts[1]);
                final year = int.parse(dateParts[2]);

                // Basic validation for days in a month
                if (day > 31 ||
                    month > 12 ||
                    year < 1900 ||
                    year > DateTime.now().year) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Invalid date entered."),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
              }

              // Check for Contact Number format
              if (field == 'Contact Number') {
                final contactPattern = RegExp(
                    r"^\+?\d{1,4}[\s\-]?\(?\d{1,4}\)?[\s\-]?\d{1,4}[\s\-]?\d{4,}$");
                if (!contactPattern.hasMatch(newValue)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Invalid contact number"),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
              }

              // Update data if the new value is valid and different from the current value
              if (newValue.isNotEmpty && newValue != currentValue) {
                await updateUserData(field, newValue);
                loadUserData(); // Reload data to update UI
              }
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.person, size: 72),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 25),
            child: Text(
              'My Profile',
              style: TextStyle(
                color: Colors.black87,
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          MyTextBox(
            text: firstname ?? 'First Name',
            sectionName: 'First Name',
            onPressed: () => editField('First Name', firstname ?? ''),
          ),
          MyTextBox(
            text: lastname ?? 'Last Name',
            sectionName: 'Last Name',
            onPressed: () => editField('Last Name', lastname ?? ''),
          ),
          MyTextBox(
            text: email ?? 'email',
            sectionName: 'Email',
            onPressed: () => editField('Email', email ?? ''),
          ),
          MyTextBox(
            text: contact ?? 'Contact Number',
            sectionName: 'Contact Number',
            onPressed: () => editField('Contact Number', contact ?? ''),
          ),
          MyTextBox(
            text: dateofbirth ?? 'Date of Birth',
            sectionName: 'Date of Birth',
            onPressed: () => editField('Date of Birth', dateofbirth ?? ''),
          ),
          MyTextBox(
            text: gender ?? 'Gender',
            sectionName: 'Gender',
            onPressed: () => editField('Gender', gender ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: deleteAccount,
              child: Text(
                "Delete Account",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
