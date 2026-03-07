import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/data/services/chat_ws_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userId;
  final String contactId;
  final String username;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.userId,
    required this.contactId,
    required this.username,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToChat();
  }

  void _subscribeToChat() {
    ChatWsService.instance.subscribeToChat(widget.chatId);

    _subscription = ChatWsService.instance.messagesStream.listen((frame) {
      if (frame.body != null && frame.body!.isNotEmpty) {
        try {
          final data = jsonDecode(frame.body!);
          setState(() {
            if (data is List) {
              _messages = data;
            } else if (data is Map) {
              _messages.add(data);
            }
          });
          _scrollToBottom();
        } catch (e) {
          debugPrint('Error parsing message: $e');
        }
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final success = await ChatWsService.instance.sendMessage(
      chatId: widget.chatId,
      senderId: widget.userId,
      username: widget.username,
      content: content,
    );

if (success) {
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    ChatWsService.instance.unsubscribe(widget.chatId);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isOwnMessage = message['senderId'] == widget.userId;
                      return _MessageBubble(
                        message: message,
                        isOwnMessage: isOwnMessage,
                      );
                    },
                  ),
          ),
          _MessageInput(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isOwnMessage;

  const _MessageBubble({required this.message, required this.isOwnMessage});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isOwnMessage ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isOwnMessage ? const Radius.circular(16) : Radius.zero,
            bottomRight: isOwnMessage ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOwnMessage)
              Text(
                message['username'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.deepPurple[700],
                ),
              ),
            if (!isOwnMessage) const SizedBox(height: 4),
            Text(
              message['content'] ?? '',
              style: TextStyle(
                color: isOwnMessage ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message['timestamp']),
              style: TextStyle(
                fontSize: 10,
                color: isOwnMessage ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp.toString());
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp.toString();
    }
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send),
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}
