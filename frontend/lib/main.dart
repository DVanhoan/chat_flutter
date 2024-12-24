import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat_app/layouts/AppLayout.dart';
import 'package:chat_app/screen/home_screen.dart';
import 'package:chat_app/screen/login_screen.dart';
import 'package:chat_app/screen/profile_screen.dart';
import 'package:chat_app/screen/setting_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Profile> fetchProfile(String token, Profile? user) async {
    if (user != null) return user;

    final url = Uri.parse('http://192.168.1.12:5000/api/auth/me');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Profile.fromJson(data);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(
            onLoginSuccess: (token, user  ) {
              fetchProfile(token, user as Profile?);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(token: token, user: user),
                ),
              );
            }
        ),
        '/setting': (context) => const AppLayout(
          child: SettingScreen(),
        ),
      },
    );
  }
}