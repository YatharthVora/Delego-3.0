import 'package:flutter/material.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/G20_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/IPC_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/LokSabha_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNCSW_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNEA_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNODC_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNSC_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/Icc_pdfviewer.dart';
class StudyGuidespage extends StatefulWidget {
  @override
  State<StudyGuidespage> createState() => _StudyGuidesPageState();
}

class _StudyGuidesPageState extends State<StudyGuidespage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Study Guides',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Study Guides",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  "Click to view the PDF",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20.0),
                _buildStudyGuideButton('G20', G20Pdfviewer()),
                _buildStudyGuideButton('Historical Lok Sabha', LoksabhaPdfviewer()),
                _buildStudyGuideButton('IPC', IpcPdfviewer()),
                _buildStudyGuideButton('UNCSW', UncswPdfviewer()),
                _buildStudyGuideButton('UNEA', UneaPdfviewer()),
                _buildStudyGuideButton('UNODC', UnodcPdfviewer()),
                _buildStudyGuideButton('UNSC', UnscPdfviewer()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create the Study Guide button
  Widget _buildStudyGuideButton(String title, Widget? page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page!));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade900,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.picture_as_pdf,
              size: 40.0,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

