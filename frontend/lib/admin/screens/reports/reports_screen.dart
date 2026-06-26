import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'report_export_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  static const Color _background = Color(0xFFF4F7FC);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _navy = Color(0xFF071A3D);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _accent = Color(0xFFFFC857);

  static const List<_ReportMenu> _reports = [
    _ReportMenu(
      title: 'Laporan Member',
      subtitle:
          'Pantau member aktif, masa berlaku membership, dan pendaftaran baru.',
      icon: Icons.groups_2_rounded,
      color: Color(0xFF2563EB),
      softColor: Color(0xFFEFF6FF),
      tag: 'Keanggotaan',
      type: ReportType.member,
    ),
    _ReportMenu(
      title: 'Laporan Transaksi',
      subtitle:
          'Lihat rekap transaksi layanan gym dan food & beverage per periode.',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF7C3AED),
      softColor: Color(0xFFF5F3FF),
      tag: 'Aktivitas kasir',
      type: ReportType.transaction,
    ),
    _ReportMenu(
      title: 'Laporan Kunjungan',
      subtitle:
          'Analisis kehadiran member, waktu check-in, dan penggunaan daily pass.',
      icon: Icons.calendar_month_rounded,
      color: Color(0xFF059669),
      softColor: Color(0xFFECFDF5),
      tag: 'Operasional',
      type: ReportType.visit,
    ),
  ];

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  _ReportMenu? _selected;
  ReportFileFormat _format = ReportFileFormat.pdf;
  _ReportPeriod _period = _ReportPeriod.all;
  late DateTimeRange _range;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(start: DateTime(now.year, now.month), end: now);
  }

  void _openReport(_ReportMenu report) {
    setState(() {
      _selected = report;
      _format = ReportFileFormat.pdf;
      _period = _ReportPeriod.all;
      final now = DateTime.now();
      _range = DateTimeRange(start: DateTime(now.year, now.month), end: now);
    });
  }

  void _closeReport() => setState(() => _selected = null);

  void _selectPeriod(_ReportPeriod period) {
    setState(() {
      _period = period;
      if (period == _ReportPeriod.all || period == _ReportPeriod.custom) return;
      final now = DateTime.now();
      final days = switch (period) {
        _ReportPeriod.day => 0,
        _ReportPeriod.week => 6,
        _ReportPeriod.month => 29,
        _ReportPeriod.twoMonths => 59,
        _ReportPeriod.year => 364,
        _ReportPeriod.all || _ReportPeriod.custom => 0,
      };
      _range = DateTimeRange(
        start: DateTime(now.year, now.month, now.day - days),
        end: now,
      );
    });
  }

  String get _periodLabel {
    if (_period == _ReportPeriod.all) return 'Semua data';
    final rangeText =
        '${_dateFormat.format(_range.start)} - '
        '${_dateFormat.format(_range.end)}';
    if (_period == _ReportPeriod.custom) return rangeText;
    return '${_period.label} ($rangeText)';
  }

  Future<void> _export() async {
    if (_isExporting || _selected == null) return;
    setState(() => _isExporting = true);
    try {
      final count = await ReportExportService.export(
        type: _selected!.type,
        format: _format,
        startDate: _period == _ReportPeriod.all ? null : _range.start,
        endDate: _period == _ReportPeriod.all ? null : _range.end,
        periodLabel: _periodLabel,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$count data berhasil dibuat dalam format '
            '${_format == ReportFileFormat.pdf ? 'PDF' : 'Excel'}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat laporan: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFB91C1C),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReportsScreen._background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            if (_selected == null) return _buildLanding(isWide);
            return isWide ? _buildSplitWide() : _buildNarrowDetail();
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Landing (belum ada laporan dipilih)
  // ---------------------------------------------------------------------------
  Widget _buildLanding(bool isWide) {
    final horizontalPadding = isWide ? 28.0 : 16.0;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(isWide)),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 10),
          sliver: SliverToBoxAdapter(child: _buildOverview(isWide)),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 12),
          sliver: const SliverToBoxAdapter(child: _SectionTitle()),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 32),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: isWide ? 184 : 182,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildReportCard(ReportsScreen._reports[index]),
              childCount: ReportsScreen._reports.length,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Split dua panel (layar lebar)
  // ---------------------------------------------------------------------------
  Widget _buildSplitWide() {
    return Column(
      children: [
        _buildHeader(true),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 290, child: _buildSidebarList()),
                const SizedBox(width: 18),
                Expanded(
                  child: SingleChildScrollView(child: _buildOptionsPanel()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backLink(),
        const SizedBox(height: 8),
        ...ReportsScreen._reports.map(
          (report) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildSidebarTile(report),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarTile(_ReportMenu report) {
    final selected = report.type == _selected?.type;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openReport(report),
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? report.softColor : ReportsScreen._surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? report.color : ReportsScreen._border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: report.softColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(report.icon, color: report.color, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  report.title,
                  style: const TextStyle(
                    color: ReportsScreen._text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.chevron_right_rounded, color: report.color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Detail (layar sempit)
  // ---------------------------------------------------------------------------
  Widget _buildNarrowDetail() {
    return Column(
      children: [
        _buildHeader(false),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _backLink(),
                const SizedBox(height: 14),
                _buildOptionsPanel(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _backLink() {
    return InkWell(
      onTap: _closeReport,
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: 16,
              color: ReportsScreen._blue,
            ),
            SizedBox(width: 6),
            Text(
              'Kembali ke ringkasan',
              style: TextStyle(
                color: ReportsScreen._blue,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Panel opsi (format + periode + kalender + tombol unduh)
  // ---------------------------------------------------------------------------
  Widget _buildOptionsPanel() {
    final report = _selected!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ReportsScreen._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ReportsScreen._border),
        boxShadow: [
          BoxShadow(
            color: ReportsScreen._navy.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: report.softColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(report.icon, color: report.color, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unduh Laporan',
                      style: TextStyle(
                        color: ReportsScreen._muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      report.title,
                      style: const TextStyle(
                        color: ReportsScreen._text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _label('FORMAT FILE'),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _FormatOption(
                  label: 'PDF',
                  subtitle: 'Siap cetak',
                  icon: Icons.picture_as_pdf_rounded,
                  color: const Color(0xFFDC2626),
                  selected: _format == ReportFileFormat.pdf,
                  onTap: () => setState(() => _format = ReportFileFormat.pdf),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FormatOption(
                  label: 'Excel',
                  subtitle: 'Dapat diedit',
                  icon: Icons.table_view_rounded,
                  color: const Color(0xFF059669),
                  selected: _format == ReportFileFormat.excel,
                  onTap: () => setState(() => _format = ReportFileFormat.excel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _label('PERIODE LAPORAN'),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ReportPeriod.values.map((period) {
              final selected = _period == period;
              return ChoiceChip(
                label: Text(period.label),
                selected: selected,
                onSelected: (_) => _selectPeriod(period),
                showCheckmark: false,
                selectedColor: ReportsScreen._blue.withValues(alpha: 0.12),
                backgroundColor: const Color(0xFFF8FAFC),
                side: BorderSide(
                  color: selected ? ReportsScreen._blue : ReportsScreen._border,
                ),
                labelStyle: TextStyle(
                  color: selected ? ReportsScreen._blue : ReportsScreen._muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _buildPeriodDetail(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: FilledButton.icon(
              onPressed: _isExporting ? null : _export,
              style: FilledButton.styleFrom(
                backgroundColor: ReportsScreen._navy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded, size: 19),
              label: Text(
                _isExporting
                    ? 'Membuat file...'
                    : 'Unduh ${_format == ReportFileFormat.pdf ? 'PDF' : 'Excel'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDetail() {
    if (_period == _ReportPeriod.all) {
      return _infoBox(
        icon: Icons.storage_rounded,
        text: 'Seluruh data dalam database akan disertakan.',
      );
    }
    if (_period != _ReportPeriod.custom) {
      return _infoBox(
        icon: Icons.date_range_rounded,
        text:
            'Periode: ${_dateFormat.format(_range.start)} — '
            '${_dateFormat.format(_range.end)}',
      );
    }
    // Rentang khusus: kalender inline muncul di bawah.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBox(
          icon: Icons.event_available_rounded,
          text:
              'Rentang dipilih: ${_dateFormat.format(_range.start)} — '
              '${_dateFormat.format(_range.end)}',
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ReportsScreen._border),
              ),
              child: _InlineRangeCalendar(
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                range: _range,
                onChanged: (value) => setState(() => _range = value),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoBox({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ReportsScreen._border),
      ),
      child: Row(
        children: [
          Icon(icon, color: ReportsScreen._blue, size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ReportsScreen._text,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: ReportsScreen._muted,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.7,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header & overview & kartu (landing)
  // ---------------------------------------------------------------------------
  Widget _buildHeader(bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isWide ? 28 : 18,
        isWide ? 24 : 20,
        isWide ? 28 : 18,
        isWide ? 26 : 22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ReportsScreen._navy,
            Color(0xFF0B3A7A),
            Color(0xFF155E9F),
          ],
          stops: [0, 0.58, 1],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(
              Icons.insert_chart_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selected == null ? 'Pusat Laporan' : _selected!.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _selected == null
                      ? 'Ringkasan data operasional dalam satu tempat'
                      : 'Pilih format & periode, lalu unduh',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFDCEBFA),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isWide)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: ReportsScreen._accent, size: 17),
                  SizedBox(width: 7),
                  Text(
                    'Data operasional',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
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

  Widget _buildOverview(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ReportsScreen._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ReportsScreen._border),
        boxShadow: [
          BoxShadow(
            color: ReportsScreen._navy.withValues(alpha: 0.055),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: isWide
          ? const Row(
              children: [
                Expanded(flex: 2, child: _OverviewIntro()),
                SizedBox(width: 24),
                Expanded(
                  child: _OverviewStat(
                    icon: Icons.folder_copy_rounded,
                    value: '3',
                    label: 'Jenis laporan',
                    color: ReportsScreen._blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _OverviewStat(
                    icon: Icons.tune_rounded,
                    value: 'Fleksibel',
                    label: 'Filter periode',
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            )
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OverviewIntro(),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _OverviewStat(
                        icon: Icons.folder_copy_rounded,
                        value: '3',
                        label: 'Jenis laporan',
                        color: ReportsScreen._blue,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _OverviewStat(
                        icon: Icons.tune_rounded,
                        value: 'Fleksibel',
                        label: 'Filter periode',
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildReportCard(_ReportMenu report) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openReport(report),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ReportsScreen._surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ReportsScreen._border),
            boxShadow: [
              BoxShadow(
                color: ReportsScreen._navy.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: report.softColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(report.icon, color: report.color, size: 25),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: report.softColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.tag,
                      style: TextStyle(
                        color: report.color,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                report.title,
                style: const TextStyle(
                  color: ReportsScreen._text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.15,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 34,
                child: Text(
                  report.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ReportsScreen._muted,
                    fontSize: 11,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    'Buka opsi unduh',
                    style: TextStyle(
                      color: report.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_forward_rounded, color: report.color, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Kalender rentang inline (tanpa pindah halaman)
// =============================================================================
class _InlineRangeCalendar extends StatefulWidget {
  const _InlineRangeCalendar({
    required this.firstDate,
    required this.lastDate,
    required this.range,
    required this.onChanged,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTimeRange range;
  final ValueChanged<DateTimeRange> onChanged;

  @override
  State<_InlineRangeCalendar> createState() => _InlineRangeCalendarState();
}

class _InlineRangeCalendarState extends State<_InlineRangeCalendar> {
  static const List<String> _weekdays = [
    'Sn',
    'Sl',
    'Rb',
    'Km',
    'Jm',
    'Sb',
    'Mg',
  ];
  static const List<String> _months = [
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

  late DateTime _visibleMonth;
  late DateTime _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = _dateOnly(widget.range.start);
    _end = _dateOnly(widget.range.end);
    _visibleMonth = DateTime(_start.year, _start.month);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _firstMonth =>
      DateTime(widget.firstDate.year, widget.firstDate.month);
  DateTime get _lastMonth =>
      DateTime(widget.lastDate.year, widget.lastDate.month);

  bool get _canPrev => _visibleMonth.isAfter(_firstMonth);
  bool get _canNext => _visibleMonth.isBefore(_lastMonth);

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  bool _isDisabled(DateTime day) {
    return day.isBefore(_dateOnly(widget.firstDate)) ||
        day.isAfter(_dateOnly(widget.lastDate));
  }

  void _onTapDay(DateTime day) {
    if (_isDisabled(day)) return;
    setState(() {
      if (_end != null) {
        // sudah ada rentang lengkap -> mulai baru
        _start = day;
        _end = null;
      } else if (day.isBefore(_start)) {
        _end = _start;
        _start = day;
      } else {
        _end = day;
      }
    });
    final endValue = _end ?? _start;
    widget.onChanged(DateTimeRange(start: _start, end: endValue));
  }

  bool _inRange(DateTime day) {
    final end = _end;
    if (end == null) return false;
    return !day.isBefore(_start) && !day.isAfter(end);
  }

  bool _isEndpoint(DateTime day) {
    return day == _start || day == _end;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // weekday: Senin=1 .. Minggu=7 -> kolom 0..6
    final leadingBlanks =
        DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday - 1;
    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final day = DateTime(_visibleMonth.year, _visibleMonth.month, d);
      cells.add(_dayCell(day));
    }

    return Column(
      children: [
        Row(
          children: [
            _navButton(Icons.chevron_left_rounded, _canPrev ? () => _shiftMonth(-1) : null),
            Expanded(
              child: Text(
                '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ReportsScreen._text,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _navButton(Icons.chevron_right_rounded, _canNext ? () => _shiftMonth(1) : null),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: _weekdays
              .map(
                (w) => Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: const TextStyle(
                        color: ReportsScreen._muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 2),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.45,
          children: cells,
        ),
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback? onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      color: ReportsScreen._blue,
      disabledColor: const Color(0xFFCBD5E1),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      splashRadius: 16,
    );
  }

  Widget _dayCell(DateTime day) {
    final disabled = _isDisabled(day);
    final endpoint = _isEndpoint(day);
    final inRange = _inRange(day);

    Color background = Colors.transparent;
    Color textColor = ReportsScreen._text;
    if (disabled) {
      textColor = const Color(0xFFCBD5E1);
    } else if (endpoint) {
      background = ReportsScreen._blue;
      textColor = Colors.white;
    } else if (inRange) {
      background = ReportsScreen._blue.withValues(alpha: 0.12);
      textColor = ReportsScreen._blue;
    }

    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: disabled ? null : () => _onTapDay(day),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: endpoint ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Widget pendukung
// =============================================================================
class _FormatOption extends StatelessWidget {
  const _FormatOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : ReportsScreen._border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: ReportsScreen._text,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: ReportsScreen._muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

enum _ReportPeriod {
  all('Semua Data'),
  day('Hari Ini'),
  week('1 Minggu'),
  month('1 Bulan'),
  twoMonths('2 Bulan'),
  year('1 Tahun'),
  custom('Rentang Khusus');

  const _ReportPeriod(this.label);

  final String label;
}

class _OverviewIntro extends StatelessWidget {
  const _OverviewIntro();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: ReportsScreen._accent,
              size: 17,
            ),
            SizedBox(width: 7),
            Text(
              'RINGKASAN LAPORAN',
              style: TextStyle(
                color: ReportsScreen._blue,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Pilih data yang ingin dianalisis',
          style: TextStyle(
            color: ReportsScreen._text,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Setiap laporan dapat ditampilkan berdasarkan periode yang dibutuhkan.',
          style: TextStyle(
            color: ReportsScreen._muted,
            fontSize: 11,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ReportsScreen._text,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ReportsScreen._muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kategori Laporan',
                style: TextStyle(
                  color: ReportsScreen._text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Pilih laporan untuk membuka opsi unduh',
                style: TextStyle(
                  color: ReportsScreen._muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.grid_view_rounded, color: ReportsScreen._muted, size: 19),
      ],
    );
  }
}

class _ReportMenu {
  const _ReportMenu({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.tag,
    required this.type,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color softColor;
  final String tag;
  final ReportType type;
}
