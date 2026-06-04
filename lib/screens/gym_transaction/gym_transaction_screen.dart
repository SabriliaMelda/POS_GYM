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
  bool _showHistory = false;

  static const Color _background = Color(0xFFF5F7FB);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _accent = Color(0xFF1F3A5F);
  static const Color _heroStart = Color(0xFF071A3D);
  static const Color _heroMiddle = Color(0xFF0B3A7A);
  static const Color _heroEnd = Color(0xFF155E9F);
  static const Color _buttonAccent = _heroStart;
  static const Color _softAccent = Color(0xFFEFF6FF);
  static const Color _success = Color(0xFF15803D);
  static const double _registrationAdminFee = 100000;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GymTransactionController());

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: FutureBuilder<List<GymPackage>>(
          future: controller.loadGymPackages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(message: 'Memuat paket gym...');
            }

            final packages = snapshot.data ?? [];

            return LayoutBuilder(
              builder: (context, constraints) {
                final canSplit = constraints.maxWidth >= 760;

                if (_showHistory && canSplit) {
                  return Column(
                    children: [
                      _buildTopBar(),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: AnimatedSlide(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutCubic,
                                offset: const Offset(-0.02, 0),
                                child: CustomScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  slivers: _buildPackageSlivers(
                                    packages,
                                    includeHero: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: AnimatedSlide(
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOutCubic,
                                offset: Offset.zero,
                                child: _buildHistoryPanel(controller),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildTopBar()),
                    ..._buildPackageSlivers(
                      packages,
                      includeHero: true,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _heroMiddle,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _heroMiddle.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.fitness_center_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paket Gym',
                  style: TextStyle(
                    color: _text,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Pilih paket membership untuk member',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
            icon: Icon(
              _showHistory
                  ? Icons.view_agenda_rounded
                  : Icons.receipt_long_rounded,
            ),
            tooltip: _showHistory ? 'Tampilkan paket' : 'Riwayat transaksi',
            style: IconButton.styleFrom(
              foregroundColor: _accent,
              backgroundColor: _softAccent,
            ),
          ),
        ],
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 150,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildPackageCard(
                      packages[index],
                      Get.find<GymTransactionController>(),
                      columns: columns,
                    );
                  },
                  childCount: packages.length,
                ),
              ),
            );
          },
        ),
    ];
  }

  Widget _buildHero(List<GymPackage> packages) {
    final bestValue = packages.isEmpty ? null : packages.last;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_heroStart, _heroMiddle, _heroEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: _heroMiddle.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Membership fleksibel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bestValue == null
                      ? 'Kelola pilihan paket bulanan sampai tahunan'
                      : 'Paket terbaik: ${bestValue.name}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHeroPill('${packages.length} Paket'),
                    _buildHeroPill('Mulai 199rb'),
                    _buildHeroPill('Admin daftar 100rb'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
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
      padding: EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Text(
        'Pilihan Paket',
        style: TextStyle(
          color: _text,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildHistoryPanel(GymTransactionController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 4, 16, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16,
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _softAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: _accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Transaksi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Transaksi paket gym terbaru',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
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
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildHistoryTile(transaction);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(GymTransaction transaction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _softAccent,
              borderRadius: BorderRadius.circular(11),
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
    GymTransactionController controller, {
    required int columns,
  }) {
    final months = _durationInMonths(package.durationInDays);
    final isPopular = months == 6;
    final isBestValue = months == 12;
    final monthlyPrice = package.price / months;
    final registrationTotal = package.price + _registrationAdminFee;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? _accent.withValues(alpha: 0.28) : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _softAccent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            _packageIcon(months),
                            color: _accent,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  package.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (isPopular || isBestValue) ...[
                                const SizedBox(width: 5),
                                _buildBadge(
                                  isBestValue ? 'Best Value' : 'Populer',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      CurrencyUtils.formatCurrency(package.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      package.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyUtils.formatCurrency(monthlyPrice)} / bulan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total Payment '
                      '${CurrencyUtils.formatCurrency(registrationTotal)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _success,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _buildQrAction(
                package,
                controller,
                columns: columns,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrAction(
    GymPackage package,
    GymTransactionController controller, {
    required int columns,
  }) {
    final totalPayment = package.price + _registrationAdminFee;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        controller.selectPackage(package);
        Get.snackbar(
          'QR Payment',
          '${package.name} + admin daftar '
          '${CurrencyUtils.formatCurrency(_registrationAdminFee)} = '
          '${CurrencyUtils.formatCurrency(totalPayment)}',
        );
      },
      child: Container(
        width: columns >= 3 ? 96 : columns == 2 ? 116 : 140,
        height: 118,
        decoration: BoxDecoration(
          color: _buttonAccent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _buttonAccent.withValues(alpha: 0.20),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 30),
            SizedBox(height: 5),
            Text(
              'QR Code',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _success.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _success,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
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
