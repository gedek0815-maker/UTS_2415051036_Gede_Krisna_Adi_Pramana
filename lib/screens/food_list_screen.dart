import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/bahan_makanan.dart';
import '../providers/bahan_provider.dart';
import '../widgets/bahan_card.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/kategori_chip.dart';
import 'edit_food_screen.dart';
import 'food_detail_screen.dart';

/// Screen: FoodListScreen
/// Menampilkan daftar bahan makanan dengan Responsive Layout menggunakan LayoutBuilder:
/// - Layar Compact (< 600px): ListView (vertikal single-column)
/// - Layar Wide (≥ 600px): GridView (multi-column responsif)
/// Dilengkapi fitur pencarian real-time dan penyaringan kategori.
class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _kategoriList = [
    'Semua',
    'Sayur',
    'Buah',
    'Daging',
    'Susu',
    'Bumbu',
    'Lainnya',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Search & Filter Bar
            _buildSearchAndFilterHeader(),

            // Konten Utama Responsif
            Expanded(
              child: Consumer<BahanProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.bahanList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (provider.errorMessage != null && provider.bahanList.isEmpty) {
                    return EmptyStateWidget.error(
                      errorMessage: provider.errorMessage!,
                      onRetry: () => provider.loadBahan(),
                    );
                  }

                  final displayList = provider.filteredBahanList;

                  if (displayList.isEmpty) {
                    return EmptyStateWidget.searchEmpty(
                      query: provider.searchQuery,
                      onReset: () {
                        _searchController.clear();
                        provider.resetFilter();
                      },
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () => provider.loadBahan(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informasi Jumlah Data & Mode Tampilan
                        _buildInfoBar(displayList.length),

                        // LayoutBuilder: Menentukan ListView (Compact) atau GridView (Wide)
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth >= 600;

                              if (isWide) {
                                return _buildWideGridView(displayList, constraints.maxWidth);
                              } else {
                                return _buildCompactListView(displayList);
                              }
                            },
                          ),
                        ),
                      ],
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

  /// Header Pencarian dan Filter Kategori
  Widget _buildSearchAndFilterHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          // Input Field Pencarian
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari bahan makanan atau catatan...',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        context.read<BahanProvider>().search('');
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onChanged: (value) {
              context.read<BahanProvider>().search(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 10),

          // Horizontal Filter Chips
          Consumer<BahanProvider>(
            builder: (context, provider, _) {
              return SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _kategoriList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final kategori = _kategoriList[index];
                    final isSelected = provider.filterKategori == kategori;
                    return KategoriChip(
                      label: kategori,
                      isSelected: isSelected,
                      onSelected: (_) {
                        provider.filter(kategori);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Banner informasi jumlah bahan dan status responsif
  Widget _buildInfoBar(int totalData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Menampilkan $totalData bahan makanan',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MediaQuery.of(context).size.width >= 600
                          ? Icons.grid_view_rounded
                          : Icons.view_agenda_outlined,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      MediaQuery.of(context).size.width >= 600 ? 'Wide (Grid)' : 'Compact (List)',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// MODE 1: Compact Layout (< 600px) menggunakan ListView.builder
  Widget _buildCompactListView(List<BahanMakanan> items) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final bahan = items[index];
        return BahanCard(
          bahan: bahan,
          isGrid: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(bahan: bahan),
              ),
            );
          },
          onEdit: () => _navigateToEdit(bahan),
          onDelete: () => DeleteConfirmationDialog.show(context, bahan: bahan),
        );
      },
    );
  }

  /// MODE 2: Wide Layout (≥ 600px) menggunakan GridView.builder
  Widget _buildWideGridView(List<BahanMakanan> items, double maxWidth) {
    // 2 kolom untuk tablet (600 - 900px), 3 kolom untuk desktop (> 900px)
    final crossAxisCount = maxWidth >= 900 ? 3 : 2;

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final bahan = items[index];
        return BahanCard(
          bahan: bahan,
          isGrid: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(bahan: bahan),
              ),
            );
          },
          onEdit: () => _navigateToEdit(bahan),
          onDelete: () => DeleteConfirmationDialog.show(context, bahan: bahan),
        );
      },
    );
  }
}

