import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bahan_makanan.dart';
import '../providers/bahan_provider.dart';
import '../widgets/bahan_card.dart';
import 'edit_food_screen.dart';
import 'food_detail_screen.dart';

/// Screen: FoodListScreen (Tab Daftar Bahan)
/// Menampilkan katalog bahan makanan sesuai mockup:
/// - Custom Header (Logo daun + FoodGuard & Search Icon responsif)
/// - Search Bar Kapsul (#EEF2EC) dengan auto-focus
/// - Baris Filter Chip Kapsul (Semua, Sayur, Buah, Daging)
/// - Kartu Item Bahan dengan status kapsul interaktif
/// - Empty state ilustrasi kotak terbuka hijau + tombol "Reset Filter"
class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<Map<String, dynamic>> _catalogCategories = [
    {'name': 'Semua', 'icon': Icons.grid_view_rounded, 'color': const Color(0xFF2E7D32)},
    {'name': 'Sayur', 'icon': Icons.eco_rounded, 'color': const Color(0xFF2E7D32)},
    {'name': 'Buah', 'icon': Icons.apple_rounded, 'color': const Color(0xFFE53935)},
    {'name': 'Daging & Olahan', 'icon': Icons.restaurant_rounded, 'color': const Color(0xFFD84315)},
    {'name': 'Produk Susu', 'icon': Icons.local_drink_rounded, 'color': const Color(0xFF0284C7)},
    {'name': 'Bahan Pokok', 'icon': Icons.bakery_dining_rounded, 'color': const Color(0xFFB57C34)},
    {'name': 'Minuman', 'icon': Icons.local_cafe_rounded, 'color': const Color(0xFF00897B)},
    {'name': 'Lainnya', 'icon': Icons.more_horiz_rounded, 'color': const Color(0xFF64748B)},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _navigateToDetail(BahanMakanan bahan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(bahan: bahan),
      ),
    );
  }

  void _navigateToEdit(BahanMakanan bahan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFoodScreen(bahan: bahan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Custom Header: Logo daun + FoodGuard di kiri, Search Icon di kanan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Color(0xFF2E7D32),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'FoodGuard',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  // Tombol Search di kanan atas: Tap langsung fokus ke input pencarian
                  GestureDetector(
                    onTap: () {
                      _searchFocusNode.requestFocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF1E293B),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Search Bar Kapsul (#EEF2EC)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2EC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (val) {
                    context.read<BahanProvider>().search(val);
                    setState(() {});
                  },
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintText: 'Cari bahan makanan...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF64748B)),
                            onPressed: () {
                              _searchController.clear();
                              context.read<BahanProvider>().search('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Baris Filter Chip Kapsul Horizontal (Semua, Sayur, Buah, Daging)
            Consumer<BahanProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    scrollDirection: Axis.horizontal,
                    itemCount: _catalogCategories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _catalogCategories[index];
                      final name = cat['name'] as String;
                      final icon = cat['icon'] as IconData;
                      final isSelected = provider.filterKategori == name ||
                          (name != 'Semua' &&
                              provider.filterKategori != 'Semua' &&
                              (name.toLowerCase().contains(provider.filterKategori.toLowerCase()) ||
                                  provider.filterKategori.toLowerCase().contains(name.toLowerCase())));

                      return GestureDetector(
                        onTap: () {
                          provider.filter(name);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 16,
                                color: isSelected ? Colors.white : (cat['color'] as Color),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                name,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Daftar Bahan Makanan
            Expanded(
              child: Consumer<BahanProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.bahanList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    );
                  }

                  final displayList = provider.filteredBahanList;

                  if (displayList.isEmpty) {
                    return _buildEmptyState(provider);
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF2E7D32),
                    onRefresh: () => provider.loadBahan(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isWide = constraints.maxWidth >= 600;
                        if (isWide) {
                          // WIDE: Grid 2 kolom untuk tablet / landscape
                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 4, bottom: 90),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.4,
                              crossAxisSpacing: 0,
                              mainAxisSpacing: 0,
                            ),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final bahan = displayList[index];
                              return BahanCard(
                                bahan: bahan,
                                onTap: () => _navigateToDetail(bahan),
                                onEdit: () => _navigateToEdit(bahan),
                              );
                            },
                          );
                        }
                        // COMPACT: ListView 1 kolom untuk mobile
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 4, bottom: 90),
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final bahan = displayList[index];
                            return BahanCard(
                              bahan: bahan,
                              onTap: () => _navigateToDetail(bahan),
                              onEdit: () => _navigateToEdit(bahan),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty State: Ilustrasi Kotak Terbuka Hijau + Tombol Reset Filter
  Widget _buildEmptyState(BahanProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Icon(
                    Icons.all_inbox_rounded,
                    size: 52,
                    color: Color(0xFF2E7D32),
                  ),
                  Positioned(
                    top: 18,
                    right: 22,
                    child: Icon(
                      Icons.spa_rounded,
                      size: 20,
                      color: Color(0xFF81C784),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Tidak Ditemukan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba ubah kata kunci atau filter yang dipilih.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            InkWell(
              onTap: () {
                _searchController.clear();
                provider.resetFilter();
                setState(() {});
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Reset Filter',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
