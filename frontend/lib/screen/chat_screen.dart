import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String token;
  final Map<String, dynamic> user;

  ChatScreen({required this.chatId, required this.token, required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel channel;
  final TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    print('ChatScreen initialized with chatId: ${widget.chatId}');
    fetchMessages();
    setupWebSocket();
  }

  void setupWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.12:5000?token=${widget.token}'),
    );

    channel.stream.listen((data) {
      final decodedMessage = json.decode(data);
      setState(() {
        messages.add(decodedMessage);
      });
    }, onError: (error) {
      print("WebSocket error: $error");
    });
  }

  // Lấy tin nhắn từ API
  Future<void> fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.1.12:5000/api/chat/recent_messages?conversationId=${widget.chatId}',
        ),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final List<dynamic> fetchedMessages = json.decode(response.body);
        print("recent message: $fetchedMessages");
        setState(() {
          messages = fetchedMessages.map((msg) {
            return {
              'content': msg['content'],
              'sender': msg['sender']['username'],
              'senderId': msg['sender']['_id']
            };
          }).toList();
          print("message fetch : $messages");
        });
      } else {
        print('Failed to fetch messages: ${response.body}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.isNotEmpty) {
      final messageContent = messageController.text;
      messageController.clear();

      final message = {
        'conversationId': widget.chatId,
        'sender': widget.user['_id'],
        'content': messageContent,
      };

      try {
        channel.sink.add(json.encode(message));
      } catch (e) {
        print('WebSocket send error: $e');
      }

      setState(() {
        messages.add({
          'content': messageContent,
          'sender': widget.user['username'],
          'senderId': widget.user['_id']
        });
      });
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isOwnMessage = message['senderId'] == widget.user['_id'];
                print('isOwnMessage $isOwnMessage');

                return Align(
                  alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOwnMessage ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: isOwnMessage ? Radius.circular(12) : Radius.zero,
                        bottomRight: isOwnMessage ? Radius.zero : Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isOwnMessage
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (!isOwnMessage)
                          Text(
                            message['sender'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        Text(
                          message['content'],
                          style: TextStyle(
                            color: isOwnMessage ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: 'Type your message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage, // Sử dụng hàm gửi chung
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
