import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import 'package:http/http.dart' as http;


class AuthenticationResult {
  final bool success;
  final String errorMessage;

  AuthenticationResult({
    required this.success,
    this.errorMessage = '',
  });
}

class AuthenticationProvider with ChangeNotifier {
  String _accessToken = '';
  final String _accessTokenKey = 'accessToken';

  Future<String> get accessToken async {
    if (_accessToken.isEmpty) {
      await _loadAccessToken();
    }
    return _accessToken;
  }

  // get http => null;

  Future<void> _saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  Future<void> _loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    if (token != null) {
      _accessToken = token;
    }
  }

  Future<bool> checkSession() async {
    if (_accessToken.isNotEmpty) {
      return true;
    } else {
      await _loadAccessToken();
      return _accessToken.isNotEmpty;
    }
  }

  Future<AuthenticationResult> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$API_URL/auth/authenticate'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    log("login: ${response.statusCode}");

    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)['accessToken'];
      _accessToken = token;

      await _saveAccessToken(token);

      return AuthenticationResult(success: true);
    } else {
      const errorMessage =
          'Authentication failed: Email or password is incorrect';
      return AuthenticationResult(success: false, errorMessage: errorMessage);
    }
  }

  Future<AuthenticationResult> register(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$API_URL/auth/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    log('signup: ${response.statusCode}');

    if (response.statusCode == 201) {
      return AuthenticationResult(success: true);
    } else {
      final errorJson = jsonDecode(response.body);
      final errorMessage = errorJson['message'] ?? 'Registration failed';
      return AuthenticationResult(success: false, errorMessage: errorMessage);
    }
  }
}
