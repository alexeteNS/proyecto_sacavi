import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../storage/secure_storage.dart';
import '../config/app_config.dart';

class DashboardWsService {
  final SecureStorageService storage;
  WebSocketChannel? _channel;
  Function(Map<String, dynamic>)? onMessage;

  DashboardWsService({required this.storage});

  Future<void> connect() async {
    final token = await storage.getToken();
    if (token == null || token.isEmpty) return;

    final wsUrl = '${AppConfig.baseUrl.replaceFirst("http", "ws")}/ws/dashboard';
    
    final uri = Uri.parse('$wsUrl?token=$token');

    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (message) {
        if (onMessage != null) {
          try {
            final data = jsonDecode(message);
            onMessage!(data);
          } catch (e) {
            // Error parsing message
          }
        }
      },
      onDone: () {
        // Handle disconnect, optionally reconnect
      },
      onError: (error) {
        // Handle error
      },
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
