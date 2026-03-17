import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/layouts/AppLayout.dart';
import 'package:frontend/screen/home_screen.dart';
import 'package:frontend/screen/login_screen.dart';
import 'package:frontend/screen/profile_screen.dart';
import 'package:frontend/screen/setting_screen.dart';
import 'package:frontend/provider/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => UserProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Profile> fetchProfile(String token, Profile? user) async {
    if (user != null) return user;

    final url = Uri.parse('https://server-chat-zp9u.onrender.com/api/auth/me');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
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
          onLoginSuccess: (token, user) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(token: token, user: user),
              ),
            );
          },
        ),
        '/setting': (context) => const AppLayout(child: SettingScreen()),
      },
    );
  }
}
