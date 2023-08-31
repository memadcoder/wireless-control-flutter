import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRCodeScannerPage(),
    );
  }
}

class QRCodeScannerPage extends StatefulWidget {
  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
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
                    if (result != null) {
                      String barcodeData = result!.code ?? ""; // Use an empty string as a default value if code is null
                      List<String> parts = barcodeData.split(':');
                      if (parts.length == 3 && parts[0] == 'tcp') {
                        String ipAddress = parts[1].substring(2); // Remove '//' from the IP
                        int port = int.tryParse(parts[2]) ?? 0;
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

class MouseControlPage extends StatefulWidget {
  final String? ipAddress;
  final int? port;

  MouseControlPage({Key? key, this.ipAddress, this.port}) : super(key: key);

  @override
  _MouseControlPageState createState() => _MouseControlPageState();
}

class _MouseControlPageState extends State<MouseControlPage> {


  @override
  void initState() {
    super.initState();
    _initSocket(); // Initialize the socket connection when the widget is created
  }

  void _initSocket() async {
    try {
      socket = await Socket.connect(widget.ipAddress!, widget.port!);
      print('Socket connection established to ${widget.ipAddress}:${widget.port}');
    } catch (e) {
      print('Error connecting to the server: $e');
    }
  }

  void updateTouchPosition(Offset newPosition) {
    setState(() {
      touchPosition = newPosition;
    });
    _sendMouseData(newPosition.dx, newPosition.dy, '');
  }

  void _sendMouseData(double dx, double dy, String text) {
    print("madhav");
    print(socket);
    if (socket != null) {
      socket!.write(jsonEncode({'dx': dx, 'dy': dy, 'text': text}));
    }
  }

  @override
  void dispose() {
    socket?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wireless Mouse'),
      ),
      body: Center(
        child: GestureDetector(
          onPanUpdate: (details) {
            updateTouchPosition(details.localPosition);
          },
          child: CustomPaint(
            size: Size(200, 200), // Set the size as needed
            painter: TouchIndicatorPainter(touchPosition),
          ),
        ),
      ),
    );
  }
}

class TouchIndicatorPainter extends CustomPainter {
  final Offset touchPosition;

  TouchIndicatorPainter(this.touchPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(touchPosition, 10, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
