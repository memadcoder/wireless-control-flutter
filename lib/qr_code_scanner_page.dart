// qr_code_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'mouse_control_page.dart';

class QRCodeScannerPage extends StatefulWidget {
  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  bool hasNavigatedToMouseControlPage = false; // Add this flag

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... (rest of your code)

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 400, // Limit the height of the QRView
              child: QRView(
                key: qrKey,
                onQRViewCreated: (QRViewController controller) {
                  controller.scannedDataStream.listen((barcode) {
                    setState(() {
                      result = barcode;
                    });
                    if (result != null && !hasNavigatedToMouseControlPage) {
                      String barcodeData = result!.code ?? "";
                      List<String> parts = barcodeData.split(':');
                      if (parts.length == 3 && parts[0] == 'tcp') {
                        String ipAddress = parts[1].substring(2);
                        int port = int.tryParse(parts[2]) ?? 0;
                        // Check if not navigated already
                        if (!hasNavigatedToMouseControlPage) {
                          hasNavigatedToMouseControlPage = true; // Set the flag
                          print("madhav called");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MouseControlPage(
                                ipAddress: ipAddress,
                                port: port,
                              ),
                            ),
                          );
                        }
                      }
                    }
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text('Result: ${result?.code ?? "No QR code detected"}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
