import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Undp_PdfViewer extends StatelessWidget {
  const Undp_PdfViewer({super.key});

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
      body: SfPdfViewer.asset("assets/pdfs/UNDP_Study_Guide.pdf"),
    );
  }
}