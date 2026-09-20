import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QrScanner(),
    ),
  );
}

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final MobileScannerController controller =
      MobileScannerController();

  bool dialogShowing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void showQRResult(String value) {
    if (dialogShowing) return;

    dialogShowing = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("QR Code Found"),
          content: SelectableText(value),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    ).then((_) {
      dialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        centerTitle: true,
      ),

      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          for (final barcode in capture.barcodes) {
            final value = barcode.rawValue;

            if (value != null && value.isNotEmpty) {
              debugPrint("Barcode Found: $value");
              showQRResult(value);
              break;
            }
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.toggleTorch();
        },
        child: const Icon(Icons.flash_on),
      ),
    );
  }
}