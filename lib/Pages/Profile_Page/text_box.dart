import 'package:flutter/material.dart';

class MyTextBox extends StatefulWidget {
  final String text;
  final String sectionName;
  final void Function ()?onPressed;
  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  State<MyTextBox> createState() => _MyTextBoxState();
}

class _MyTextBoxState extends State<MyTextBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.only(left: 15, bottom: 15),
      margin: EdgeInsets.only(left: 20,right: 20,top: 20) ,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.sectionName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins'
                ),
              ),

              //edit botton
              IconButton(
                  onPressed:widget.onPressed,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Colors.blue.shade900,
                  ),)
            ],
          ),

          //text
          Text(widget.text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins'
          ),
          ),
        ],
      ),
    );
  }
}
