import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'navbar.dart';

class QRScanPage extends StatefulWidget {
  final String parentID;
  final int childID;

  const QRScanPage({super.key, required this.parentID, required this.childID});

  @override
  State<QRScanPage> createState() => _QRScanPageState();

  void requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    await Permission.camera.request();
  }
}
}

class _QRScanPageState extends State<QRScanPage> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _hasScanned = false;
  String? qrText;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFFC0DA),
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
            appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Stack(
          children: [
            AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 254, 171, 205), Color.fromARGB(255, 254, 171, 205).withOpacity(0.6)],                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.only(left: 20, top: 50, right: 20, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Ibu Digi",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Serif', fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 60,),
          Expanded(
            flex: 4,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: MobileScanner(
                controller: _cameraController,
                onDetect: (BarcodeCapture capture) async {
                  if (_hasScanned) return;

                  final barcode = capture.barcodes.first;
                  if (barcode.rawValue == null) return;

                  setState(() {
                    qrText = barcode.rawValue;
                    _hasScanned = true;
                  });

                  _cameraController.stop();
                  await _handleQRData(qrText!);

                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Scan the QR code from the vaccine provider!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              softWrap: true,
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> _handleQRData(String rawData) async {
    try {
      final decoded = json.decode(rawData);
      if (decoded is! List) {
        _showDialog("Error", "Invalid QR format. Expected a list of vaccinations.");
        return;
      }

      List<String> failedMessages = [];

      for (final entry in decoded) {
        final response = await http.put(
          Uri.parse('http://10.0.2.2:8000/api/child/${widget.childID}/vaccinations/scan'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'vaccine_id': entry['vaccine_id'],
            'lot_id': entry['lot_id'],
            'prov_id': entry['prov_id'],
          }),
        );

        if (response.statusCode != 200) {
          failedMessages.add("Vaccine ID ${entry['vaccine_id']}: ${response.body}");
        }
      }

      if (failedMessages.isEmpty) {
        _showDialog("Success", "All vaccinations updated successfully!");
      } else {
        _showDialog("Partial Success", "Some updates failed:\n\n${failedMessages.join('\n')}");
      }

    } catch (e) {
      _showDialog("Error", "Invalid QR data or network error:\n$e");
    }
  }


  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => NavBar_screen(
                    initialPage: 0,
                    parentID: widget.parentID,
                    childID: widget.childID,
                  ),
                ),
                (route) => false, // Remove all previous routes
              );
            },

          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
