import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/auth_service.dart';

class AdminAccountRepository {
  AdminAccountRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'http://192.168.1.106:8080',
          );

  final http.Client _client;
  final String _baseUrl;

  Future<List<AccountUser>> listCashiers() async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/api/admin/users/cashiers'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));

    final payload = _decodePayload(response.body);
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(payload));
    }

    final cashiers = payload['cashiers'];
    if (cashiers is! List) {
      throw const AuthException('Data kasir dari server tidak valid');
    }

    return cashiers
        .whereType<Map<String, dynamic>>()
        .map(AccountUser.fromJson)
        .toList();
  }

  Future<AccountUser> createCashier({
    required String fullName,
    required String username,
    required String password,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/admin/users/cashiers'),
          headers: await _authorizedHeaders(),
          body: jsonEncode({
            'full_name': fullName,
            'username': username,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final payload = _decodePayload(response.body);
    if (response.statusCode != 201) {
      throw AuthException(_errorMessage(payload));
    }

    final user = payload['user'];
    if (user is! Map<String, dynamic>) {
      throw const AuthException('Data kasir dari server tidak valid');
    }
    return AccountUser.fromJson(user);
  }

  Future<void> deleteCashier(int cashierId) async {
    final response = await _client
        .delete(
          Uri.parse('$_baseUrl/api/admin/users/cashiers/$cashierId'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));

    final payload = _decodePayload(response.body);
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(payload));
    }
  }

  Future<void> resetCashierPassword({
    required int cashierId,
    required String password,
  }) async {
    final response = await _client
        .patch(
          Uri.parse('$_baseUrl/api/admin/users/cashiers/$cashierId/password'),
          headers: await _authorizedHeaders(),
          body: jsonEncode({'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    final payload = _decodePayload(response.body);
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(payload));
    }
  }

  Future<AccountUser> updateCurrentUser({
    required String fullName,
    required String username,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _client
        .patch(
          Uri.parse('$_baseUrl/api/auth/me'),
          headers: await _authorizedHeaders(),
          body: jsonEncode({
            'full_name': fullName,
            'username': username,
            'current_password': currentPassword,
            'new_password': newPassword,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final payload = _decodePayload(response.body);
    if (response.statusCode != 200) {
      throw AuthException(_errorMessage(payload));
    }

    final user = payload['user'];
    if (user is! Map<String, dynamic>) {
      throw const AuthException('Data admin dari server tidak valid');
    }

    final account = AccountUser.fromJson(user);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('auth_username', account.username);
    await preferences.setString('auth_full_name', account.fullName);
    await preferences.setBool(
      'auth_must_change_password',
      account.mustChangePassword,
    );
    return account;
  }

  Future<Map<String, String>> _authorizedHeaders() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    final tokenType = preferences.getString('auth_token_type') ?? 'Bearer';
    if (token == null || token.trim().isEmpty) {
      throw const AuthException(
        'Sesi login tidak ditemukan. Silakan login ulang.',
      );
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': '$tokenType $token',
    };
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
    return 'Gagal memproses akun.';
  }
}

class AccountUser {
  const AccountUser({
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

  factory AccountUser.fromJson(Map<String, dynamic> json) {
    return AccountUser(
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
