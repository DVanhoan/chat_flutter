import 'package:flutter/material.dart';
import '../model/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void login(String username, String token, String email, String picture) {
    _user = User(
      username: username,
      token: token,
      email: email,
      picture: picture,
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
