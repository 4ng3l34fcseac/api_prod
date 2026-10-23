// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String? token;

  bool get isAuthenticated => token != null;

  void login(String newToken) {
    token = newToken;
    notifyListeners();
  }

  void logout() {
    token = null;
    notifyListeners();
  }
}