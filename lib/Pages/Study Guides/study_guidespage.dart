import 'package:flutter/material.dart';

class StudyGuidespage extends StatelessWidget {
   StudyGuidespage({super.key});

  final List<String> organizations = [
    'AIPPM',
    'ILC',
    'UNDP',
    'UNODC',
    'WHO',
    'WORLD BANK',
    'UNHRC',
    'H',
    'UNGA',
    'UNSC',
    'UNFCCC-COP'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: organizations.length, // Number of containers
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  organizations[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.book,
                  size: 45.0,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
