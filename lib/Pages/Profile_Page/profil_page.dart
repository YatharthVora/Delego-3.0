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
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
        title: const Text(
          'Profile Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50),
          Icon(Icons.person, size: 72),
          const SizedBox(height: 30),
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
          // First Name and Last Name Fields
          Row(
            children: [
              Expanded(
                child: MyTextBox(
                  text: firstname ?? 'First Name',
                  sectionName: 'First Name',
                  onPressed: () => editField('First Name', firstname ?? ''),
                ),
              ),
              Expanded(
                child: MyTextBox(
                  text: lastname ?? 'Last Name',
                  sectionName: 'Last Name',
                  onPressed: () => editField('Last Name', lastname ?? ''),
                ),
              ),
            ],
          ),
          // Email Field
          GestureDetector(
            onTap: () => {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Email cannot be edited."),
                    backgroundColor: Colors.red),
              )
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //text
                  Text(
                    email ?? 'Email',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
          ),
          MyTextBox(
            text: contact ?? 'Contact',
            sectionName: 'Contact Number',
            onPressed: () => editField('Contact Number', contact ?? ''),
          ),
          MyTextBox(
            text: dateofbirth ?? 'Date of Birth',
            sectionName: 'Date of Birth',
            onPressed: () => editField('Date of Birth', dateofbirth ?? ''),
          ),
          // Gender Dropdown
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(15),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins')),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: gender,
                            hint: Text('Select Gender',
                                style: TextStyle(fontFamily: 'Poppins')),
                            items: <String>[
                              'Male',
                              'Female',
                              'Other',
                              'Prefer not to say'
                            ]
                                .map((String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                    ))
                                .toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                updateUserData('gender', newValue);
                                setState(() {
                                  gender = newValue;
                                });
                              }
                            },
                          ),
                        ])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
