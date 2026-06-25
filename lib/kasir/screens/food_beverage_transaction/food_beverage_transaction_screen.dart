import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/food_beverage_transaction_controller.dart';
import '../../models/index.dart';
import '../../utils/utils.dart';

class FoodBeverageTransactionScreen extends StatefulWidget {
  const FoodBeverageTransactionScreen({super.key});

  @override
  State<FoodBeverageTransactionScreen> createState() =>
      _FoodBeverageTransactionScreenState();
}

class _FoodBeverageTransactionScreenState
    extends State<FoodBeverageTransactionScreen> {
  static const _primary = Color(0xFF1D4ED8);
  static const _dark = Color(0xFF071A3D);
  static const _background = Color(0xFFF5F7FB);

  final _searchController = TextEditingController();
  late final FoodBeverageTransactionController _controller;
  String _query = '';
  String _selectedCategory = 'Semua';
  bool _showCartPanel = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<FoodBeverageTransactionController>()
        ? Get.find<FoodBeverageTransactionController>()
        : Get.put(FoodBeverageTransactionController());
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
        backgroundColor: _dark,
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
              'Food & Beverage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              'Pilih menu untuk transaksi baru',
              style: TextStyle(
                color: Color(0xFFE8F4FF),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton.filled(
                tooltip: _showCartPanel ? 'Tutup keranjang' : 'Lihat keranjang',
                style: IconButton.styleFrom(
                  foregroundColor: _dark,
                  backgroundColor: const Color(0xFFFFC857),
                  minimumSize: const Size(44, 44),
                ),
                onPressed: () => _toggleCart(context),
                icon: Badge(
                  isLabelVisible: _controller.cartItems.isNotEmpty,
                  label: Text('${_totalQuantity()}'),
                  backgroundColor: const Color(0xFFDC2626),
                  textColor: Colors.white,
                  child: Icon(
                    _showCartPanel
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
          if (_controller.isLoading.value && _controller.items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          final categories = <String>{
            'Semua',
            ..._controller.items.map((item) => item.category),
          }.toList();
          final filteredItems = _controller.items.where((item) {
            final keyword = _query.toLowerCase();
            final matchesQuery =
                keyword.isEmpty ||
                item.name.toLowerCase().contains(keyword) ||
                item.description.toLowerCase().contains(keyword);
            final matchesCategory =
                _selectedCategory == 'Semua' ||
                item.category == _selectedCategory;
            return matchesQuery && matchesCategory;
          }).toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final useSplit = _showCartPanel && constraints.maxWidth >= 760;
              final catalog = _buildCatalog(
                categories,
                filteredItems,
                showBottomCartBar: !useSplit,
              );

              if (!useSplit) return catalog;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      offset: const Offset(-0.02, 0),
                      child: catalog,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      offset: Offset.zero,
                      child: _buildCartPanel(),
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
      bottomSheet: Obx(() {
        final splitVisible =
            _showCartPanel && MediaQuery.sizeOf(context).width >= 760;
        return _controller.cartItems.isEmpty || splitVisible
            ? const SizedBox.shrink()
            : _buildCartBar(context);
      }),
    );
  }

  Widget _buildCatalog(
    List<String> categories,
    List<FoodBeverageItem> filteredItems, {
    required bool showBottomCartBar,
  }) {
    return Obx(() {
      final hasCartItems = _controller.cartItems.isNotEmpty;

      return Column(
        children: [
          _buildToolbar(categories),
          Expanded(
            child: filteredItems.isEmpty
                ? _buildEmptyState()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columnCount = constraints.maxWidth >= 900
                          ? 3
                          : constraints.maxWidth >= 580
                          ? 2
                          : 1;
                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          showBottomCartBar && hasCartItems ? 104 : 20,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 188,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) => _ProductCard(
                          item: filteredItems[index],
                          quantity: _quantityFor(filteredItems[index]),
                          onAdd: () =>
                              _controller.addToCart(filteredItems[index]),
                          onRemove: () => _decreaseItem(filteredItems[index]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildToolbar(List<String> categories) {
    return Container(
      color: _background,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              hintText: 'Cari makanan atau minuman...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: _primary),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(_categoryLabel(category)),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = category),
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: _primary,
                  side: BorderSide(
                    color: selected ? _primary : const Color(0xFFE2E8F0),
                  ),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 34,
                color: _primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Menu tidak ditemukan',
              style: TextStyle(
                color: _dark,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba kata kunci atau kategori yang berbeda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCart(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 760) {
      setState(() => _showCartPanel = !_showCartPanel);
      return;
    }
    _showCart(context);
  }

  Widget _buildCartPanel() {
    return Obx(() => _buildCartPanelContent());
  }

  Widget _buildCartPanelContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14071A3D),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 10, 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Badge(
                      isLabelVisible: _controller.cartItems.isNotEmpty,
                      label: Text('${_totalQuantity()}'),
                      backgroundColor: const Color(0xFFDC2626),
                      child: const Icon(
                        Icons.shopping_cart_rounded,
                        color: _primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesanan Anda',
                        style: TextStyle(
                          color: _dark,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Periksa item sebelum pembayaran',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _showCartPanel = false),
                  tooltip: 'Tutup keranjang',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          _buildCustomerSelector(),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: _controller.cartItems.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 42,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Keranjang masih kosong',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _dark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Klik menu di sebelah kiri untuk menambahkan pesanan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _controller.cartItems.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 22, color: Color(0xFFE2E8F0)),
                    itemBuilder: (context, index) {
                      final cartItem = _controller.cartItems[index];
                      return _CartItemRow(
                        cartItem: cartItem,
                        onAdd: () {
                          final product = _controller.items.firstWhere(
                            (item) => item.id == cartItem.itemId,
                          );
                          _controller.addToCart(product);
                        },
                        onRemove: () => _controller.updateCartItemQuantity(
                          cartItem.itemId,
                          cartItem.quantity - 1,
                        ),
                      );
                    },
                  ),
          ),
          if (_controller.cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _controller.clearCart,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Kosongkan',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total pembayaran',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            CurrencyUtils.formatCurrencySimple(
                              _controller.totalAmount.value,
                            ),
                            style: const TextStyle(
                              color: _dark,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _continuePayment,
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text(
                        'Lanjut ke Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector() {
    final isMember = _controller.isMemberCustomer.value;
    final selectedMember = _controller.selectedMember.value;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipe Pembeli',
            style: TextStyle(
              color: _dark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.person_outline_rounded),
                  label: Text('Non-member'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.workspace_premium_outlined),
                  label: Text('Member'),
                ),
              ],
              selected: {isMember},
              onSelectionChanged: (selection) =>
                  _controller.setMemberCustomer(selection.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: const WidgetStatePropertyAll(
                  TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          if (isMember) ...[
            const SizedBox(height: 10),
            Autocomplete<Member>(
              initialValue: TextEditingValue(
                text: selectedMember == null
                    ? ''
                    : '${selectedMember.name} (${selectedMember.memberId})',
              ),
              displayStringForOption: (member) =>
                  '${member.name} (${member.memberId})',
              optionsBuilder: (value) {
                final query = value.text.trim().toLowerCase();
                if (query.isEmpty) return const Iterable<Member>.empty();
                return _controller.members.where(
                  (member) =>
                      member.name.toLowerCase().contains(query) ||
                      member.memberId.toLowerCase().contains(query) ||
                      member.phoneNumber.contains(query),
                );
              },
              onSelected: _controller.selectMember,
              fieldViewBuilder: (context, textController, focusNode, _) {
                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  onChanged: (value) {
                    final selectedLabel = selectedMember == null
                        ? ''
                        : '${selectedMember.name} (${selectedMember.memberId})';
                    if (selectedMember != null && value != selectedLabel) {
                      _controller.selectedMember.value = null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Pilih atau cari member',
                    hintText: 'Nama, ID member, atau nomor telepon',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: _primary,
                      size: 20,
                    ),
                    suffixIcon: selectedMember == null
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _primary, width: 1.5),
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
                      constraints: const BoxConstraints(
                        maxWidth: 440,
                        maxHeight: 280,
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: members.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE8F4FF),
                              foregroundColor: _primary,
                              child: Text(
                                member.name.isEmpty
                                    ? '?'
                                    : member.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            title: Text(
                              member.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              '${member.memberId} | ${member.phoneNumber}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => onSelected(member),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            const Text(
              'Harga member hemat 10% dari harga normal.',
              style: TextStyle(
                color: Color(0xFF15803D),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _continuePayment() {
    if (_controller.isMemberCustomer.value &&
        _controller.selectedMember.value == null) {
      Get.snackbar('Pilih Member', 'Pilih nama member sebelum pembayaran.');
      return;
    }
    Get.snackbar('Pratinjau UI', 'Pembayaran belum diaktifkan.');
  }

  Widget _buildCartBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071A3D), Color(0xFF0B3A7A), Color(0xFF155E9F)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330F2927),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Badge(
                  label: Text('${_totalQuantity()}'),
                  backgroundColor: const Color(0xFFFFC857),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_controller.cartItems.length} jenis item',
                    style: const TextStyle(
                      color: Color(0xFFE8F4FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyUtils.formatCurrencySimple(
                      _controller.totalAmount.value,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => _toggleCart(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFC857),
                foregroundColor: const Color(0xFF3D2A00),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Pesanan',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCart(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Obx(
        () => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.78,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pesanan Anda',
                              style: TextStyle(
                                color: _dark,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Periksa kembali sebelum pembayaran',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _controller.clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Kosongkan',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _buildCustomerSelector(),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                Flexible(
                  child: _controller.cartItems.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('Keranjang sudah kosong'),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(20),
                          itemCount: _controller.cartItems.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 24,
                            color: Color(0xFFE2E8F0),
                          ),
                          itemBuilder: (context, index) {
                            final cartItem = _controller.cartItems[index];
                            return _CartItemRow(
                              cartItem: cartItem,
                              onAdd: () {
                                final product = _controller.items.firstWhere(
                                  (item) => item.id == cartItem.itemId,
                                );
                                _controller.addToCart(product);
                              },
                              onRemove: () =>
                                  _controller.updateCartItemQuantity(
                                    cartItem.itemId,
                                    cartItem.quantity - 1,
                                  ),
                            );
                          },
                        ),
                ),
                if (_controller.cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              CurrencyUtils.formatCurrencySimple(
                                _controller.totalAmount.value,
                              ),
                              style: const TextStyle(
                                color: _dark,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              if (_controller.isMemberCustomer.value &&
                                  _controller.selectedMember.value == null) {
                                Get.snackbar(
                                  'Pilih Member',
                                  'Pilih nama member sebelum pembayaran.',
                                );
                                return;
                              }
                              Navigator.pop(context);
                              _continuePayment();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: _primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.payments_outlined),
                            label: const Text(
                              'Lanjut ke Pembayaran',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _quantityFor(FoodBeverageItem item) {
    final index = _controller.cartItems.indexWhere(
      (cartItem) => cartItem.itemId == item.id,
    );
    return index == -1 ? 0 : _controller.cartItems[index].quantity;
  }

  int _totalQuantity() =>
      _controller.cartItems.fold(0, (total, item) => total + item.quantity);

  void _decreaseItem(FoodBeverageItem item) {
    final quantity = _quantityFor(item);
    if (quantity > 0) {
      _controller.updateCartItemQuantity(item.id ?? 0, quantity - 1);
    }
  }

  String _categoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'minuman':
      case 'drinks':
      case 'coffee':
        return 'Minuman';
      case 'appetizer':
      case 'snacks':
        return 'Appetizer';
      case 'additional':
        return 'Additional';
      case 'makanan':
      case 'meals':
        return 'Makanan';
      default:
        return category;
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final FoodBeverageItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1D4ED8);
    const dark = Color(0xFF111827);
    final memberPrice = _memberPrice(item.price);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      elevation: quantity > 0 ? 2 : 0,
      shadowColor: const Color(0x1A1D4ED8),
      child: InkWell(
        onTap: onAdd,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: quantity > 0
                  ? const Color(0xFF60A5FA)
                  : const Color(0xFFDDE3EC),
              width: quantity > 0 ? 1.5 : 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageWidth = (constraints.maxWidth * 0.40).clamp(
                112.0,
                164.0,
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: imageWidth,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          _imageForItem(item),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xD9111827),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _shortCategory(item.category),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: dark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              if (quantity > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F4FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${quantity}x',
                                    style: const TextStyle(
                                      color: primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10,
                              height: 1.35,
                            ),
                          ),
                          const Spacer(),
                          _PriceRow(
                            label: 'Member',
                            price: memberPrice,
                            color: primary,
                            highlighted: true,
                          ),
                          const SizedBox(height: 4),
                          _PriceRow(
                            label: 'Non-member',
                            price: item.price,
                            color: const Color(0xFF475569),
                          ),
                          const SizedBox(height: 8),
                          if (quantity == 0)
                            SizedBox(
                              width: double.infinity,
                              height: 34,
                              child: FilledButton.icon(
                                onPressed: onAdd,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF071A3D),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 17),
                                label: const Text(
                                  'Tambah',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 34,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  _QuantityButton(
                                    icon: Icons.remove_rounded,
                                    onPressed: onRemove,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '$quantity',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: dark,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  _QuantityButton(
                                    icon: Icons.add_rounded,
                                    onPressed: onAdd,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _imageForItem(FoodBeverageItem item) {
    if (item.itemId == 'FNB-001' || item.itemId == 'FNB-004') {
      return 'assets/images/fnb/protein-shake.png';
    }
    switch (item.category.toLowerCase()) {
      case 'minuman':
      case 'drinks':
      case 'coffee':
        return 'assets/images/fnb/cold-drinks.png';
      case 'appetizer':
      case 'snacks':
      case 'additional':
        return 'assets/images/fnb/healthy-snacks.png';
      default:
        return 'assets/images/fnb/chicken-meal.png';
    }
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
          width: 70,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: highlighted
                ? const Color(0xFFE8F4FF)
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
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.cartItem,
    required this.onAdd,
    required this.onRemove,
  });

  final CartItem cartItem;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.restaurant_rounded, color: Color(0xFF1D4ED8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cartItem.itemName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                CurrencyUtils.formatCurrencySimple(
                  cartItem.price * cartItem.quantity,
                ),
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantityButton(
                icon: cartItem.quantity == 1
                    ? Icons.delete_outline_rounded
                    : Icons.remove_rounded,
                onPressed: onRemove,
              ),
              SizedBox(
                width: 30,
                child: Text(
                  '${cartItem.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              _QuantityButton(icon: Icons.add_rounded, onPressed: onAdd),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 18),
      color: const Color(0xFF1D4ED8),
      disabledColor: const Color(0xFFCBD5E1),
    );
  }
}
