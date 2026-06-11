import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/gym_transaction_controller.dart';
import '../../models/index.dart';
import '../../utils/utils.dart';
import '../../widgets/index.dart';

class GymTransactionScreen extends StatefulWidget {
  const GymTransactionScreen({super.key});

  @override
  State<GymTransactionScreen> createState() => _GymTransactionScreenState();
}

class _GymTransactionScreenState extends State<GymTransactionScreen> {
  bool _showTransactionPanel = false;
  bool _showHistoryPanel = false;
  late final GymTransactionController _controller;

  static const Color _background = Color(0xFFF5F7FB);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _accent = Color(0xFF1D4ED8);
  static const Color _heroStart = Color(0xFF071A3D);
  static const Color _heroMiddle = Color(0xFF0B3A7A);
  static const Color _heroEnd = Color(0xFF155E9F);
  static const Color _buttonAccent = _heroStart;
  static const Color _softAccent = Color(0xFFE8F4FF);

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<GymTransactionController>()
        ? Get.find<GymTransactionController>()
        : Get.put(GymTransactionController());
    if (_controller.packages.isEmpty) _controller.loadGymPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _heroStart,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_heroStart, _heroMiddle, _heroEnd],
            ),
          ),
        ),
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paket Gym',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              'Pilih paket membership untuk transaksi baru',
              style: TextStyle(
                color: Color(0xFFE8F4FF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _toggleHistory(context),
            tooltip: _showHistoryPanel ? 'Tutup riwayat' : 'Riwayat transaksi',
            color: Colors.white,
            icon: Icon(
              _showHistoryPanel
                  ? Icons.view_agenda_rounded
                  : Icons.history_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Obx(
              () => IconButton(
                onPressed: () => _toggleTransaction(context),
                tooltip: _showTransactionPanel
                    ? 'Tutup transaksi'
                    : 'Lihat transaksi',
                color: Colors.white,
                icon: Badge(
                  isLabelVisible: _controller.selectedPackage.value != null,
                  backgroundColor: const Color(0xFFDC2626),
                  child: Icon(
                    _showTransactionPanel
                        ? Icons.view_agenda_rounded
                        : Icons.shopping_cart_rounded,
                    size: 23,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final packages = _controller.packages.toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final canSplit = constraints.maxWidth >= 760;

              if (_showTransactionPanel && canSplit) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        offset: const Offset(-0.02, 0),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: _buildPackageSlivers(
                            packages,
                            includeHero: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _buildTransactionPanel()),
                  ],
                );
              }

              if (_showHistoryPanel && canSplit) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: _buildPackageSlivers(
                          packages,
                          includeHero: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _buildHistoryPanel(_controller)),
                  ],
                );
              }

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: _buildPackageSlivers(packages, includeHero: true),
              );
            },
          );
        }),
      ),
      bottomSheet: Obx(() {
        final splitVisible =
            (_showTransactionPanel || _showHistoryPanel) &&
            MediaQuery.sizeOf(context).width >= 760;
        return _controller.selectedPackage.value == null || splitVisible
            ? const SizedBox.shrink()
            : _buildTransactionBar(context);
      }),
    );
  }

  void _toggleTransaction(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 760) {
      setState(() {
        _showTransactionPanel = !_showTransactionPanel;
        if (_showTransactionPanel) _showHistoryPanel = false;
      });
      return;
    }
    _showTransactionSheet(context);
  }

  void _toggleHistory(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 760) {
      setState(() {
        _showHistoryPanel = !_showHistoryPanel;
        if (_showHistoryPanel) _showTransactionPanel = false;
      });
      return;
    }
    _showHistorySheet(context);
  }

  void _showTransactionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.86,
        child: _buildTransactionPanel(isSheet: true),
      ),
    );
  }

  Widget _buildTransactionPanel({bool isSheet = false}) {
    return Obx(() {
      final package = _controller.selectedPackage.value;
      final customerType = _controller.customerType.value;

      return Container(
        margin: isSheet
            ? EdgeInsets.zero
            : const EdgeInsets.fromLTRB(4, 16, 16, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isSheet
              ? const BorderRadius.vertical(top: Radius.circular(20))
              : BorderRadius.circular(8),
          border: isSheet ? null : Border.all(color: _border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24071A3D),
              blurRadius: 22,
              offset: Offset(0, 9),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              color: _heroStart,
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_cart_rounded,
                    color: Color(0xFFFFC857),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaksi Gym',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Lengkapi pembeli dan paket',
                          style: TextStyle(
                            color: Color(0xFFC8DDF2),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (isSheet) {
                        Get.back<void>();
                      } else {
                        setState(() => _showTransactionPanel = false);
                      }
                    },
                    tooltip: 'Tutup transaksi',
                    color: Colors.white,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Jenis Pembeli',
                    style: TextStyle(
                      color: _text,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'member',
                          icon: Icon(Icons.badge_outlined),
                          label: Text('Member'),
                        ),
                        ButtonSegment(
                          value: 'new',
                          icon: Icon(Icons.person_add_alt_rounded),
                          label: Text('Baru'),
                        ),
                        ButtonSegment(
                          value: 'guest',
                          icon: Icon(Icons.directions_walk_rounded),
                          label: Text('Harian'),
                        ),
                      ],
                      selected: {customerType},
                      onSelectionChanged: (selection) {
                        _controller.setCustomerType(selection.first);
                      },
                      showSelectedIcon: false,
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStatePropertyAll(
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (customerType == 'member') _buildMemberSelector(),
                  if (customerType == 'new') _buildNewMemberInfo(),
                  if (customerType == 'guest') _buildGuestInfo(),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: _border),
                  const SizedBox(height: 16),
                  if (package == null)
                    _buildNoPackageState()
                  else
                    _buildSelectedPackage(package),
                ],
              ),
            ),
            if (package != null) _buildTransactionFooter(isSheet: isSheet),
          ],
        ),
      );
    });
  }

  Widget _buildMemberSelector() {
    final member = _controller.selectedMember.value;
    return Autocomplete<Member>(
      initialValue: TextEditingValue(
        text: member == null ? '' : '${member.name} (${member.memberId})',
      ),
      displayStringForOption: (option) => '${option.name} (${option.memberId})',
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<Member>.empty();
        return _controller.members.where(
          (option) =>
              option.name.toLowerCase().contains(query) ||
              option.memberId.toLowerCase().contains(query) ||
              option.phoneNumber.contains(query),
        );
      },
      onSelected: _controller.selectMember,
      fieldViewBuilder: (context, textController, focusNode, _) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          onChanged: (value) {
            final selectedLabel = member == null
                ? ''
                : '${member.name} (${member.memberId})';
            if (member != null && value != selectedLabel) {
              _controller.selectedMember.value = null;
            }
          },
          decoration: InputDecoration(
            labelText: 'Pilih atau cari member',
            hintText: 'Nama, ID member, atau nomor telepon',
            prefixIcon: const Icon(Icons.search_rounded, color: _accent),
            suffixIcon: member == null
                ? null
                : IconButton(
                    tooltip: 'Hapus pilihan',
                    onPressed: () {
                      textController.clear();
                      _controller.selectedMember.value = null;
                      focusNode.requestFocus();
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final members = options.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440, maxHeight: 280),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: members.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: _border),
                itemBuilder: (context, index) {
                  final option = members[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _softAccent,
                      foregroundColor: _accent,
                      child: Text(
                        option.name.isEmpty
                            ? '?'
                            : option.name[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    title: Text(
                      option.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${option.memberId} | ${option.phoneNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewMemberInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _softAccent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.qr_code_scanner_rounded, color: _accent),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bayar terlebih dahulu',
                  style: TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Setelah pembayaran, pelanggan scan QR registrasi yang tersedia di meja kasir untuk mengisi data diri.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Biaya pendaftaran Rp100.000.',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _softAccent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.directions_walk_rounded, color: _accent),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Non-member menggunakan Daily Pass Rp60.000 untuk satu kali kunjungan.',
              style: TextStyle(
                color: _text,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPackageState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(Icons.local_activity_outlined, size: 38, color: _muted),
          SizedBox(height: 9),
          Text(
            'Belum ada paket dipilih',
            style: TextStyle(color: _text, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 3),
          Text(
            'Klik Pilih Paket pada katalog di sebelah kiri.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPackage(GymPackage package) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _softAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center_rounded, color: _accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  CurrencyUtils.formatCurrency(package.price),
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _controller.selectedPackage.value = null,
            tooltip: 'Hapus paket',
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionFooter({required bool isSheet}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Column(
        children: [
          if (_controller.adminFee > 0)
            _buildAmountRow('Biaya pendaftaran', _controller.adminFee),
          _buildAmountRow(
            'Paket',
            _controller.selectedPackage.value?.price ?? 0,
          ),
          const Divider(height: 18, color: _border),
          _buildAmountRow(
            'Total pembayaran',
            _controller.transactionTotal,
            emphasized: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodSelector(),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton.outlined(
                onPressed: _clearTransaction,
                tooltip: 'Kosongkan transaksi',
                icon: const Icon(Icons.delete_outline_rounded),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _processTransaction(closeSheet: isSheet),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.payments_outlined),
                  label: Text(
                    _controller.customerType.value == 'new'
                        ? 'Bayar & Lanjut Registrasi'
                        : 'Proses Pembayaran',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final method = _controller.paymentMethod.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode pembayaran',
          style: TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'QRIS',
                icon: Icon(Icons.qr_code_2_rounded),
                label: Text('QRIS'),
              ),
              ButtonSegment(
                value: 'Debit (EDC)',
                icon: Icon(Icons.credit_card_rounded),
                label: Text('Debit / EDC'),
              ),
            ],
            selected: {method},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              final selected = selection.first;
              _controller.paymentMethod.value = selected;
              if (selected == 'Debit (EDC)') {
                Get.snackbar(
                  'Pembayaran Debit',
                  'Lanjutkan transaksi debit langsung di mesin EDC.',
                  icon: const Icon(
                    Icons.credit_card_rounded,
                    color: _accent,
                  ),
                );
              }
            },
          ),
        ),
        if (method == 'Debit (EDC)') ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: _muted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Pembayaran debit diproses melalui mesin EDC.',
                  style: TextStyle(
                    color: _muted.withValues(alpha: 0.9),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount, {
    bool emphasized = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: emphasized ? _text : _muted,
              fontSize: emphasized ? 12 : 10,
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          Text(
            CurrencyUtils.formatCurrency(amount),
            style: TextStyle(
              color: emphasized ? _text : _muted,
              fontSize: emphasized ? 17 : 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionBar(BuildContext context) {
    final package = _controller.selectedPackage.value!;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _heroStart,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33071A3D),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.local_activity_rounded, color: Color(0xFFFFC857)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFC8DDF2),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    CurrencyUtils.formatCurrency(_controller.transactionTotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => _showTransactionSheet(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFC857),
                foregroundColor: _heroStart,
              ),
              child: const Text(
                'Lihat Transaksi',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearTransaction() {
    _controller.clearTransaction();
  }

  Future<void> _processTransaction({required bool closeSheet}) async {
    final package = _controller.selectedPackage.value;
    final type = _controller.customerType.value;
    if (package == null) return;

    if (type == 'member' && _controller.selectedMember.value == null) {
      Get.snackbar(
        'Member Belum Dipilih',
        'Pilih member yang akan diperpanjang.',
      );
      return;
    }
    final now = DateTime.now();
    final selectedMember = _controller.selectedMember.value;
    final customerName = type == 'member'
        ? selectedMember!.name
        : type == 'new'
        ? 'Pendaftaran Member Baru'
        : 'Non-member Harian';

    await _controller.createTransaction(
      GymTransaction(
        transactionId: 'GYM-${now.millisecondsSinceEpoch}',
        memberId: selectedMember?.id ?? 0,
        memberName: customerName,
        gymPackageId: package.id ?? 0,
        packageName: package.name,
        amount: _controller.transactionTotal,
        paymentMethod: _controller.paymentMethod.value,
        status: 'Completed',
        transactionDate: now,
        notes: type == 'new'
            ? 'Pembayaran member baru | Data diri melalui QR registrasi kasir'
            : type == 'guest'
            ? 'Kunjungan harian non-member'
            : 'Perpanjangan member',
        createdAt: now,
        updatedAt: now,
      ),
    );

    if (type == 'new') {
      Get.snackbar(
        'Pembayaran Berhasil',
        'Silakan arahkan pelanggan untuk scan QR registrasi di meja kasir.',
        icon: const Icon(Icons.qr_code_scanner_rounded, color: _accent),
      );
    }

    _clearTransaction();
    if (closeSheet && Get.isBottomSheetOpen == true) Get.back<void>();
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.78,
        child: _buildHistoryPanel(_controller),
      ),
    );
  }

  List<Widget> _buildPackageSlivers(
    List<GymPackage> packages, {
    required bool includeHero,
  }) {
    return [
      if (includeHero) SliverToBoxAdapter(child: _buildHero(packages)),
      SliverToBoxAdapter(child: _buildSectionTitle()),
      if (packages.isEmpty)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateWidget(
            title: 'Belum Ada Paket',
            subtitle: 'Paket membership akan tampil di sini',
            icon: Icons.local_activity_outlined,
          ),
        )
      else
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.crossAxisExtent >= 720
                ? 3
                : constraints.crossAxisExtent >= 430
                ? 2
                : 1;
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 188,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildPackageCard(
                    packages[index],
                    Get.find<GymTransactionController>(),
                  );
                }, childCount: packages.length),
              ),
            );
          },
        ),
    ];
  }

  Widget _buildHero(List<GymPackage> packages) {
    final bestValue = packages.isEmpty ? null : packages.last;
    final bestValueMonthlyPrice = bestValue == null
        ? null
        : bestValue.price / _durationInMonths(bestValue.durationInDays);

    return LayoutBuilder(
      builder: (context, constraints) {
        final showBestValue =
            constraints.maxWidth >= 680 && bestValueMonthlyPrice != null;

        return Container(
          height: 258,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33071A3D),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/gym/premium-gym-hero.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
              const ColoredBox(color: Color(0x260B3A7A)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xF2071A3D),
                      Color(0xD90B3A7A),
                      Color(0x5C155E9F),
                      Color(0x12071A3D),
                    ],
                    stops: [0, 0.42, 0.72, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFFFFC857),
                                size: 18,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'PREMIUM MEMBERSHIP',
                                style: TextStyle(
                                  color: Color(0xFFFFC857),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Train Without Limits',
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            'Pilih akses latihan yang sesuai dengan target member.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildHeroPill('${packages.length} Paket'),
                              _buildHeroPill('Mulai 199rb'),
                              _buildHeroPill('Admin 100rb'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (showBestValue) ...[
                      const SizedBox(width: 24),
                      Container(
                        width: 1,
                        height: 116,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      const SizedBox(width: 22),
                      SizedBox(
                        width: 180,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BEST VALUE',
                              style: TextStyle(
                                color: Color(0xFFFFC857),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              bestValue!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${CurrencyUtils.formatCurrency(bestValueMonthlyPrice)} / bulan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFE8F4FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 2, 16, 14),
      child: Row(
        children: [
          SizedBox(
            width: 4,
            height: 38,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF1D4ED8)),
            ),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Koleksi Membership',
                  style: TextStyle(
                    color: _text,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Akses premium untuk setiap tahap latihan',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel(GymTransactionController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 16, 16, 28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24071A3D),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: _heroStart,
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                SizedBox(
                  width: 38,
                  height: 38,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFF0B3A7A),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFFFFC857),
                      size: 21,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Transaksi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Transaksi membership terbaru',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFC8DDF2),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Obx(() {
                final transactions = controller.filteredTransactions;
                if (transactions.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'Belum Ada Transaksi',
                    subtitle: 'Riwayat paket gym akan tampil di sini',
                    icon: Icons.receipt_long_outlined,
                  );
                }

                return ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: _border),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildHistoryTile(transaction);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(GymTransaction transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _softAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: _accent,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.memberName ?? 'Member Tidak Diketahui',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.packageName ?? 'Paket Gym',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.formatCurrency(transaction.amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _text,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                DateTimeUtils.formatDate(transaction.transactionDate),
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    GymPackage package,
    GymTransactionController controller,
  ) {
    final isDaily = package.packageId == 'PKG-DAILY';
    final months = isDaily ? 0 : _durationInMonths(package.durationInDays);
    final monthlyPrice = isDaily ? package.price : package.price / months;

    return Material(
      color: _surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFD7DEE8), width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: const Color(0x33071A3D),
      child: InkWell(
        onTap: () => _selectPackage(package, controller),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _softAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_packageIcon(months), color: _accent, size: 17),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          isDaily
                              ? 'Satu kali kunjungan'
                              : '$months bulan akses penuh',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _softAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isDaily ? 'HARIAN' : 'MEMBERSHIP',
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      CurrencyUtils.formatCurrency(package.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    isDaily
                        ? 'sekali masuk'
                        : '${CurrencyUtils.formatCurrency(monthlyPrice)}/bln',
                    maxLines: 1,
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                package.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 34,
                child: FilledButton.icon(
                  onPressed: () => _selectPackage(package, controller),
                  style: FilledButton.styleFrom(
                    backgroundColor: _buttonAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                  label: const Text(
                    'Pilih Paket',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectPackage(GymPackage package, GymTransactionController controller) {
    controller.selectPackage(package);
    if (MediaQuery.sizeOf(context).width >= 760) {
      setState(() {
        _showTransactionPanel = true;
        _showHistoryPanel = false;
      });
    }
  }

  int _durationInMonths(int days) {
    if (days >= 365) return 12;
    return (days / 30).round().clamp(1, 12);
  }

  IconData _packageIcon(int months) {
    if (months >= 12) return Icons.emoji_events_rounded;
    if (months >= 6) return Icons.workspace_premium_rounded;
    if (months >= 4) return Icons.local_fire_department_rounded;
    if (months >= 2) return Icons.trending_up_rounded;
    return Icons.fitness_center_rounded;
  }
}
