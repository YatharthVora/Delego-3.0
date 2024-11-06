import 'package:flutter/material.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/Aippm_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/Copuos_pdfviewer.dart'; // Added COPUOS import
import 'package:delego/Pages/Study Guides/PDF_viewers/HUNGA_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/ILC_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/IPC_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNDP_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/WHO_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNSC_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNODC_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNHRC_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNFCCC-COP_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/WORLD_BANK_pdfviewer.dart';

class StudyGuidespage extends StatefulWidget {
  @override
  State<StudyGuidespage> createState() => _StudyGuidespageState();
}

class _StudyGuidespageState extends State<StudyGuidespage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Aippm_PdfViwer())); // AIPPM
              },
              child: _buildStudyGuideButton('AIPPM', Aippm_PdfViwer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Copuos_PdfViewer()));
                // COPUOS
              },
              child: _buildStudyGuideButton('COPUOS', Copuos_PdfViewer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Ilc_PdfViewer()));
                // ILC
              },
              child: _buildStudyGuideButton('ILC', Ilc_PdfViewer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IPC_PdfViwer()));
                // IPC
              },
              child: _buildStudyGuideButton('IPC', IPC_PdfViwer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Undp_PdfViewer()));
                // UNDP
              },
              child: _buildStudyGuideButton('UNDP', Undp_PdfViewer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Unodc_PdfViewer()));
                // UNODC
              },
              child: _buildStudyGuideButton('UNODC', Unodc_PdfViewer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Who_PdfViewer()));
                // WHO
              },
              child: _buildStudyGuideButton('WHO', Who_PdfViewer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WorldBank_PdfViewer()));
                // WORLD BANK
              },
              child:
                  _buildStudyGuideButton('WORLD BANK', WorldBank_PdfViewer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Unhrc_PdfViewer()));
                // UNHRC
              },
              child: _buildStudyGuideButton('UNHRC', Unhrc_PdfViewer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Hunga_PdfViewer()));
                // H.UNGA
              },
              child: _buildStudyGuideButton('H.UNGA', Hunga_PdfViewer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Unsc_PdfViewer()));
                // UNSC
              },
              child: _buildStudyGuideButton('UNSC', Unsc_PdfViewer()),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Unfccc_PdfViewer()));
                // UNFCCC-COP
              },
              child: _buildStudyGuideButton('UNFCCC-COP', Unfccc_PdfViewer()),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create the Study Guide button
  Widget _buildStudyGuideButton(String title, Widget? page) {
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
            title,
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
  }
}
