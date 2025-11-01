import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class LoksabhaPdfviewer extends StatelessWidget {
  const LoksabhaPdfviewer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: scheme.primary,
          centerTitle: true,
          title: Text('PDF Viewer',
            style: TextStyle(
              color: scheme.onPrimary,
            ),
          ),
        ),
        body: SfPdfViewer.asset("assets/pdfs/LokSabha.pdf")
    );
  }
}