import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatWsService {
  static final ChatWsService instance = ChatWsService._();

  ChatWsService._();

  StompClient? _client;
  String? _sessionId;
  bool _isConnected = false;
  final Map<String, void Function()> _subscriptions = {};

  final _messageController = StreamController<StompFrame>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const int _baseReconnectDelayMs = 1000;

  static const String _baseUrl = 'http://10.0.2.2:8080/ws';

  Stream<StompFrame> get messagesStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<String> get errorStream => _errorController.stream;

  bool get isConnected => _isConnected;
  String? get sessionId => _sessionId;

  Future<bool> connect(String sessionId) async {
    if (_client != null && _isConnected && _sessionId == sessionId) {
      return true;
    }

    await disconnect();

    _sessionId = sessionId;

    _client = StompClient(
      config: StompConfig.sockJS(
        url: _baseUrl,
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        onUnhandledMessage: _onUnhandledMessage,
        stompConnectHeaders: {'session-id': sessionId},
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _client!.activate();

    final completer = Completer<bool>();

    void onConnectCheck() {
      if (_isConnected) {
        completer.complete(true);
      } else {
        Future.delayed(const Duration(milliseconds: 500), onConnectCheck);
      }
    }

    onConnectCheck();

    await Future.delayed(const Duration(seconds: 5));
    return _isConnected;
  }

  void _onConnect(StompFrame connectFrame) {
    _isConnected = true;
    _reconnectAttempts = 0;
    _connectionController.add(true);
  }

  void _onDisconnect(StompFrame disconnectFrame) {
    _isConnected = false;
    _connectionController.add(false);
  }

  void _onStompError(StompFrame stompErrorFrame) {
    _errorController.add(stompErrorFrame.headers['message'] ?? 'STOMP error');
  }

  void _onWebSocketError(dynamic error) {
    _errorController.add(error.toString());
    _isConnected = false;
    _connectionController.add(false);
    _scheduleReconnect();
  }

  void _onUnhandledMessage(StompFrame frame) {
    _messageController.add(frame);
  }

  void _scheduleReconnect() {
    if (_sessionId == null) return;

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _errorController.add('Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delayMs = _baseReconnectDelayMs * (1 << (_reconnectAttempts - 1));

    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      if (_sessionId != null && !_isConnected) {
        connect(_sessionId!);
      }
    });
  }

  Future<void> subscribeToChat(String chatId) async {
    if (_client == null || !_isConnected) {
      _errorController.add('Not connected to WebSocket');
      return;
    }

    // Subscribe to /app/chats/{chatId} - returns chat history
    final unsubscribeHistory = _client!.subscribe(
      destination: '/app/chats/$chatId',
      headers: {'session-id': _sessionId ?? ''},
      callback: (frame) {
        _messageController.add(frame);
      },
    );

    // Subscribe to /topic/chats/{chatId} - receives real-time messages
    final unsubscribeRealTime = _client!.subscribe(
      destination: '/topic/chats/$chatId',
      headers: {'session-id': _sessionId ?? ''},
      callback: (frame) {
        _messageController.add(frame);
      },
    );

    _subscriptions[chatId] = () {
      unsubscribeHistory();
      unsubscribeRealTime();
    };
  }

  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String username,
    required String content,
  }) async {
    if (_client == null || !_isConnected) {
      _errorController.add('Not connected to WebSocket');
      return false;
    }

    try {
      _client!.send(
        destination: '/app/chats/$chatId',
        headers: {'session-id': _sessionId ?? ''},
        body: jsonEncode({
          'senderId': senderId,
          'username': username,
          'content': content,
        }),
      );
      return true;
    } catch (e) {
      _errorController.add('Failed to send message: $e');
      return false;
    }
  }

  Future<void> unsubscribe(String chatId) async {
    final unsubscribeFn = _subscriptions.remove(chatId);
    if (unsubscribeFn != null) {
      unsubscribeFn();
    }
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    for (final unsubscribeFn in _subscriptions.values) {
      unsubscribeFn();
    }
    _subscriptions.clear();

    if (_client != null) {
      _client!.deactivate();
      _client = null;
    }

    _isConnected = false;
    _sessionId = null;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
    _errorController.close();
  }
}
