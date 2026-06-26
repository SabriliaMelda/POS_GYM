import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/auth_service.dart';
import '../../../kasir/models/attendance.dart';
import '../../../kasir/models/food_beverage_item.dart';
import '../../../kasir/models/food_beverage_transaction.dart';
import '../../../kasir/models/gym_package.dart';
import '../../../kasir/models/gym_transaction.dart';
import '../../../kasir/models/member.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminMasterDataRepository {
  AdminMasterDataRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl =
          baseUrl ??
          dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080');

  final http.Client _client;
  final String _baseUrl;

  String resolveImageUrl(String? path) {
    final value = path?.trim() ?? '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) return '$_baseUrl$value';
    return value;
  }

  Future<List<GymPackage>> listGymPackages() async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/api/admin/master/gym-packages'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});
    final items = payload['items'];
    if (items is! List) {
      throw const AuthException('Data paket gym dari server tidak valid');
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(GymPackage.fromMap)
        .toList();
  }

  Future<GymPackage> createGymPackage(GymPackageInput input) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/admin/master/gym-packages'),
          headers: await _authorizedHeaders(),
          body: jsonEncode(input.toJson()),
        )
        .timeout(const Duration(seconds: 10));
    return _gymPackageFromMutation(response, {201});
  }

  Future<GymPackage> updateGymPackage(int id, GymPackageInput input) async {
    final response = await _client
        .put(
          Uri.parse('$_baseUrl/api/admin/master/gym-packages/$id'),
          headers: await _authorizedHeaders(),
          body: jsonEncode(input.toJson()),
        )
        .timeout(const Duration(seconds: 10));
    return _gymPackageFromMutation(response, {200});
  }

  Future<void> deleteGymPackage(int id) async {
    final response = await _client
        .delete(
          Uri.parse('$_baseUrl/api/admin/master/gym-packages/$id'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});
  }

  GymPackage _gymPackageFromMutation(
    http.Response response,
    Set<int> successCodes,
  ) {
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, successCodes);
    final item = payload['item'];
    if (item is! Map<String, dynamic>) {
      throw const AuthException('Data paket gym dari server tidak valid');
    }
    return GymPackage.fromMap(item);
  }

  Future<List<FoodBeverageItem>> listFnbItems() async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/api/admin/master/fnb'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});

    final items = payload['items'];
    if (items is! List) {
      throw const AuthException('Data menu F&B dari server tidak valid');
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(FoodBeverageItem.fromApiJson)
        .toList();
  }

  Future<FoodBeverageItem> createFnbItem(FnbItemInput input) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/admin/master/fnb'),
          headers: await _authorizedHeaders(),
          body: jsonEncode(input.toJson()),
        )
        .timeout(const Duration(seconds: 10));
    return _itemFromMutation(response, {201});
  }

  Future<FoodBeverageItem> updateFnbItem(int id, FnbItemInput input) async {
    final response = await _client
        .put(
          Uri.parse('$_baseUrl/api/admin/master/fnb/$id'),
          headers: await _authorizedHeaders(),
          body: jsonEncode(input.toJson()),
        )
        .timeout(const Duration(seconds: 10));
    return _itemFromMutation(response, {200});
  }

  Future<void> deleteFnbItem(int id) async {
    final response = await _client
        .delete(
          Uri.parse('$_baseUrl/api/admin/master/fnb/$id'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});
  }

  Future<List<Member>> listMembers() async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/api/admin/master/members'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});

    final items = payload['items'];
    if (items is! List) {
      throw const AuthException('Data member dari server tidak valid');
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(Member.fromApiJson)
        .toList();
  }

  Future<void> deleteMember(int id) async {
    final response = await _client
        .delete(
          Uri.parse('$_baseUrl/api/admin/master/members/$id'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});
  }

  /// Mencatat perpanjangan membership ke database.
  /// [packageCode] kosong = pakai paket member saat ini.
  Future<void> renewMember(int id, {String packageCode = ''}) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/admin/master/members/$id/renew'),
          headers: await _authorizedHeaders(),
          body: jsonEncode({'package_code': packageCode}),
        )
        .timeout(const Duration(seconds: 15));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});
  }

  /// Daftar transaksi gym terbaru (untuk panel riwayat kasir).
  Future<List<GymTransaction>> listGymTransactions() async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/api/admin/transactions/gym'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});
    final items = payload['items'];
    if (items is! List) {
      throw const AuthException('Data transaksi gym dari server tidak valid');
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(_gymTransactionFromApi)
        .toList();
  }

  /// Mencatat pembayaran layanan gym. Untuk [customerType] == 'member'
  /// backend sekaligus menambah perpanjangan & memperbarui masa berlaku.
  Future<GymTransaction> createGymTransaction({
    required String customerType,
    int? memberId,
    required String packageCode,
    required String paymentMethod,
    String notes = '',
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/admin/transactions/gym'),
          headers: await _authorizedHeaders(),
          body: jsonEncode({
            'customer_type': customerType,
            'member_id': ?memberId,
            'package_code': packageCode,
            'payment_method': paymentMethod,
            'notes': notes,
          }),
        )
        .timeout(const Duration(seconds: 15));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {201});
    final tx = payload['transaction'];
    if (tx is! Map<String, dynamic>) {
      throw const AuthException('Data transaksi gym dari server tidak valid');
    }
    return _gymTransactionFromApi(tx);
  }

  /// Daftar transaksi F&B terbaru (untuk panel riwayat kasir).
  Future<List<FoodBeverageTransaction>> listFnbTransactions() async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/api/admin/transactions/fnb'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});
    final items = payload['items'];
    if (items is! List) {
      throw const AuthException('Data transaksi F&B dari server tidak valid');
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(FoodBeverageTransaction.fromApiJson)
        .toList();
  }

  /// Mencatat penjualan F&B ke database. [memberId] null = pembeli non-member.
  /// Backend sekaligus mengurangi stok tiap item.
  Future<FoodBeverageTransaction> createFnbTransaction({
    int? memberId,
    required String paymentMethod,
    String notes = '',
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/admin/transactions/fnb'),
          headers: await _authorizedHeaders(),
          body: jsonEncode({
            'member_id': memberId,
            'payment_method': paymentMethod,
            'notes': notes,
            'items': items,
          }),
        )
        .timeout(const Duration(seconds: 15));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {201});
    final tx = payload['transaction'];
    if (tx is! Map<String, dynamic>) {
      throw const AuthException('Data transaksi F&B dari server tidak valid');
    }
    return FoodBeverageTransaction.fromApiJson(tx);
  }

  /// Mencari nama member dari member_code (PUBLIK, tanpa token) untuk
  /// halaman konfirmasi absensi di HP sebelum menekan "Hadir".
  Future<AttendanceMember> lookupAttendanceMember(String memberCode) async {
    final response = await _client
        .get(
          Uri.parse(
            '$_baseUrl/api/attendance/member'
            '?code=${Uri.encodeQueryComponent(memberCode)}',
          ),
          headers: const {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});
    return AttendanceMember(
      memberCode: payload['member_code']?.toString() ?? memberCode,
      memberName: payload['member_name']?.toString() ?? '',
      active: payload['active'] == true,
    );
  }

  /// Check-in absensi dari HP member (PUBLIK, tanpa token) saat memindai
  /// barcode. Backend mencatat kehadiran hari ini.
  Future<AttendanceCheckIn> checkInAttendance(String memberCode) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/attendance/check-in'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'member_code': memberCode}),
        )
        .timeout(const Duration(seconds: 15));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200, 201});
    return AttendanceCheckIn(
      memberName: payload['member_name']?.toString() ?? '',
      checkInTime: payload['check_in_time']?.toString() ?? '',
      already: payload['already'] == true,
      message: payload['message']?.toString() ?? '',
    );
  }

  /// Daftar absensi untuk panel kasir (butuh login).
  Future<List<Attendance>> listAttendance() async {
    final response = await _client
        .get(
          Uri.parse('$_baseUrl/api/admin/attendance'),
          headers: await _authorizedHeaders(),
        )
        .timeout(const Duration(seconds: 10));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});
    final items = payload['items'];
    if (items is! List) {
      throw const AuthException('Data absensi dari server tidak valid');
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(Attendance.fromApiJson)
        .toList();
  }

  GymTransaction _gymTransactionFromApi(Map<String, dynamic> json) {
    final date =
        DateTime.tryParse(
          json['transaction_date']?.toString() ?? '',
        )?.toLocal() ??
        DateTime.now();
    return GymTransaction(
      transactionId: json['transaction_code']?.toString() ?? '',
      memberId: 0,
      memberName: json['customer_name']?.toString() ?? '',
      gymPackageId: 0,
      packageName:
          json['package_name']?.toString() ??
          json['package_code']?.toString() ??
          '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method']?.toString() ?? '',
      status: json['status']?.toString() ?? 'completed',
      transactionDate: date,
      notes: json['notes']?.toString(),
      createdAt: date,
      updatedAt: date,
    );
  }

  /// Mengirim email follow-up ke member dan mencatat riwayatnya.
  /// Mengembalikan pesan sukses dari server (mis. "follow-up terkirim ke ...").
  Future<String> sendMemberFollowUp(
    int id, {
    required String subject,
    required String message,
    required String type,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/admin/master/members/$id/follow-up'),
          headers: await _authorizedHeaders(),
          body: jsonEncode({
            'subject': subject,
            'message': message,
            'type': type,
          }),
        )
        .timeout(const Duration(seconds: 30));
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {200});
    final serverMessage = payload['message'];
    return serverMessage is String && serverMessage.trim().isNotEmpty
        ? serverMessage
        : 'Follow-up terkirim.';
  }

  Future<String> uploadFnbImage({
    required List<int> bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/admin/master/fnb/image'),
    );
    request.headers.addAll(await _authorizedHeaders(json: false));
    request.files.add(
      http.MultipartFile.fromBytes('image', bytes, filename: filename),
    );

    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, {201});
    final path = payload['path'];
    if (path is! String || path.trim().isEmpty) {
      throw const AuthException('Path gambar dari server tidak valid');
    }
    return path;
  }

  FoodBeverageItem _itemFromMutation(
    http.Response response,
    Set<int> successCodes,
  ) {
    final payload = _decodePayload(response.body);
    _ensureSuccess(response, payload, successCodes);
    final item = payload['item'];
    if (item is! Map<String, dynamic>) {
      throw const AuthException('Data menu F&B dari server tidak valid');
    }
    return FoodBeverageItem.fromApiJson(item);
  }

  Future<Map<String, String>> _authorizedHeaders({bool json = true}) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    final tokenType = preferences.getString('auth_token_type') ?? 'Bearer';
    if (token == null || token.trim().isEmpty) {
      throw const AuthException(
        'Sesi login tidak ditemukan. Silakan login ulang.',
      );
    }
    return {
      if (json) 'Content-Type': 'application/json',
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

  void _ensureSuccess(
    http.Response response,
    Map<String, dynamic> payload,
    Set<int> successCodes,
  ) {
    if (successCodes.contains(response.statusCode)) return;
    final error = payload['error'];
    throw AuthException(
      error is String && error.trim().isNotEmpty
          ? error
          : 'Gagal memproses master data F&B.',
    );
  }
}

/// Data member untuk halaman konfirmasi absensi (sebelum tekan "Hadir").
class AttendanceMember {
  const AttendanceMember({
    required this.memberCode,
    required this.memberName,
    required this.active,
  });

  final String memberCode;
  final String memberName;
  final bool active;
}

/// Hasil check-in absensi dari backend.
class AttendanceCheckIn {
  const AttendanceCheckIn({
    required this.memberName,
    required this.checkInTime,
    required this.already,
    required this.message,
  });

  final String memberName;
  final String checkInTime;

  /// True bila member sudah tercatat hadir hari ini sebelumnya.
  final bool already;
  final String message;
}

class GymPackageInput {
  const GymPackageInput({
    required this.packageCode,
    required this.packageName,
    required this.description,
    required this.price,
    required this.packageType,
    required this.durationDays,
    required this.isActive,
  });

  final String packageCode;
  final String packageName;
  final String description;
  final double price;
  final String packageType;
  final int durationDays;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'package_code': packageCode,
    'package_name': packageName,
    'description': description,
    'price': price,
    'package_type': packageType,
    'duration_days': durationDays,
    'is_active': isActive,
  };
}

class FnbItemInput {
  const FnbItemInput({
    required this.itemId,
    required this.name,
    required this.description,
    required this.category,
    required this.memberPrice,
    required this.price,
    required this.stock,
    required this.imagePath,
    required this.isActive,
  });

  final String itemId;
  final String name;
  final String description;
  final String category;
  final double memberPrice;
  final double price;
  final int stock;
  final String imagePath;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'name': name,
    'description': description,
    'category': category,
    'member_price': memberPrice,
    'price': price,
    'stock': stock,
    'image_path': imagePath,
    'is_active': isActive,
  };

  FnbItemInput copyWith({String? imagePath}) {
    return FnbItemInput(
      itemId: itemId,
      name: name,
      description: description,
      category: category,
      memberPrice: memberPrice,
      price: price,
      stock: stock,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive,
    );
  }
}
