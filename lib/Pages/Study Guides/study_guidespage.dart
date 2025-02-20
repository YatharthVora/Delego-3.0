import 'package:delego/Pages/Study%20Guides/PDF_viewers/Nata_pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/Aippm_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/Copuos_pdfviewer.dart';
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
import 'package:delego/Pages/Study Guides/PDF_viewers/Icc_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/Nata_pdfviewer.dart';
import 'package:delego/Pages/Study Guides/PDF_viewers/UNGA_ECOFIN_pdfviewer.dart';
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
                _buildStudyGuideButton('ICC', Icc_PdfViewer()),
                _buildStudyGuideButton('NATA', Nata_PdfViewer()),
                _buildStudyGuideButton('UNGA-ECOFIN', Unga_Ecofin_PdfViewer()),
                // _buildStudyGuideButton('AIPPM', Aippm_PdfViwer()),
                // _buildStudyGuideButton('COPUOS', Copuos_PdfViewer()),
                // _buildStudyGuideButton('ILC', Ilc_PdfViewer()),
                // _buildStudyGuideButton('IPC', IPC_PdfViwer()),
                // _buildStudyGuideButton('UNDP', Undp_PdfViewer()),
                // _buildStudyGuideButton('UNODC', Unodc_PdfViewer()),
                // _buildStudyGuideButton('WHO', Who_PdfViewer()),
                // _buildStudyGuideButton('WORLD BANK', WorldBank_PdfViewer()),
                // _buildStudyGuideButton('UNHRC', Unhrc_PdfViewer()),
                // _buildStudyGuideButton('H.UNGA', Hunga_PdfViewer()),
                // _buildStudyGuideButton('UNSC', Unsc_PdfViewer()),
                // _buildStudyGuideButton('UNFCCC-COP', Unfccc_PdfViewer()),
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

