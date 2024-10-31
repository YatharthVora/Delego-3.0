
import 'package:flutter/material.dart';
import 'package:delego/Pages/Profile Page/text_box.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // edit fild
  Future<void> editField(String field)async {
  String newValue= "";
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
            hintText: "Enter New $field",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue=value;
          },
        ),
        actions: [
          //cancel botton
          TextButton(
              onPressed: ()=> Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),),

          //save botton
          TextButton(
            onPressed: ()=> Navigator.of(context).pop(newValue),
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),)
        ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
        title: const Text('Profile Page',
        style: TextStyle(
          color: Colors.white,
        ),),
      ),
      body: ListView(
        children: [
           SizedBox(height: 50.0,),
          // Profile Pictures
          Icon(
            Icons.person,
            size: 72,
          ),
          const SizedBox(height: 30),
          // user details
          Padding(
            padding: EdgeInsets.only(left: 25),
           child: Text(
             'My Details',
             style: TextStyle(color: Colors.black87,
             fontFamily: 'Poppins',
               fontSize: 16,
               fontWeight: FontWeight.bold,
             ),
           ),
          ),
          // Email
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.only(left: 15, bottom: 15),
        margin: EdgeInsets.only(left: 20,right: 20,top: 20) ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 7, 0, 3),
                  child: Text('Email',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins'
                    ),
                  ),
                ),

            //text
            Text('Email',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'
              ),
            ),
          ],
        ),
      ),
          //Name
          MyTextBox(
            text: 'Mithil Save',
            sectionName: 'Name',
            onPressed: ()=> editField('Name'),
          ),
          //Contact
          MyTextBox(
            text: '755******5',
            sectionName: 'Contact No',
            onPressed: ()=> editField('contact'),
          ),
          MyTextBox(text: '29-01-2005',
              sectionName: 'DoB',
              onPressed:()=> editField("DoB")
          ),
          MyTextBox(text: 'Male',
              sectionName: 'Gender',
              onPressed:()=> editField("Gender")
          ),

        ],
      ),
    );
  }
}
