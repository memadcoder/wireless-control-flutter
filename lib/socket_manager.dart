// socket_manager.dart
import 'dart:io';
import 'dart:math';

class SocketManager {
  static SocketManager? _instance;
  Socket? _socket;
  bool _initialized = false;

  static SocketManager getInstance() {
    if (_instance == null) {
      _instance = SocketManager();
    }
    return _instance!;
  }

  Future<void> initializeSocket(String ipAddress, int port) async {
    if (!_initialized) {
      try {
        _socket = await Socket.connect(ipAddress, port);
        // Generate a random integer between 0 and 99 (inclusive)
        Random random = Random();
        int randomNumber = random.nextInt(100);

        // Print the random number
        print("Random Number: $randomNumber");
        print('Socket connection established to $ipAddress:$port');
        _initialized = true;
      } catch (e) {
        print('Error connecting to the server: $e');
      }
    }
  }

  Socket? get socket => _socket;
  bool get isInitialized => _initialized;

  void closeSocket() {
    _socket?.destroy();
    _initialized = false;
  }
}
