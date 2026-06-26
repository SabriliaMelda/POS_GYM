import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/transaction_history_controller.dart';
import '../../models/index.dart';
import '../../utils/utils.dart';
import '../../widgets/index.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  static const _background = Color(0xFFF5F7FB);
  static const _surface = Colors.white;
  static const _text = Color(0xFF111827);
  static const _muted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _primary = Color(0xFF1D4ED8);
  static const _navy = Color(0xFF071A3D);
  late final TransactionHistoryController _controller;
  final _searchController = TextEditingController();
  String _query = '';
  _HistoryType? _selectedType;
  _DateFilterMode _dateFilterMode = _DateFilterMode.all;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    final isRegistered = Get.isRegistered<TransactionHistoryController>();
    _controller = isRegistered
        ? Get.find<TransactionHistoryController>()
        : Get.put(TransactionHistoryController());
    if (isRegistered) _controller.loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
            ),
          ),
        ),
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              'Semua aktivitas pembayaran gym dan F&B',
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
            onPressed: _controller.loadTransactions,
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final entries = _buildEntries();
        final filteredEntries = _filterEntries(entries);
        final groupedEntries = _groupEntriesByDate(filteredEntries);

        return RefreshIndicator(
          onRefresh: _controller.loadTransactions,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                sliver: SliverToBoxAdapter(child: _buildHero(entries)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                sliver: SliverToBoxAdapter(child: _buildFilters(entries)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Aktivitas Terbaru',
                          style: TextStyle(
                            color: _text,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${filteredEntries.length} aktivitas',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_controller.isLoading.value && entries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredEntries.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    title: 'Riwayat Tidak Ditemukan',
                    subtitle: 'Ubah kata kunci, tipe, atau filter tanggal',
                    icon: Icons.receipt_long_outlined,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  sliver: SliverList.separated(
                    itemCount: groupedEntries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) =>
                        _buildDateSection(groupedEntries[index]),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHero(List<_HistoryEntry> entries) {
    final totalRevenue = entries.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26071A3D),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: _buildHeroSummary(totalRevenue),
    );
  }

  Widget _buildHeroSummary(double totalRevenue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Total Omzet Tercatat',
          style: TextStyle(
            color: Color(0xFFC8DDF2),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyUtils.formatCurrencySimple(totalRevenue),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Gabungan pendaftaran, daily pass, perpanjangan, dan penjualan F&B.',
          style: TextStyle(
            color: Color(0xFFC8DDF2),
            fontSize: 10,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(List<_HistoryEntry> entries) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Cari nama, ID transaksi, paket, atau item...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: _primary),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: _background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primary, width: 1.3),
              ),
            ),
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDateFilterChip(
                icon: Icons.all_inbox_rounded,
                label: 'Semua Tanggal',
                count: entries.length,
                selected: _dateFilterMode == _DateFilterMode.all,
                onSelected: () =>
                    setState(() => _dateFilterMode = _DateFilterMode.all),
              ),
              _buildDateFilterChip(
                icon: Icons.today_rounded,
                label: 'Hari Ini',
                count: _countForDateFilter(entries, _DateFilterMode.today),
                selected: _dateFilterMode == _DateFilterMode.today,
                onSelected: () =>
                    setState(() => _dateFilterMode = _DateFilterMode.today),
              ),
              _buildDateFilterChip(
                icon: Icons.calendar_month_rounded,
                label: 'Bulan Ini',
                count: _countForMonth(entries, DateTime.now()),
                selected:
                    _dateFilterMode == _DateFilterMode.month &&
                    _isSameMonth(_selectedMonth, DateTime.now()),
                onSelected: () => setState(() {
                  final now = DateTime.now();
                  _dateFilterMode = _DateFilterMode.month;
                  _selectedMonth = DateTime(now.year, now.month);
                }),
              ),
              _buildCalendarFilterButton(entries),
            ],
          ),
          const SizedBox(height: 11),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Semua',
                  count: entries.length,
                  selected: _selectedType == null,
                  onSelected: () => setState(() => _selectedType = null),
                ),
                const SizedBox(width: 7),
                ..._HistoryType.values.map((type) {
                  final visual = _visualFor(type);
                  final count = entries
                      .where((entry) => entry.type == type)
                      .length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: _buildFilterChip(
                      label: visual.shortLabel,
                      count: count,
                      selected: _selectedType == type,
                      onSelected: () => setState(() => _selectedType = type),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      label: Text('$label  $count'),
      labelStyle: TextStyle(
        color: selected ? Colors.white : _muted,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
      selectedColor: _primary,
      backgroundColor: _background,
      side: BorderSide(color: selected ? _primary : _border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    );
  }

  Widget _buildDateFilterChip({
    required IconData icon,
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _primary : _background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _primary : _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : _primary),
            const SizedBox(width: 6),
            Text(
              '$label  $count',
              style: TextStyle(
                color: selected ? Colors.white : _muted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarFilterButton(List<_HistoryEntry> entries) {
    final monthActive = _dateFilterMode == _DateFilterMode.month;
    final selected =
        monthActive && !_isSameMonth(_selectedMonth, DateTime.now());
    final label = monthActive ? _monthYearLabel(_selectedMonth) : 'Kalender';
    final count = monthActive ? _countForMonth(entries, _selectedMonth) : null;

    return InkWell(
      onTap: _pickMonthFilter,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _primary : _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_rounded, size: 16, color: _primary),
            const SizedBox(width: 6),
            Text(
              count == null ? label : '$label  $count',
              style: const TextStyle(
                color: _primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMonthFilter() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Pilih bulan riwayat',
      cancelText: 'Batal',
      confirmText: 'Pakai Bulan',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _dateFilterMode = _DateFilterMode.month;
      _selectedMonth = DateTime(picked.year, picked.month);
    });
  }

  Widget _buildDateSection(_HistoryDayGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader(group),
        const SizedBox(height: 8),
        ...group.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildTransactionCard(entry),
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(_HistoryDayGroup group) {
    final transactionCount = group.entries
        .where((entry) => entry.type != _HistoryType.visit)
        .length;
    final visitCount = group.entries
        .where((entry) => entry.type == _HistoryType.visit)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateHeaderTitle(group.date),
                  style: const TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$transactionCount transaksi | $visitCount kunjungan | ${CurrencyUtils.formatCurrencySimple(group.revenue)}',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${group.entries.length}',
            style: const TextStyle(
              color: _primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(_HistoryEntry entry) {
    final visual = _visualFor(entry.type);
    final status = _statusVisual(entry.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F071A3D),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: visual.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(visual.icon, color: visual.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      entry.customerName,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    _buildBadge(
                      visual.label,
                      visual.color,
                      visual.color.withValues(alpha: 0.09),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _buildMetadata(Icons.tag_rounded, entry.transactionId),
                    _buildMetadata(
                      Icons.schedule_rounded,
                      DateTimeUtils.formatDateTime(entry.date),
                    ),
                    _buildMetadata(
                      Icons.payments_outlined,
                      entry.paymentMethod,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.type == _HistoryType.visit
                    ? 'Kunjungan'
                    : CurrencyUtils.formatCurrencySimple(entry.amount),
                style: TextStyle(
                  color: entry.type == _HistoryType.visit
                      ? visual.color
                      : _text,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              _buildBadge(status.label, status.color, status.background),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 13),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  List<_HistoryEntry> _buildEntries() {
    final entries = <_HistoryEntry>[
      ..._controller.gymTransactions.map(_entryFromGym),
      ..._controller.fbTransactions.map(_entryFromFoodBeverage),
      ..._controller.attendanceRecords.map(_entryFromAttendance),
    ];
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  List<_HistoryEntry> _filterEntries(List<_HistoryEntry> entries) {
    final query = _query.toLowerCase();
    return entries.where((entry) {
      if (_selectedType != null && entry.type != _selectedType) return false;
      if (!_matchesDateFilter(entry.date)) return false;
      if (query.isEmpty) return true;
      return entry.customerName.toLowerCase().contains(query) ||
          entry.transactionId.toLowerCase().contains(query) ||
          entry.description.toLowerCase().contains(query) ||
          entry.paymentMethod.toLowerCase().contains(query) ||
          _visualFor(entry.type).label.toLowerCase().contains(query);
    }).toList();
  }

  List<_HistoryDayGroup> _groupEntriesByDate(List<_HistoryEntry> entries) {
    final grouped = <String, List<_HistoryEntry>>{};
    for (final entry in entries) {
      final key = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    return grouped.values.map((items) {
      final date = DateTime(
        items.first.date.year,
        items.first.date.month,
        items.first.date.day,
      );
      final revenue = items.fold<double>(0, (sum, item) => sum + item.amount);
      return _HistoryDayGroup(date: date, entries: items, revenue: revenue);
    }).toList();
  }

  bool _matchesDateFilter(DateTime date) {
    return switch (_dateFilterMode) {
      _DateFilterMode.all => true,
      _DateFilterMode.today => _isSameDate(date, DateTime.now()),
      _DateFilterMode.month => _isSameMonth(date, _selectedMonth),
    };
  }

  int _countForDateFilter(List<_HistoryEntry> entries, _DateFilterMode mode) {
    return switch (mode) {
      _DateFilterMode.all => entries.length,
      _DateFilterMode.today =>
        entries
            .where((entry) => _isSameDate(entry.date, DateTime.now()))
            .length,
      _DateFilterMode.month => _countForMonth(entries, _selectedMonth),
    };
  }

  int _countForMonth(List<_HistoryEntry> entries, DateTime month) {
    return entries.where((entry) => _isSameMonth(entry.date, month)).length;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  String _dateHeaderTitle(DateTime date) {
    final label = _isSameDate(date, DateTime.now())
        ? 'Hari Ini'
        : DateTimeUtils.isYesterday(date)
        ? 'Kemarin'
        : _dayName(date.weekday);
    return '$label, ${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthYearLabel(DateTime date) {
    return '${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const names = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return names[(month - 1) % 12];
  }

  String _dayName(int weekday) {
    const names = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return names[(weekday - 1) % 7];
  }

  DateTime _attendanceDateTime(Attendance attendance) {
    final base = attendance.attendanceDate;
    final match = RegExp(
      r'^(\d{1,2}):(\d{1,2})',
    ).firstMatch(attendance.checkInTime ?? '');
    if (match == null) return base;

    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) return base;

    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  String _attendanceAccessMethod(Attendance attendance) {
    final credential = (attendance.rfidCardNumber ?? '').toUpperCase();
    if (credential.contains('RFID')) return 'RFID';
    if (credential.contains('BARCODE')) return 'Barcode';
    if (credential.contains('DAILY')) return 'Akses kasir';
    return 'Manual';
  }

  _HistoryEntry _entryFromGym(GymTransaction transaction) {
    final notes = (transaction.notes ?? '').toLowerCase();
    final package = (transaction.packageName ?? '').toLowerCase();
    final customer = (transaction.memberName ?? '').toLowerCase();

    final type =
        notes.contains('member baru') ||
            customer.contains('pendaftaran member baru')
        ? _HistoryType.registration
        : notes.contains('harian') || package.contains('daily pass')
        ? _HistoryType.dailyPass
        : _HistoryType.renewal;

    final description = switch (type) {
      _HistoryType.registration =>
        '${transaction.packageName ?? 'Paket gym'} + biaya pendaftaran member baru',
      _HistoryType.dailyPass =>
        '${transaction.packageName ?? 'Daily Pass'} untuk kunjungan harian',
      _HistoryType.renewal =>
        'Perpanjangan ${transaction.packageName ?? 'membership gym'}',
      _HistoryType.foodBeverage => transaction.packageName ?? 'Transaksi gym',
      _HistoryType.visit => transaction.packageName ?? 'Kunjungan gym',
    };

    return _HistoryEntry(
      transactionId: transaction.transactionId,
      customerName: transaction.memberName ?? 'Pelanggan Gym',
      description: description,
      amount: transaction.amount,
      paymentMethod: transaction.paymentMethod,
      status: transaction.status,
      date: transaction.transactionDate,
      type: type,
    );
  }

  _HistoryEntry _entryFromFoodBeverage(FoodBeverageTransaction transaction) {
    final totalQuantity = transaction.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final itemNames = transaction.items.map((item) => item.itemName).join(', ');
    final description = itemNames.isEmpty
        ? '${transaction.items.length} jenis item F&B'
        : '$totalQuantity item: $itemNames';

    return _HistoryEntry(
      transactionId: transaction.transactionId,
      customerName: transaction.memberName ?? 'Pelanggan Non-member',
      description: description,
      amount: transaction.finalAmount,
      paymentMethod: transaction.paymentMethod,
      status: transaction.status,
      date: transaction.transactionDate,
      type: _HistoryType.foodBeverage,
    );
  }

  _HistoryEntry _entryFromAttendance(Attendance attendance) {
    final dateTime = _attendanceDateTime(attendance);
    final checkInTime =
        attendance.checkInTime ?? DateTimeUtils.formatTime(dateTime);
    final accessMethod = _attendanceAccessMethod(attendance);

    return _HistoryEntry(
      transactionId:
          'VISIT-${(attendance.id ?? attendance.memberId).toString().padLeft(4, '0')}',
      customerName: attendance.memberName ?? 'Member Tidak Diketahui',
      description: 'Check-in pukul $checkInTime melalui $accessMethod',
      amount: 0,
      paymentMethod: accessMethod,
      status: 'hadir',
      date: dateTime,
      type: _HistoryType.visit,
    );
  }

  ({String label, String shortLabel, IconData icon, Color color}) _visualFor(
    _HistoryType type,
  ) {
    return switch (type) {
      _HistoryType.registration => (
        label: 'Pendaftaran Baru',
        shortLabel: 'Pendaftaran',
        icon: Icons.person_add_alt_1_rounded,
        color: const Color(0xFF2563EB),
      ),
      _HistoryType.dailyPass => (
        label: 'Daily Pass',
        shortLabel: 'Daily Pass',
        icon: Icons.directions_walk_rounded,
        color: const Color(0xFFD97706),
      ),
      _HistoryType.foodBeverage => (
        label: 'Food & Beverage',
        shortLabel: 'F&B',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFF7C3AED),
      ),
      _HistoryType.renewal => (
        label: 'Perpanjangan',
        shortLabel: 'Perpanjangan',
        icon: Icons.autorenew_rounded,
        color: const Color(0xFF0891B2),
      ),
      _HistoryType.visit => (
        label: 'Kunjungan Member',
        shortLabel: 'Kunjungan',
        icon: Icons.login_rounded,
        color: const Color(0xFF16A34A),
      ),
    };
  }

  ({String label, Color color, Color background}) _statusVisual(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
      case 'selesai':
        return (
          label: 'SELESAI',
          color: const Color(0xFF15803D),
          background: const Color(0xFFEAF7EE),
        );
      case 'pending':
        return (
          label: 'MENUNGGU',
          color: const Color(0xFFB45309),
          background: const Color(0xFFFFF7E6),
        );
      case 'cancelled':
        return (
          label: 'DIBATALKAN',
          color: const Color(0xFFB91C1C),
          background: const Color(0xFFFEECEC),
        );
      case 'hadir':
      case 'checked in':
        return (
          label: 'HADIR',
          color: const Color(0xFF15803D),
          background: const Color(0xFFEAF7EE),
        );
      default:
        return (
          label: value.toUpperCase(),
          color: _muted,
          background: _background,
        );
    }
  }
}

class _HistoryDayGroup {
  const _HistoryDayGroup({
    required this.date,
    required this.entries,
    required this.revenue,
  });

  final DateTime date;
  final List<_HistoryEntry> entries;
  final double revenue;
}

enum _HistoryType { registration, dailyPass, foodBeverage, renewal, visit }

enum _DateFilterMode { all, today, month }

class _HistoryEntry {
  const _HistoryEntry({
    required this.transactionId,
    required this.customerName,
    required this.description,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.date,
    required this.type,
  });

  final String transactionId;
  final String customerName;
  final String description;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime date;
  final _HistoryType type;
}
