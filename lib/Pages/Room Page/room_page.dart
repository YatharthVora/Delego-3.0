import 'package:flutter/material.dart';

class RoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Rooms'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade900),
                shape: BoxShape.rectangle,
                boxShadow: const[
                    BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 4.0), //(x,y)
                    blurRadius: 8.0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade900,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                      'Room 1',
                  style:TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  )),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade900),
                shape: BoxShape.rectangle,
                boxShadow: const[
                    BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 4.0), //(x,y)
                    blurRadius: 8.0,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade900,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                      'Room 2',
                      style:TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      )),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade900),
                shape: BoxShape.rectangle,
                boxShadow:const [
                    BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 4.0), //(x,y)
                    blurRadius: 8.0,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade900,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                      'Room 3',
                      style:TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      )),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade900),
                shape: BoxShape.rectangle,
                boxShadow: const[
                    BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 4.0), //(x,y)
                    blurRadius: 8.0,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade900,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                      'Room 4',
                      style:TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      )),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade900),
                shape: BoxShape.rectangle,
                boxShadow: const [
                     BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 4.0), //(x,y)
                    blurRadius: 8.0,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade900,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                      'Room 5',
                      style:TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      )),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade900),
                shape: BoxShape.rectangle,
                boxShadow: const [
                    BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 4.0), //(x,y)
                    blurRadius: 8.0,
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade900,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                      'Room 6',
                      style:TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}