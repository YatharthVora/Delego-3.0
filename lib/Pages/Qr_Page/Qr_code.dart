import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrCode extends StatefulWidget {
  const QrCode({super.key});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  Uint8List? _qrCodeImage;

  @override
  void initState() {
    super.initState();
    _loadQrCodeImage();
  }


  Future<void> _loadQrCodeImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString('qr');

    if (base64Image != null) {
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
        title: const Text(
          'Your QR Code',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Transform.translate(
          offset: const Offset(0, -20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _qrCodeImage != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Show this QR outside the food counter",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Image.memory(
                        _qrCodeImage!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Bon appétit! Enjoy your meal 🍽️",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.qr_code_rounded,
                        size: 100,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "No QR Code available.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Error! No QR code available, contact the Organizing Committee",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}