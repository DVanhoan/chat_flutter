import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';
import 'package:chat_app/layouts/AppLayout.dart';


class HomeScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;

  HomeScreen({required this.token, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> chatList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  Future<void> fetchChats() async {
    try {
      final response = await http.get(
        Uri.parse('https://server-chat-zp9u.onrender.com/api/chat/all'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          chatList = json.decode(response.body);
          isLoading = false;
          print("chat list: $chatList");
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch chats';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching chats: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
        child: Scaffold(
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
            itemCount: chatList.length,
            itemBuilder: (context, index) {
              final chat = chatList[index];
              String name = '';

              final participants = chat['participants'];
              if (participants != null && participants is List) {
                for (var participant in participants) {
                  if (participant['username'] != widget.user['username']) {
                    name = participant['username'];
                    break;
                  }
                }
              }

              name = name.isNotEmpty ? name : 'Chat';

              return ListTile(
                title: Text(name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          chatId: chat['_id'],
                          token: widget.token,
                          user: widget.user
                      ),
                    ),
                  );
                },
              );
            },
          )
      )
    );
  }
}