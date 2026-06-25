import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../../kasir/models/index.dart';
import '../../../kasir/services/mock_data_service.dart';

class AdminRiwayatScreen extends StatefulWidget {
  const AdminRiwayatScreen({super.key});

  @override
  State<AdminRiwayatScreen> createState() => _AdminRiwayatScreenState();
}

class _AdminRiwayatScreenState extends State<AdminRiwayatScreen> {
  static const Color _background = Color(0xFFF4F7FB);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _primary = Color(0xFF1D4ED8);

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _HistoryType? _selectedType;
  _DateFilterMode _dateFilterMode = _DateFilterMode.all;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _showFilterPanel = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();
    final filteredEntries = _filterEntries(entries);
    final groupedEntries = _groupEntriesByDate(filteredEntries);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              sliver: SliverToBoxAdapter(
                child: _Header(
                  totalActivities: filteredEntries.length,
                  totalRevenue: filteredEntries.fold<double>(
                    0,
                    (sum, item) => sum + item.amount,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              sliver: SliverToBoxAdapter(child: _buildFilters(entries)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Riwayat per Tanggal',
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (filteredEntries.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: _EmptyState()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                sliver: SliverList.separated(
                  itemCount: groupedEntries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return _buildDateSection(groupedEntries[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(List<_HistoryEntry> entries) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Cari nama, ID, paket, item, atau metode akses...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: _primary),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
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
          _buildFilterBar(entries),
          if (_showFilterPanel) ...[
            const SizedBox(height: 11),
            _buildFilterPanel(entries),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<_HistoryEntry> entries) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, color: _primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _activeFilterLabel(entries),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _text,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              setState(() => _showFilterPanel = !_showFilterPanel);
            },
            icon: Icon(
              _showFilterPanel
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.filter_alt_rounded,
              size: 17,
            ),
            label: Text(_showFilterPanel ? 'Tutup' : 'Filter'),
            style: TextButton.styleFrom(
              foregroundColor: _primary,
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(List<_HistoryEntry> entries) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Periode',
            style: TextStyle(
              color: _text,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterModeChip(
                icon: Icons.all_inbox_rounded,
                label: 'Semua',
                selected: _dateFilterMode == _DateFilterMode.all,
                onTap: () =>
                    setState(() => _dateFilterMode = _DateFilterMode.all),
              ),
              _buildFilterModeChip(
                icon: Icons.today_rounded,
                label: 'Tanggal',
                selected: _dateFilterMode == _DateFilterMode.day,
                onTap: () async {
                  if (_dateFilterMode != _DateFilterMode.day) {
                    setState(() => _dateFilterMode = _DateFilterMode.day);
                  }
                  await _pickDateFilter();
                },
              ),
              _buildFilterModeChip(
                icon: Icons.calendar_month_rounded,
                label: 'Bulan',
                selected: _dateFilterMode == _DateFilterMode.month,
                onTap: () async {
                  if (_dateFilterMode != _DateFilterMode.month) {
                    setState(() => _dateFilterMode = _DateFilterMode.month);
                  }
                  await _pickMonthFilter();
                },
              ),
            ],
          ),
          if (_dateFilterMode != _DateFilterMode.all) ...[
            const SizedBox(height: 10),
            _buildCalendarSettingTile(entries),
          ],
          const SizedBox(height: 12),
          const Text(
            'Jenis Aktivitas',
            style: TextStyle(
              color: _text,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeChip(
                  label: 'Semua',
                  count: entries
                      .where((entry) => _matchesDateFilter(entry.date))
                      .length,
                  selected: _selectedType == null,
                  onTap: () => setState(() => _selectedType = null),
                ),
                const SizedBox(width: 7),
                ..._HistoryType.values.map((type) {
                  final visual = _visualFor(type);
                  return Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: _buildTypeChip(
                      label: visual.shortLabel,
                      count: entries
                          .where(
                            (entry) =>
                                entry.type == type &&
                                _matchesDateFilter(entry.date),
                          )
                          .length,
                      selected: _selectedType == type,
                      onTap: () => setState(() => _selectedType = type),
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

  Widget _buildFilterModeChip({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _primary : _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _primary : _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? Colors.white : _primary, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
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

  Widget _buildCalendarSettingTile(List<_HistoryEntry> entries) {
    final dayMode = _dateFilterMode == _DateFilterMode.day;
    final title = dayMode ? 'Tanggal dipilih' : 'Bulan dipilih';
    final value = dayMode
        ? _fullDateLabel(_selectedDate)
        : _monthYearLabel(_selectedMonth);
    final count = dayMode
        ? entries
              .where((entry) => _isSameDate(entry.date, _selectedDate))
              .length
        : _countForMonth(entries, _selectedMonth);

    return InkWell(
      onTap: dayMode ? _pickDateFilter : _pickMonthFilter,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event_rounded, color: _primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$value | $count aktivitas',
                    style: const TextStyle(
                      color: _text,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _muted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      label: Text('$label  $count'),
      labelStyle: TextStyle(
        color: selected ? Colors.white : _muted,
        fontSize: 10,
        fontWeight: FontWeight.w900,
      ),
      selectedColor: _primary,
      backgroundColor: _background,
      side: BorderSide(color: selected ? _primary : _border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
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

  Future<void> _pickDateFilter() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Pilih tanggal riwayat',
      cancelText: 'Batal',
      confirmText: 'Pakai Tanggal',
    );
    if (picked == null || !mounted) return;

    setState(() {
      _dateFilterMode = _DateFilterMode.day;
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
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
            child: _buildHistoryTile(entry),
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
            width: 36,
            height: 36,
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
                  '$transactionCount transaksi | $visitCount kunjungan | ${_currency.format(group.revenue)}',
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

  Widget _buildHistoryTile(_HistoryEntry entry) {
    final visual = _visualFor(entry.type);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D071A3D),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: visual.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(visual.icon, color: visual.color, size: 21),
          ),
          const SizedBox(width: 10),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    _Badge(
                      label: visual.label,
                      color: visual.color,
                      background: visual.color.withValues(alpha: 0.09),
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _metadata(Icons.tag_rounded, entry.id),
                    _metadata(
                      Icons.schedule_rounded,
                      _dateTimeLabel(entry.date),
                    ),
                    _metadata(Icons.payments_outlined, entry.method),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.type == _HistoryType.visit
                    ? 'Kunjungan'
                    : _currency.format(entry.amount),
                style: TextStyle(
                  color: entry.type == _HistoryType.visit
                      ? visual.color
                      : _text,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              _Badge(
                label: entry.status,
                color: entry.type == _HistoryType.visit
                    ? const Color(0xFF15803D)
                    : _primary,
                background: entry.type == _HistoryType.visit
                    ? const Color(0xFFEAF7EE)
                    : const Color(0xFFEFF6FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metadata(IconData icon, String value) {
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  List<_HistoryEntry> _buildEntries() {
    final service = MockDataService.instance;
    final entries = <_HistoryEntry>[
      ...service.gymTransactions.map(_entryFromGym),
      ...service.foodBeverageTransactions.map(_entryFromFoodBeverage),
      ...service.attendanceRecords.map(_entryFromAttendance),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  List<_HistoryEntry> _filterEntries(List<_HistoryEntry> entries) {
    final query = _query.toLowerCase();
    return entries.where((entry) {
      if (_selectedType != null && entry.type != _selectedType) return false;
      if (!_matchesDateFilter(entry.date)) return false;
      if (query.isEmpty) return true;

      return entry.id.toLowerCase().contains(query) ||
          entry.customerName.toLowerCase().contains(query) ||
          entry.description.toLowerCase().contains(query) ||
          entry.method.toLowerCase().contains(query) ||
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
      _DateFilterMode.day => _isSameDate(date, _selectedDate),
      _DateFilterMode.month => _isSameMonth(date, _selectedMonth),
    };
  }

  String _activeFilterLabel(List<_HistoryEntry> entries) {
    final typeLabel = _selectedType == null
        ? 'Semua jenis'
        : _visualFor(_selectedType!).label;
    final count = entries.where((entry) {
      if (_selectedType != null && entry.type != _selectedType) return false;
      return _matchesDateFilter(entry.date);
    }).length;

    final periodLabel = switch (_dateFilterMode) {
      _DateFilterMode.all => 'Semua tanggal',
      _DateFilterMode.day => _fullDateLabel(_selectedDate),
      _DateFilterMode.month => _monthYearLabel(_selectedMonth),
    };
    return '$periodLabel | $typeLabel | $count aktivitas';
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

  _HistoryEntry _entryFromGym(GymTransaction trx) {
    final notes = (trx.notes ?? '').toLowerCase();
    final package = (trx.packageName ?? '').toLowerCase();
    final customer = (trx.memberName ?? '').toLowerCase();
    final type =
        notes.contains('member baru') ||
            customer.contains('pendaftaran member baru')
        ? _HistoryType.registration
        : notes.contains('harian') || package.contains('daily pass')
        ? _HistoryType.dailyPass
        : _HistoryType.renewal;

    return _HistoryEntry(
      id: trx.transactionId,
      customerName: trx.memberName ?? 'Pelanggan Gym',
      description: switch (type) {
        _HistoryType.registration =>
          '${trx.packageName ?? 'Paket gym'} + biaya pendaftaran member baru',
        _HistoryType.dailyPass =>
          '${trx.packageName ?? 'Daily Pass'} untuk kunjungan harian',
        _HistoryType.renewal =>
          'Perpanjangan ${trx.packageName ?? 'membership gym'}',
        _HistoryType.foodBeverage => trx.packageName ?? 'Transaksi gym',
        _HistoryType.visit => trx.packageName ?? 'Kunjungan gym',
      },
      amount: trx.amount,
      method: trx.paymentMethod,
      status: _statusLabel(trx.status),
      date: trx.transactionDate,
      type: type,
    );
  }

  _HistoryEntry _entryFromFoodBeverage(FoodBeverageTransaction trx) {
    final totalQuantity = trx.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final itemNames = trx.items.map((item) => item.itemName).join(', ');

    return _HistoryEntry(
      id: trx.transactionId,
      customerName: trx.memberName ?? 'Pelanggan Non-member',
      description: itemNames.isEmpty
          ? '${trx.items.length} jenis item F&B'
          : '$totalQuantity item: $itemNames',
      amount: trx.finalAmount,
      method: trx.paymentMethod,
      status: _statusLabel(trx.status),
      date: trx.transactionDate,
      type: _HistoryType.foodBeverage,
    );
  }

  _HistoryEntry _entryFromAttendance(Attendance attendance) {
    final dateTime = _attendanceDateTime(attendance);
    final checkInTime = attendance.checkInTime ?? _timeLabel(dateTime);
    final accessMethod = _attendanceAccessMethod(attendance);

    return _HistoryEntry(
      id: 'VISIT-${(attendance.id ?? attendance.memberId).toString().padLeft(4, '0')}',
      customerName: attendance.memberName ?? 'Member Tidak Diketahui',
      description: 'Check-in pukul $checkInTime melalui $accessMethod',
      amount: 0,
      method: accessMethod,
      status: 'HADIR',
      date: dateTime,
      type: _HistoryType.visit,
    );
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

  String _statusLabel(String status) {
    return switch (status.toLowerCase()) {
      'completed' || 'selesai' => 'SELESAI',
      'pending' => 'MENUNGGU',
      'cancelled' => 'DIBATALKAN',
      _ => status.toUpperCase(),
    };
  }

  ({String label, String shortLabel, IconData icon, Color color}) _visualFor(
    _HistoryType type,
  ) {
    return switch (type) {
      _HistoryType.registration => (
        label: 'Pendaftaran',
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
        label: 'Kunjungan',
        shortLabel: 'Kunjungan',
        icon: Icons.login_rounded,
        color: const Color(0xFF16A34A),
      ),
    };
  }

  String _dateHeaderTitle(DateTime date) {
    final label = _isSameDate(date, DateTime.now())
        ? 'Hari Ini'
        : _isSameDate(date, DateTime.now().subtract(const Duration(days: 1)))
        ? 'Kemarin'
        : _dayName(date.weekday);
    return '$label, ${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _dateTimeLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${_timeLabel(date)}';
  }

  String _fullDateLabel(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _timeLabel(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
}

class _Header extends StatelessWidget {
  const _Header({required this.totalActivities, required this.totalRevenue});

  final int totalActivities;
  final double totalRevenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Riwayat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalActivities aktivitas | ${_AdminRiwayatScreenState._currency.format(totalRevenue)}',
                  style: const TextStyle(
                    color: Color(0xFFDCEBFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Transaksi dan kunjungan dikelompokkan berdasarkan tanggal.',
                  style: TextStyle(
                    color: Color(0xFFC8DDF2),
                    fontSize: 10,
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
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.receipt_long_outlined, color: Color(0xFF94A3B8), size: 42),
        SizedBox(height: 10),
        Text(
          'Riwayat Tidak Ditemukan',
          style: TextStyle(
            color: _AdminRiwayatScreenState._text,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Ubah kata kunci, tipe, atau filter tanggal.',
          style: TextStyle(
            color: _AdminRiwayatScreenState._muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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

class _HistoryEntry {
  const _HistoryEntry({
    required this.id,
    required this.customerName,
    required this.description,
    required this.amount,
    required this.method,
    required this.status,
    required this.date,
    required this.type,
  });

  final String id;
  final String customerName;
  final String description;
  final double amount;
  final String method;
  final String status;
  final DateTime date;
  final _HistoryType type;
}

enum _HistoryType { registration, dailyPass, foodBeverage, renewal, visit }

enum _DateFilterMode { all, day, month }
