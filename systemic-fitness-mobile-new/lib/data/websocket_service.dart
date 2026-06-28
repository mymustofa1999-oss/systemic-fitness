import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:workout/data/api_config.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  String? _token;
  bool _isConnected = false;

  Function(Map<String, dynamic>)? onMessage;
  Function(int)? onUnreadCount;
  Function(String)? onUserOnline;
  Function(String)? onUserOffline;
  Function()? onConnected;
  Function()? onDisconnected;

  bool get isConnected => _isConnected;

  Future<void> connect(String token) async {
    _token = token;
    _disconnect();

    try {
      final uri = Uri.parse('${ApiConfig.wsUrl}?token=$token');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          _isConnected = true;
          onConnected?.call();

          final json = jsonDecode(data) as Map<String, dynamic>;
          final type = json['type'];

          switch (type) {
            case 'unread_count':
              onUnreadCount?.call(json['data']['count'] ?? 0);
              break;
            case 'new_message':
              onMessage?.call(json['data']);
              break;
            case 'user_online':
              onUserOnline?.call(json['data']['user_id']);
              break;
            case 'user_offline':
              onUserOffline?.call(json['data']['user_id']);
              break;
          }
        },
        onError: (error) {
          _isConnected = false;
          onDisconnected?.call();
          _scheduleReconnect();
        },
        onDone: () {
          _isConnected = false;
          onDisconnected?.call();
          _scheduleReconnect();
        },
      );
    } catch (e) {
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_token != null) {
        connect(_token!);
      }
    });
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }

  void disconnect() {
    _token = null;
    _disconnect();
  }
}
