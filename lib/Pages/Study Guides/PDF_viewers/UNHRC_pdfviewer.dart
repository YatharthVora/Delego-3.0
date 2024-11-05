import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Unhrc_PdfViewer extends StatelessWidget {
  const Unhrc_PdfViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
        title: Text('PDF Viewer',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SfPdfViewer.asset("assets/pdfs/UNHRC_Study_Guide.pdf"),
    );
  }
}