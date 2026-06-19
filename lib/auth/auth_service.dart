import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRepository {
  Future<LoginSession> login({
    required String username,
    required String password,
    required String role,
  });
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://192.168.1.106:8080',
          );

  final http.Client _client;
  final String _baseUrl;

  @override
  Future<LoginSession> login({
    required String username,
    required String password,
    required String role,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/auth/login');

    final response = await _client
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
            'role': role,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final payload = _decodePayload(response.body);
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(payload));
    }

    final session = LoginSession.fromJson(payload);
    await _saveSession(session);
    return session;
  }

  Map<String, dynamic> _decodePayload(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      throw const AuthException('Respons server tidak valid');
    }

    throw const AuthException('Respons server tidak valid');
  }

  String _errorMessage(Map<String, dynamic> payload) {
    final error = payload['error'];
    if (error is String && error.trim().isNotEmpty) return error;
    return 'Login gagal. Periksa username, password, dan role.';
  }

  Future<void> _saveSession(LoginSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('auth_token', session.token);
    await preferences.setString('auth_token_type', session.tokenType);
    await preferences.setInt('auth_expires_in', session.expiresIn);
    await preferences.setBool(
      'auth_must_change_password',
      session.mustChangePassword,
    );
    await preferences.setString('auth_user_role', session.user.role);
    await preferences.setString('auth_username', session.user.username);
    await preferences.setString('auth_full_name', session.user.fullName);
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LoginSession {
  const LoginSession({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.mustChangePassword,
    required this.user,
  });

  final String token;
  final String tokenType;
  final int expiresIn;
  final bool mustChangePassword;
  final AuthUser user;

  factory LoginSession.fromJson(Map<String, dynamic> json) {
    final userPayload = json['user'];
    if (userPayload is! Map<String, dynamic>) {
      throw const AuthException('Data user dari server tidak valid');
    }

    final token = json['token'];
    final tokenType = json['token_type'];
    final expiresIn = json['expires_in'];
    final mustChangePassword = json['must_change_password'];

    if (token is! String || token.trim().isEmpty) {
      throw const AuthException('Token login tidak ditemukan');
    }

    return LoginSession(
      token: token,
      tokenType: tokenType is String ? tokenType : 'Bearer',
      expiresIn: expiresIn is int ? expiresIn : 0,
      mustChangePassword: mustChangePassword is bool
          ? mustChangePassword
          : false,
      user: AuthUser.fromJson(userPayload),
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.mustChangePassword,
  });

  final int id;
  final String username;
  final String fullName;
  final String role;
  final bool isActive;
  final bool mustChangePassword;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] is int ? json['id'] as int : 0,
      username: json['username'] is String ? json['username'] as String : '',
      fullName: json['full_name'] is String ? json['full_name'] as String : '',
      role: json['role'] is String ? json['role'] as String : '',
      isActive: json['is_active'] is bool ? json['is_active'] as bool : false,
      mustChangePassword: json['must_change_password'] is bool
          ? json['must_change_password'] as bool
          : false,
    );
  }
}
