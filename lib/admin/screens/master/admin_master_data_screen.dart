import 'package:flutter/material.dart';

import '../../../kasir/models/food_beverage_item.dart';
import '../../../kasir/models/gym_package.dart';
import '../../../kasir/services/mock_data_service.dart';
import '../../../kasir/utils/utils.dart';

class AdminMasterDataScreen extends StatelessWidget {
  const AdminMasterDataScreen({super.key});

  static const Color _background = Color(0xFFF5F7FB);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFD7DEE8);
  static const Color _navy = Color(0xFF071A3D);
  static const Color _accent = Color(0xFF1D4ED8);
  static const Color _softAccent = Color(0xFFE8F4FF);

  @override
  Widget build(BuildContext context) {
    final service = MockDataService.instance;
    final lowStock = service.foodBeverageItems
        .where((item) => item.stock <= 12)
        .toList();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(
                title: 'Master Data',
                subtitle: 'Kontrol paket gym, harga, produk, dan stok F&B.',
                icon: Icons.tune_rounded,
              ),
              const SizedBox(height: 14),
              _SectionPanel(
                title: 'Paket Gym',
                subtitle: '${service.gymPackages.length} paket tersedia',
                icon: Icons.fitness_center_rounded,
                child: _CardGrid(
                  maxCardWidth: 360,
                  cardHeight: 150,
                  children: service.gymPackages
                      .map((package) => _GymPackageCard(package: package))
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              _SectionPanel(
                title: 'Produk Food & Beverage',
                subtitle:
                    '${service.foodBeverageItems.length} produk, ${lowStock.length} stok rendah',
                icon: Icons.local_cafe_rounded,
                child: _CardGrid(
                  maxCardWidth: 360,
                  cardHeight: 168,
                  children: service.foodBeverageItems
                      .map((item) => _FnbCard(item: item))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminMasterDataScreen._navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFDCEBFF),
                    fontSize: 12,
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

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminMasterDataScreen._surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminMasterDataScreen._border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AdminMasterDataScreen._softAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AdminMasterDataScreen._accent, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AdminMasterDataScreen._text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AdminMasterDataScreen._muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminMasterDataScreen._navy,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Responsive grid of equal-size cards; wraps into more columns when wide.
class _CardGrid extends StatelessWidget {
  const _CardGrid({
    required this.children,
    required this.maxCardWidth,
    required this.cardHeight,
  });

  final List<Widget> children;
  final double maxCardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final width = constraints.maxWidth;
        final columns = (width / maxCardWidth).floor().clamp(1, 4);
        final cardWidth = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _GymPackageCard extends StatelessWidget {
  const _GymPackageCard({required this.package});

  final GymPackage package;

  @override
  Widget build(BuildContext context) {
    final isDaily = package.packageId == 'PKG-DAILY';
    final months = _durationInMonths(package.durationInDays);
    final monthlyPrice = isDaily ? package.price : package.price / months;

    return Material(
      color: AdminMasterDataScreen._surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AdminMasterDataScreen._border, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: const Color(0x22071A3D),
      child: InkWell(
        onTap: () {},
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
                      color: AdminMasterDataScreen._softAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _packageIcon(isDaily ? 0 : months),
                      color: AdminMasterDataScreen._accent,
                      size: 17,
                    ),
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
                            color: AdminMasterDataScreen._text,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          isDaily
                              ? 'Satu kali kunjungan'
                              : '$months bulan akses penuh',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AdminMasterDataScreen._muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Badge(
                    label: isDaily ? 'HARIAN' : 'MEMBERSHIP',
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      CurrencyUtils.formatCurrencySimple(package.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AdminMasterDataScreen._text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    isDaily
                        ? 'sekali masuk'
                        : '${CurrencyUtils.formatCurrencySimple(monthlyPrice)}/bln',
                    maxLines: 1,
                    style: const TextStyle(
                      color: AdminMasterDataScreen._accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const _EditButton(),
                ],
              ),
            ],
          ),
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

class _FnbCard extends StatelessWidget {
  const _FnbCard({required this.item});

  final FoodBeverageItem item;

  @override
  Widget build(BuildContext context) {
    final memberPrice = _memberPrice(item.price);
    final lowStock = item.stock <= 12;

    return Material(
      color: AdminMasterDataScreen._surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AdminMasterDataScreen._border, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: const Color(0x22071A3D),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AdminMasterDataScreen._text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _Badge(label: _shortCategory(item.category)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    size: 13,
                    color: lowStock
                        ? const Color(0xFFDC2626)
                        : AdminMasterDataScreen._muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Stok ${item.stock}${lowStock ? ' • rendah' : ''}',
                    style: TextStyle(
                      color: lowStock
                          ? const Color(0xFFDC2626)
                          : AdminMasterDataScreen._muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _PriceRow(
                label: 'Member',
                price: memberPrice,
                color: AdminMasterDataScreen._accent,
                highlighted: true,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: _PriceRow(
                      label: 'Non-member',
                      price: item.price,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const _EditButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortCategory(String category) {
    switch (category.toLowerCase()) {
      case 'meals':
        return 'MAKANAN';
      case 'snacks':
        return 'CAMILAN';
      default:
        return 'MINUMAN';
    }
  }

  double _memberPrice(double nonMemberPrice) {
    return (nonMemberPrice * 0.9 / 1000).round() * 1000;
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.price,
    required this.color,
    this.highlighted = false,
  });

  final String label;
  final double price;
  final Color color;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 78,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: highlighted
                ? AdminMasterDataScreen._softAccent
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            CurrencyUtils.formatCurrencySimple(price),
            maxLines: 1,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AdminMasterDataScreen._softAccent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AdminMasterDataScreen._accent,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.edit_rounded,
          size: 15,
          color: AdminMasterDataScreen._navy,
        ),
      ),
    );
  }
}
