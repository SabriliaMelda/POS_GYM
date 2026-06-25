import 'package:get/get.dart';

import '../../admin/screens/master/admin_master_data_service.dart';
import '../models/index.dart';

/// Kategori status member untuk filter.
/// - [active]      : masih aktif dan jauh dari kedaluwarsa.
/// - [renewalDue]  : masih aktif tapi <= [MemberManagementController.renewalDueDays]
///                   hari lagi -> perlu perpanjangan.
/// - [expired]     : sudah kedaluwarsa -> harus daftar/bayar ulang (tidak bisa
///                   diperpanjang).
enum MemberFilter { all, active, renewalDue, expired }

/// Controller member untuk kasir. Sumber data = backend (sama seperti admin),
/// bukan mock/SQLite lokal.
class MemberManagementController extends GetxController {
  /// Ambang "perlu perpanjangan": sisa hari <= nilai ini.
  static const int renewalDueDays = 2;

  MemberManagementController({AdminMasterDataRepository? repository})
    : _repository = repository ?? AdminMasterDataRepository();

  final AdminMasterDataRepository _repository;

  final members = <Member>[].obs;
  final filteredMembers = <Member>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final memberFilter = MemberFilter.all.obs;

  /// Paket gym (reaktif) untuk menampilkan NAMA paket, bukan kodenya.
  final packages = <GymPackage>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
    loadGymPackages();
  }

  /// Nama paket dari kodenya (mis. 'PKG-001' -> 'Paket 1 Bulan').
  /// Mengembalikan kode apa adanya bila belum/ tidak ditemukan.
  String packageName(String code) {
    for (final p in packages) {
      if (p.packageId == code) return p.name;
    }
    return code;
  }

  Future<void> loadMembers() async {
    try {
      isLoading.value = true;
      final loaded = await _repository.listMembers();
      members.value = loaded;
      _applyFilter();
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat data member: ${_message(e)}');
    } finally {
      isLoading.value = false;
    }
  }

  /// Daftar paket gym (di-cache) untuk menampilkan nama paket.
  Future<List<GymPackage>> loadGymPackages() async {
    if (packages.isNotEmpty) return packages;
    try {
      packages.value = await _repository.listGymPackages();
      // Picu rebuild daftar (item dibangun lazy) agar nama paket muncul.
      filteredMembers.refresh();
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat paket gym: ${_message(e)}');
    }
    return packages;
  }

  /// Memperpanjang membership lewat backend lalu memuat ulang data.
  /// [packageCode] kosong = pakai paket member saat ini.
  Future<bool> renewMember(Member member, {String packageCode = ''}) async {
    final id = member.id;
    if (id == null) {
      Get.snackbar('Kesalahan', 'ID member tidak valid.');
      return false;
    }
    try {
      isLoading.value = true;
      await _repository.renewMember(id, packageCode: packageCode);
      await loadMembers();
      return true;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memperpanjang: ${_message(e)}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void searchMembers(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void setFilter(MemberFilter filter) {
    memberFilter.value = filter;
    _applyFilter();
  }

  /// Kedaluwarsa -> harus daftar/bayar ulang (tidak bisa diperpanjang).
  static bool isExpired(Member m) => m.isExpired;

  /// Masih aktif tapi mendekati habis -> perlu perpanjangan.
  static bool isRenewalDue(Member m) =>
      !m.isExpired && m.daysUntilExpiry <= renewalDueDays;

  /// Aktif dan masih jauh dari kedaluwarsa.
  static bool isActiveHealthy(Member m) =>
      !m.isExpired && m.daysUntilExpiry > renewalDueDays;

  /// Hanya member yang belum kedaluwarsa yang boleh diperpanjang.
  static bool canRenew(Member m) => !m.isExpired;

  /// Jumlah member pada satu kategori (untuk angka di chip filter).
  int countFor(MemberFilter filter) =>
      members.where((m) => _matchesFilter(m, filter)).length;

  bool _matchesFilter(Member member, MemberFilter filter) {
    return switch (filter) {
      MemberFilter.all => true,
      MemberFilter.active => isActiveHealthy(member),
      MemberFilter.renewalDue => isRenewalDue(member),
      MemberFilter.expired => isExpired(member),
    };
  }

  /// Versi terbaru member dari daftar (untuk menyegarkan tampilan detail
  /// setelah perpanjangan).
  Member? memberById(int? id) {
    if (id == null) return null;
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  void _applyFilter() {
    final query = searchQuery.value.toLowerCase().trim();
    final filter = memberFilter.value;
    filteredMembers.value = members.where((member) {
      if (!_matchesFilter(member, filter)) return false;
      if (query.isEmpty) return true;
      return member.name.toLowerCase().contains(query) ||
          member.memberId.toLowerCase().contains(query) ||
          member.phoneNumber.contains(query);
    }).toList();
  }

  String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
