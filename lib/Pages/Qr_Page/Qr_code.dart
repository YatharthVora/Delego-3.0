import 'dart:convert'; // For base64 encoding/decoding
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrCode extends StatefulWidget {
  const QrCode({super.key});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  Uint8List? _qrCodeImage; // To hold the decoded image data

  @override
  void initState() {
    super.initState();
    _loadQrCodeImage();
  }

  // Method to load image from SharedPreferences
  Future<void> _loadQrCodeImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString('qr');

    if (base64Image != null) {
      // Decode the Base64 image to Uint8List
      setState(() {
        _qrCodeImage = base64Decode(base64Image);
      });
    } else {
      print("No QR code image found in SharedPreferences.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Center(
        child: _qrCodeImage != null
            ? Image.memory(_qrCodeImage!) // Display the decoded image
            : Text(
                "No QR Code available."), // Display a placeholder if no image
      ),
    );
  }
}
