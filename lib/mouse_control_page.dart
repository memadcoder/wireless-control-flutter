import 'package:flutter/material.dart';
import 'dart:convert';
import 'socket_manager.dart';
import 'touch_indicator_painter.dart';

class MouseControlPage extends StatefulWidget {
  final String? ipAddress;
  final int? port;

  MouseControlPage({Key? key, this.ipAddress, this.port}) : super(key: key);

  @override
  _MouseControlPageState createState() => _MouseControlPageState();
}

class _MouseControlPageState extends State<MouseControlPage> {
  SocketManager? _socketManager;
  Offset touchPosition = Offset(100, 100);

  @override
  void initState() {
    super.initState();
    touchPosition = Offset(100, 100);
    _initSocket();
  }

  void _initSocket() async {
    _socketManager ??= SocketManager();
    if (!_socketManager!.isInitialized) {
      await _socketManager!.initializeSocket(widget.ipAddress!, widget.port!);
    }
  }

  void updateTouchPosition(Offset newPosition) {
    if (_socketManager == null) {
      _initSocket();
    }
    if (_socketManager!.isInitialized) {
      setState(() {
        touchPosition = newPosition;
      });
      _sendMouseData(newPosition.dx, newPosition.dy, null, null);
    }
  }

  void _sendMouseData(double dx, double dy, String? text, String? click) {
    if (_socketManager!.socket != null) {
      _socketManager!.socket!.write(jsonEncode({'dx': dx, 'dy': dy, 'text': text, 'click': click}));
    }
  }

  void resetTouchPosition() {
    setState(() {
      touchPosition = Offset(100, 100);
    });
  }

  void simulateLeftClick() {
    if (_socketManager != null && _socketManager!.isInitialized) {
      _sendMouseData(0, 0, null, 'left');
    }
  }

  Future<void> _showTextFieldDialog() async {
    String text = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Text'),
          content: TextField(
            onChanged: (value) {
              text = value;
            },
            decoration: InputDecoration(
              hintText: 'Type something...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Send'),
              onPressed: () {
                _sendMouseData(0, 0, text, null);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void sendBackspace() {
    // Simulate backspace by sending a specific message to the socket.
    if (_socketManager != null && _socketManager!.isInitialized) {
      _sendMouseData(0, 0, 'backspace', null);
    }
  }

  @override
  void dispose() {
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
          onPanEnd: (details) {
            resetTouchPosition();
          },
          onDoubleTap: () {
            simulateLeftClick();
          },
          child: CustomPaint(
            size: Size(200, 200),
            painter: TouchIndicatorPainter(touchPosition),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _showTextFieldDialog();
            },
            child: Icon(Icons.text_fields),
            heroTag: null,
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              sendBackspace();
            },
            child: Icon(Icons.backspace),
            heroTag: null,
          ),
        ],
      ),
    );
  }

}
