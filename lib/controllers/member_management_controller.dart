import 'package:get/get.dart';
import '../models/index.dart';
import '../services/mock_data_service.dart';

class MemberManagementController extends GetxController {
  final MockDataService _mockData = MockDataService.instance;

  var members = <Member>[].obs;
  var filteredMembers = <Member>[].obs;
  var selectedMember = Rx<Member?>(null);
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  Future<void> loadMembers() async {
    try {
      isLoading.value = true;
      final loadedMembers = List<Member>.from(_mockData.members);
      members.value = loadedMembers;
      filteredMembers.value = loadedMembers;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat data member: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMember(Member member) async {
    try {
      isLoading.value = true;
      _mockData.addMember(member);
      await loadMembers();
      Get.snackbar('Berhasil', 'Member berhasil ditambahkan');
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal menambahkan member: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMember(Member member) async {
    try {
      isLoading.value = true;
      _mockData.updateMember(member);
      await loadMembers();
      Get.snackbar('Berhasil', 'Member berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memperbarui member: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMember(int memberId) async {
    try {
      isLoading.value = true;
      _mockData.deleteMember(memberId);
      await loadMembers();
      Get.snackbar('Berhasil', 'Member berhasil dihapus');
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal menghapus member: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchMembers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredMembers.value = members;
    } else {
      filteredMembers.value = members
          .where((member) =>
              member.name.toLowerCase().contains(query.toLowerCase()) ||
              member.memberId.toLowerCase().contains(query.toLowerCase()) ||
              member.phoneNumber.contains(query))
          .toList();
    }
  }

  Future<void> selectMember(int memberId) async {
    try {
      final member = _mockData.getMemberById(memberId);
      selectedMember.value = member;
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat detail member: $e');
    }
  }

  Future<List<GymPackage>> loadGymPackages() async {
    try {
      return _mockData.getActiveGymPackages();
    } catch (e) {
      Get.snackbar('Kesalahan', 'Gagal memuat paket gym: $e');
      return [];
    }
  }

  Future<int> getActiveMemberCount() async {
    try {
      return _mockData.getActiveMembers().length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Member>> getExpiredMembers() async {
    try {
      return _mockData.getExpiredMembers();
    } catch (e) {
      return [];
    }
  }
}
