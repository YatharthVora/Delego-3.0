import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class WorldBank_PdfViewer extends StatelessWidget {
  const WorldBank_PdfViewer({super.key});

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
      body: SfPdfViewer.asset("assets/pdfs/World_Bank_Study_Guide.pdf"),
    );
  }
}