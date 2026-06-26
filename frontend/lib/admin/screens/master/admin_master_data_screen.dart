import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../kasir/models/food_beverage_item.dart';
import '../../../kasir/models/gym_package.dart';
import '../../../kasir/utils/utils.dart';
import 'admin_master_data_service.dart';

class AdminMasterDataScreen extends StatefulWidget {
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
  State<AdminMasterDataScreen> createState() => _AdminMasterDataScreenState();
}

class _AdminMasterDataScreenState extends State<AdminMasterDataScreen> {
  final AdminMasterDataRepository _repository = AdminMasterDataRepository();
  final ScrollController _catalogScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<GymPackage> _gymPackages = const [];
  List<FoodBeverageItem> _fnbItems = const [];
  bool _isGymLoading = true;
  bool _isGymSaving = false;
  String? _gymLoadError;
  bool _isLoading = true;
  String? _loadError;
  bool _showEditor = false;
  bool _isSaving = false;
  FoodBeverageItem? _editingItem;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadGymPackages();
    _loadFnbItems();
  }

  Future<void> _loadGymPackages() async {
    setState(() {
      _isGymLoading = true;
      _gymLoadError = null;
    });
    try {
      final items = await _repository.listGymPackages();
      if (!mounted) return;
      setState(() => _gymPackages = items);
    } catch (error) {
      if (!mounted) return;
      setState(() => _gymLoadError = error.toString());
    } finally {
      if (mounted) setState(() => _isGymLoading = false);
    }
  }

  @override
  void dispose() {
    _catalogScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFnbItems() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final items = await _repository.listFnbItems();
      if (!mounted) return;
      setState(() => _fnbItems = items);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowStock = _fnbItems.where((item) => item.stock <= 12).toList();

    return Scaffold(
      backgroundColor: AdminMasterDataScreen._background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useSplit = _showEditor && constraints.maxWidth >= 900;
            final catalog = _buildCatalog(lowStock);
            if (!useSplit) return catalog;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    offset: const Offset(-0.01, 0),
                    child: catalog,
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth >= 1200 ? 450 : 400,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      offset: Offset.zero,
                      child: _FnbFormDialog(
                        key: ValueKey(
                          _editingItem?.id ?? 'new-${_nextItemId()}',
                        ),
                        item: _editingItem,
                        nextItemId: _nextItemId(),
                        existingImageUrl: _repository.resolveImageUrl(
                          _editingItem?.imagePath,
                        ),
                        embedded: true,
                        isSaving: _isSaving,
                        onClose: _closeEditor,
                        onResult: (result) =>
                            _handleFnbResult(result, _editingItem),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCatalog(List<FoodBeverageItem> lowStock) {
    return SingleChildScrollView(
      controller: _catalogScrollController,
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
            subtitle: '${_gymPackages.length} paket tersedia',
            icon: Icons.fitness_center_rounded,
            onAdd: _isGymSaving ? () {} : () => _openGymPackageForm(),
            child: _buildGymPackageContent(),
          ),
          const SizedBox(height: 14),
          _SectionPanel(
            title: 'Produk Food & Beverage',
            subtitle:
                '${_fnbItems.length} produk, ${lowStock.length} stok rendah',
            icon: Icons.local_cafe_rounded,
            onAdd: () => _openFnbForm(),
            child: _buildFnbContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildGymPackageContent() {
    if (_isGymLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_gymLoadError != null) {
      return _LoadError(message: _gymLoadError!, onRetry: _loadGymPackages);
    }
    if (_gymPackages.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Belum ada paket gym di database.')),
      );
    }
    return _CardGrid(
      minCardWidth: 280,
      cardHeight: 184,
      children: _gymPackages
          .map(
            (package) => _GymPackageCard(
              package: package,
              onEdit: () => _openGymPackageForm(package),
            ),
          )
          .toList(),
    );
  }

  Future<void> _openGymPackageForm([GymPackage? package]) async {
    final result = await showDialog<_GymPackageFormResult>(
      context: context,
      builder: (_) => _GymPackageFormDialog(
        package: package,
        nextPackageCode: _nextPackageCode(),
      ),
    );
    if (result == null || !mounted || _isGymSaving) return;
    setState(() => _isGymSaving = true);
    try {
      if (result.delete && package?.id != null) {
        await _repository.deleteGymPackage(package!.id!);
      } else if (package?.id != null) {
        await _repository.updateGymPackage(package!.id!, result.input!);
      } else {
        await _repository.createGymPackage(result.input!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.delete
                ? 'Paket gym berhasil dihapus.'
                : 'Paket gym berhasil disimpan.',
          ),
        ),
      );
      await _loadGymPackages();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isGymSaving = false);
    }
  }

  String _nextPackageCode() {
    var highest = 0;
    for (final package in _gymPackages) {
      final match = RegExp(r'^PKG-(\d+)$').firstMatch(package.packageId);
      final value = int.tryParse(match?.group(1) ?? '');
      if (value != null && value > highest) highest = value;
    }
    return 'PKG-${(highest + 1).toString().padLeft(3, '0')}';
  }

  Widget _buildFnbContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return _LoadError(message: _loadError!, onRetry: _loadFnbItems);
    }
    if (_fnbItems.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Belum ada menu F&B di database.')),
      );
    }
    final query = _searchQuery.toLowerCase();
    final filteredItems = _fnbItems.where((item) {
      final matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.itemId.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          _normalizedCategory(item.category) == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFnbToolbar(filteredItems.length),
        const SizedBox(height: 16),
        if (filteredItems.isEmpty)
          _buildEmptyFilterState()
        else
          _CardGrid(
            minCardWidth: 280,
            cardHeight: 196,
            children: filteredItems
                .map(
                  (item) => _FnbCard(
                    item: item,
                    imageUrl: _repository.resolveImageUrl(item.imagePath),
                    selected: _showEditor && _editingItem?.id == item.id,
                    onEdit: () => _openFnbForm(item),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildFnbToolbar(int resultCount) {
    const categories = [
      'Semua',
      'Makanan',
      'Minuman',
      'Appetizer',
      'Additional',
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value.trim()),
            decoration: InputDecoration(
              hintText: 'Cari nama, kode, atau deskripsi menu...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AdminMasterDataScreen._accent,
              ),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFD7DEE8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: AdminMasterDataScreen._accent,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 7),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final selected = category == _selectedCategory;
                      final count = category == 'Semua'
                          ? _fnbItems.length
                          : _fnbItems
                                .where(
                                  (item) =>
                                      _normalizedCategory(item.category) ==
                                      category,
                                )
                                .length;
                      return ChoiceChip(
                        label: Text('$category ($count)'),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                        selectedColor: AdminMasterDataScreen._accent,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: selected
                              ? AdminMasterDataScreen._accent
                              : const Color(0xFFD7DEE8),
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF475569),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AdminMasterDataScreen._softAccent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '$resultCount hasil',
                  style: const TextStyle(
                    color: AdminMasterDataScreen._accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 36,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 10),
          const Text(
            'Menu tidak ditemukan',
            style: TextStyle(
              color: AdminMasterDataScreen._text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba kata kunci atau kategori yang berbeda.',
            style: TextStyle(color: AdminMasterDataScreen._muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _resetFnbFilters,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }

  String _normalizedCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'minuman':
      case 'drinks':
      case 'coffee':
        return 'Minuman';
      case 'appetizer':
      case 'snacks':
        return 'Appetizer';
      case 'additional':
        return 'Additional';
      default:
        return 'Makanan';
    }
  }

  void _resetFnbFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'Semua';
    });
  }

  Future<void> _openFnbForm([FoodBeverageItem? item]) async {
    if (MediaQuery.sizeOf(context).width >= 900) {
      setState(() {
        _editingItem = item;
        _showEditor = true;
      });
      return;
    }

    final result = await showDialog<_FnbFormResult>(
      context: context,
      builder: (_) => _FnbFormDialog(
        item: item,
        nextItemId: _nextItemId(),
        existingImageUrl: _repository.resolveImageUrl(item?.imagePath),
      ),
    );
    if (result == null || !mounted) return;

    await _handleFnbResult(result, item);
  }

  Future<void> _handleFnbResult(
    _FnbFormResult result,
    FoodBeverageItem? item,
  ) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      if (result.delete && item?.id != null) {
        await _repository.deleteFnbItem(item!.id!);
      } else {
        var input = result.input!;
        if (result.imageBytes != null && result.imageFileName != null) {
          final path = await _repository.uploadFnbImage(
            bytes: result.imageBytes!,
            filename: result.imageFileName!,
          );
          input = input.copyWith(imagePath: path);
        }
        if (item?.id != null) {
          await _repository.updateFnbItem(item!.id!, input);
        } else {
          await _repository.createFnbItem(input);
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.delete
                ? 'Menu berhasil dihapus.'
                : 'Menu berhasil disimpan.',
          ),
        ),
      );
      await _loadFnbItems();
      _closeEditor();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _closeEditor() {
    if (!mounted) return;
    setState(() {
      _showEditor = false;
      _editingItem = null;
    });
  }

  String _nextItemId() {
    var highest = 0;
    for (final item in _fnbItems) {
      final match = RegExp(r'^FNB-(\d+)$').firstMatch(item.itemId);
      final value = int.tryParse(match?.group(1) ?? '');
      if (value != null && value > highest) highest = value;
    }
    return 'FNB-${(highest + 1).toString().padLeft(3, '0')}';
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
        borderRadius: BorderRadius.circular(14),
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
    required this.onAdd,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onAdd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminMasterDataScreen._surface,
        borderRadius: BorderRadius.circular(14),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AdminMasterDataScreen._accent,
                  size: 19,
                ),
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
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminMasterDataScreen._navy,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
    required this.minCardWidth,
    required this.cardHeight,
  });

  final List<Widget> children;
  final double minCardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final width = constraints.maxWidth;
        final columns = ((width + spacing) / (minCardWidth + spacing))
            .floor()
            .clamp(1, 4);
        final cardWidth = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map(
                (card) =>
                    SizedBox(width: cardWidth, height: cardHeight, child: card),
              )
              .toList(),
        );
      },
    );
  }
}

class _GymPackageCard extends StatelessWidget {
  const _GymPackageCard({required this.package, required this.onEdit});

  final GymPackage package;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isDaily = package.packageType == 'daily';
    final months = _durationInMonths(package.durationInDays);
    final monthlyPrice = isDaily ? package.price : package.price / months;

    return Material(
      color: AdminMasterDataScreen._surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AdminMasterDataScreen._border,
          width: 0.8,
        ),
      ),
      elevation: 1,
      shadowColor: const Color(0x22071A3D),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AdminMasterDataScreen._softAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _packageIcon(isDaily ? 0 : months),
                    color: AdminMasterDataScreen._accent,
                    size: 20,
                  ),
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
                          color: AdminMasterDataScreen._text,
                          fontSize: 14,
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
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _EditButton(onTap: onEdit),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Badge(label: isDaily ? 'HARIAN' : 'MEMBERSHIP'),
                if (!package.isActive) ...[
                  const SizedBox(width: 6),
                  const _Badge(label: 'NONAKTIF'),
                ],
              ],
            ),
            const Spacer(),
            _PackagePrice(
              price: package.price,
              detail: isDaily
                  ? 'sekali masuk'
                  : '${CurrencyUtils.formatCurrencySimple(monthlyPrice)}/bln',
            ),
          ],
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

class _PackagePrice extends StatelessWidget {
  const _PackagePrice({required this.price, required this.detail});

  final double price;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6EBF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              CurrencyUtils.formatCurrencySimple(price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AdminMasterDataScreen._text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            detail,
            maxLines: 1,
            style: const TextStyle(
              color: AdminMasterDataScreen._accent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FnbCard extends StatelessWidget {
  const _FnbCard({
    required this.item,
    required this.imageUrl,
    required this.selected,
    required this.onEdit,
  });

  final FoodBeverageItem item;
  final String imageUrl;
  final bool selected;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final memberPrice = item.memberPrice ?? _memberPrice(item.price);
    final lowStock = item.stock <= 12;

    return Material(
      color: AdminMasterDataScreen._surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? AdminMasterDataScreen._accent
              : AdminMasterDataScreen._border,
          width: selected ? 1.8 : 0.8,
        ),
      ),
      elevation: selected ? 3 : 1,
      shadowColor: const Color(0x22071A3D),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _FnbImage(imageSource: imageUrl),
                const SizedBox(width: 10),
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
                const SizedBox(width: 10),
                _EditButton(onTap: onEdit),
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
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE6EBF2)),
            const Spacer(),
            _PriceRow(
              label: 'Member',
              price: memberPrice,
              color: AdminMasterDataScreen._accent,
              highlighted: true,
            ),
            const SizedBox(height: 7),
            _PriceRow(
              label: 'Non-member',
              price: item.price,
              color: const Color(0xFF475569),
            ),
          ],
        ),
      ),
    );
  }

  String _shortCategory(String category) {
    switch (category.toLowerCase()) {
      case 'minuman':
      case 'drinks':
      case 'coffee':
        return 'MINUMAN';
      case 'appetizer':
      case 'snacks':
        return 'APPETIZER';
      case 'additional':
        return 'ADDITIONAL';
      default:
        return 'MAKANAN';
    }
  }

  double _memberPrice(double nonMemberPrice) {
    return (nonMemberPrice * 0.9 / 1000).round() * 1000;
  }
}

class _FnbImage extends StatelessWidget {
  const _FnbImage({required this.imageSource, this.size = 40});

  final String imageSource;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = imageSource.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: SizedBox(
        width: size,
        height: size,
        child: path.isEmpty
            ? _fallback()
            : path.startsWith('http://') || path.startsWith('https://')
            ? Image.network(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              )
            : Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() {
    return const ColoredBox(
      color: AdminMasterDataScreen._softAccent,
      child: Icon(
        Icons.restaurant_menu_rounded,
        color: AdminMasterDataScreen._accent,
        size: 19,
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Color(0xFFDC2626)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _GymPackageFormResult {
  const _GymPackageFormResult.save(this.input) : delete = false;
  const _GymPackageFormResult.delete() : input = null, delete = true;

  final GymPackageInput? input;
  final bool delete;
}

class _GymPackageFormDialog extends StatefulWidget {
  const _GymPackageFormDialog({
    required this.package,
    required this.nextPackageCode,
  });

  final GymPackage? package;
  final String nextPackageCode;

  @override
  State<_GymPackageFormDialog> createState() =>
      _GymPackageFormDialogState();
}

class _GymPackageFormDialogState extends State<_GymPackageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late String _packageType;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final package = widget.package;
    _codeController = TextEditingController(
      text: package?.packageId ?? widget.nextPackageCode,
    );
    _nameController = TextEditingController(text: package?.name ?? '');
    _descriptionController = TextEditingController(
      text: package?.description ?? '',
    );
    _priceController = TextEditingController(
      text: package == null ? '' : _numberText(package.price),
    );
    _durationController = TextEditingController(
      text: package?.durationInDays.toString() ?? '30',
    );
    _packageType = package?.packageType == 'daily' ? 'daily' : 'membership';
    _isActive = package?.isActive ?? true;
  }

  String _numberText(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.package != null;
    return AlertDialog(
      title: Text(editing ? 'Edit Paket Gym' : 'Tambah Paket Gym'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField(_codeController, 'Kode paket', required: true),
                _textField(_nameController, 'Nama paket', required: true),
                _textField(
                  _descriptionController,
                  'Keterangan',
                  maxLines: 2,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    initialValue: _packageType,
                    decoration: const InputDecoration(
                      labelText: 'Jenis paket',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'membership',
                        child: Text('Membership'),
                      ),
                      DropdownMenuItem(
                        value: 'daily',
                        child: Text('Daily'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _packageType = value;
                        if (value == 'daily') {
                          _durationController.text = '1';
                        }
                      });
                    },
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _numberField(
                        _priceController,
                        'Harga',
                        allowDecimal: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        _durationController,
                        'Durasi (hari)',
                        maxValue: 3650,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SwitchListTile.adaptive(
                    title: const Text(
                      'Paket aktif',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Paket aktif dapat digunakan dalam transaksi',
                    ),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (editing)
          TextButton(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (required && text.isEmpty) return '$label wajib diisi';
          if (label == 'Kode paket' && text.length > 20) {
            return 'Kode maksimal 20 karakter';
          }
          if (label == 'Nama paket' && text.length > 100) {
            return 'Nama maksimal 100 karakter';
          }
          if (label == 'Keterangan' && text.length > 255) {
            return 'Keterangan maksimal 255 karakter';
          }
          return null;
        },
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    bool allowDecimal = false,
    int? maxValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final number = double.tryParse(value?.trim() ?? '');
          if (number == null || number < (allowDecimal ? 0 : 1)) {
            return '$label tidak valid';
          }
          if (!allowDecimal && number != number.roundToDouble()) {
            return 'Harus bilangan bulat';
          }
          if (maxValue != null && number > maxValue) {
            return 'Maksimal $maxValue';
          }
          return null;
        },
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _GymPackageFormResult.save(
        GymPackageInput(
          packageCode: _codeController.text.trim(),
          packageName: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          packageType: _packageType,
          durationDays: int.parse(_durationController.text.trim()),
          isActive: _isActive,
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus paket gym?'),
        content: Text(
          'Paket ${widget.package!.name} akan dihapus dari database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.pop(context, const _GymPackageFormResult.delete());
    }
  }
}

class _FnbFormResult {
  const _FnbFormResult.save(this.input, {this.imageBytes, this.imageFileName})
    : delete = false;
  const _FnbFormResult.delete()
    : input = null,
      imageBytes = null,
      imageFileName = null,
      delete = true;

  final FnbItemInput? input;
  final Uint8List? imageBytes;
  final String? imageFileName;
  final bool delete;
}

class _FnbFormDialog extends StatefulWidget {
  const _FnbFormDialog({
    super.key,
    required this.item,
    required this.nextItemId,
    required this.existingImageUrl,
    this.embedded = false,
    this.isSaving = false,
    this.onClose,
    this.onResult,
  });

  final FoodBeverageItem? item;
  final String nextItemId;
  final String existingImageUrl;
  final bool embedded;
  final bool isSaving;
  final VoidCallback? onClose;
  final ValueChanged<_FnbFormResult>? onResult;

  @override
  State<_FnbFormDialog> createState() => _FnbFormDialogState();
}

class _FnbFormDialogState extends State<_FnbFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemIdController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _selectedCategory;
  late final TextEditingController _memberPriceController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late bool _isActive;
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _itemIdController = TextEditingController(
      text: item?.itemId ?? widget.nextItemId,
    );
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _selectedCategory = _normalizeCategory(item?.category);
    _memberPriceController = TextEditingController(
      text: _numberText(item?.memberPrice),
    );
    _priceController = TextEditingController(text: _numberText(item?.price));
    _stockController = TextEditingController(text: '${item?.stock ?? 0}');
    _isActive = item?.isActive ?? true;
  }

  String _numberText(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  void dispose() {
    _itemIdController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _memberPriceController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.item != null;
    if (widget.embedded) {
      return Material(
        color: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x22071A3D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AdminMasterDataScreen._border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _editorHeader(editing),
            Expanded(child: _formContent(const EdgeInsets.all(18))),
            _editorFooter(editing),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Text(editing ? 'Edit Menu F&B' : 'Tambah Menu F&B'),
      content: SizedBox(
        width: 540,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
          child: _formContent(EdgeInsets.zero),
        ),
      ),
      actions: [
        if (editing)
          TextButton(
            onPressed: widget.isSaving ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        TextButton(
          onPressed: widget.isSaving ? null : _close,
          child: const Text('Batal'),
        ),
        _saveButton(),
      ],
    );
  }

  Widget _editorHeader(bool editing) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071A3D), Color(0xFF0B3A7A)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              editing ? Icons.edit_rounded : Icons.add_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editing ? 'Edit Produk F&B' : 'Tambah Produk F&B',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  editing ? widget.item!.name : 'Lengkapi informasi menu baru',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFDCEBFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Tutup editor',
            onPressed: widget.isSaving ? null : _close,
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _formContent(EdgeInsets padding) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_itemIdController, 'Kode menu', required: true),
            _field(_nameController, 'Nama menu', required: true),
            _categoryDropdown(),
            _field(_descriptionController, 'Deskripsi', maxLines: 2),
            Row(
              children: [
                Expanded(
                  child: _numberField(_memberPriceController, 'Harga member'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _numberField(_priceController, 'Harga non-member'),
                ),
              ],
            ),
            _numberField(_stockController, 'Stok'),
            _imagePicker(),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SwitchListTile.adaptive(
                title: const Text(
                  'Menu aktif',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Tampilkan menu pada transaksi kasir'),
                value: _isActive,
                onChanged: widget.isSaving
                    ? null
                    : (value) => setState(() => _isActive = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editorFooter(bool editing) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (editing)
            TextButton.icon(
              onPressed: widget.isSaving ? null : _delete,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Hapus'),
            ),
          const Spacer(),
          TextButton(
            onPressed: widget.isSaving ? null : _close,
            child: const Text('Batal'),
          ),
          const SizedBox(width: 8),
          _saveButton(),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return FilledButton.icon(
      onPressed: widget.isSaving ? null : _save,
      style: FilledButton.styleFrom(
        backgroundColor: AdminMasterDataScreen._navy,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
      icon: widget.isSaving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.save_rounded, size: 18),
      label: Text(widget.isSaving ? 'Menyimpan...' : 'Simpan'),
    );
  }

  void _close() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.pop(context);
    }
  }

  void _finish(_FnbFormResult result) {
    if (widget.onResult != null) {
      widget.onResult!(result);
    } else {
      Navigator.pop(context, result);
    }
  }

  static const List<String> _categoryOptions = [
    'Makanan',
    'Minuman',
    'Appetizer',
    'Additional',
  ];

  String _normalizeCategory(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    switch (value) {
      case 'minuman':
      case 'drinks':
      case 'coffee':
        return 'Minuman';
      case 'appetizer':
      case 'snacks':
        return 'Appetizer';
      case 'additional':
        return 'Additional';
      default:
        return 'Makanan';
    }
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        decoration: const InputDecoration(
          labelText: 'Kategori',
          border: OutlineInputBorder(),
        ),
        items: _categoryOptions
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: widget.isSaving
            ? null
            : (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !widget.isSaving,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                  ? '$label wajib diisi'
                  : null
            : null,
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !widget.isSaving,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final number = double.tryParse(value?.trim() ?? '');
          if (number == null || number < 0) return '$label tidak valid';
          return null;
        },
      ),
    );
  }

  Widget _imagePicker() {
    final hasExistingImage = widget.existingImageUrl.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD7DEE8)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              width: 72,
              height: 72,
              child: _pickedImageBytes != null
                  ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                  : hasExistingImage
                  ? _FnbImage(imageSource: widget.existingImageUrl, size: 72)
                  : const ColoredBox(
                      color: Color(0xFFE8F4FF),
                      child: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: AdminMasterDataScreen._accent,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pickedImageName ??
                      (hasExistingImage
                          ? 'Gambar menu saat ini'
                          : 'Belum ada gambar'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'JPG, PNG, atau WEBP. Maksimal 5 MB.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isPickingImage || widget.isSaving
                      ? null
                      : _pickImage,
                  icon: _isPickingImage
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_rounded, size: 18),
                  label: Text(
                    _pickedImageBytes == null && !hasExistingImage
                        ? 'Pilih Gambar'
                        : 'Ganti Gambar',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran gambar maksimal 5 MB.')),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageName = file.name;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $error')));
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.item == null && _pickedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar menu wajib dipilih.')),
      );
      return;
    }
    final memberPrice = double.parse(_memberPriceController.text.trim());
    final price = double.parse(_priceController.text.trim());
    final stockValue = double.parse(_stockController.text.trim());
    if (memberPrice > price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga member tidak boleh melebihi non-member.'),
        ),
      );
      return;
    }
    if (stockValue != stockValue.roundToDouble()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok harus berupa bilangan bulat.')),
      );
      return;
    }
    _finish(
      _FnbFormResult.save(
        FnbItemInput(
          itemId: _itemIdController.text.trim(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          memberPrice: memberPrice,
          price: price,
          stock: stockValue.toInt(),
          imagePath: widget.item?.imagePath ?? '',
          isActive: _isActive,
        ),
        imageBytes: _pickedImageBytes,
        imageFileName: _pickedImageName,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus menu?'),
        content: Text('Menu ${widget.item!.name} akan dihapus dari database.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _finish(const _FnbFormResult.delete());
    }
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
  const _EditButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Icon(
          Icons.edit_rounded,
          size: 16,
          color: AdminMasterDataScreen._navy,
        ),
      ),
    );
  }
}
