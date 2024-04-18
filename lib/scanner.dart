import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:transparent_image/transparent_image.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  bool scanStarted = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Stack(
        children: [
          _buildCameraPreview(),
          _buildScanBoxOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
    );
  }

  Widget _buildScanBoxOverlay() {
    final double boxSize = MediaQuery.of(context).size.width * 0.6;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: boxSize,
          height: boxSize,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.memory(
                  kTransparentImage,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: boxSize * 0.8,
                  height: boxSize * 0.8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    bool scanned = false; // Flag to track if the QR code has been scanned

    controller.scannedDataStream.listen((scanData) {
      if (scanned)
        return; // If already scanned, return to avoid showing the dialog again

      setState(() {
        scanStarted = true;
      });

      // Decode the JSON text
      String jsonData = scanData.code!;
      dynamic decodedData = json.decode(jsonData);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          scanned = true; // Set the scanned flag to true
          return AlertDialog(
            title: const Text('QR Code Content'),
            content: Text(jsonData),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    scanStarted = false;
                    scanned =
                        false; // Reset the scanned flag when the dialog is dismissed
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultPage(
                        name: decodedData['name'],
                        rollNo: decodedData['RollNo'],
                        dept: decodedData['Department'],
                        phone: decodedData['phoneno'],
                      ),
                    ),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }
}

class ResultPage extends StatelessWidget {
  final String name;
  final String rollNo;
  final String dept;
  final String phone;

  const ResultPage({
    required this.name,
    required this.rollNo,
    required this.dept,
    required this.phone,
  });

  void _makePhoneCall(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    if (res == false) {
      print('Failed to make phone call');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
      ),
      body: Column(
        children: [
          reusableCard(
            text: name,
            type: 'Name:',
          ),
          reusableCard(
            text: rollNo,
            type: 'RollNo:',
          ),
          reusableCard(
            text: dept,
            type: 'Dept:',
          ),
          InkWell(
            onTap: () => _makePhoneCall(phone.toString()),
            child: reusableCard(
              text: phone,
              type: 'Phone:',
            ),
          ),
        ],
      ),
    );
  }
}

class reusableCard extends StatelessWidget {
  final dynamic text;
  final String type;

  const reusableCard({
    Key? key,
    required this.text,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ).copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                type,
                style: const TextStyle().copyWith(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              text.toString(),
              style: const TextStyle().copyWith(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
