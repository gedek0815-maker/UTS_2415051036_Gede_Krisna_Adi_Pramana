import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/bahan_makanan.dart';
import '../providers/bahan_provider.dart';
import '../widgets/bahan_card.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/kategori_chip.dart';
import 'add_food_screen.dart';
import 'barcode_scanner_screen.dart';
import 'edit_food_screen.dart';
import 'food_detail_screen.dart';
import 'food_list_screen.dart';
import 'profile_screen.dart';

/// Screen utama: HomeScreen Dashboard
/// Menampilkan ringkasan inventaris (summary cards), status bahan segera olah,
/// filter kategori cepat, dan BottomNavigationBar sebagai navigasi utama.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
  void initState() {
    super.initState();
    // Memuat data saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BahanProvider>().loadBahan();
    });
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

  Future<void> _openBarcodeScanner() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
    if (barcode != null && barcode.isNotEmpty && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddFoodScreen(initialBarcode: barcode),
        ),
      );
    }
  }

  void _updateStatus(BahanMakanan bahan, String newStatus) async {
    final success = await context.read<BahanProvider>().updateStatusBahan(bahan.id, newStatus);
    if (success && mounted) {
      final label = newStatus == 'dikonsumsi'
          ? 'ditandai telah dikonsumsi'
          : newStatus == 'dibuang'
              ? 'ditandai dibuang (soft delete)'
              : 'dipulihkan menjadi tersedia';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${bahan.nama} $label.'),
          backgroundColor: newStatus == 'dikonsumsi'
              ? AppColors.safe
              : newStatus == 'dibuang'
                  ? AppColors.warning
                  : AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildCurrentTab(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFoodScreen(),
            ),
          );
        },
        tooltip: 'Tambah Bahan',
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// AppBar dengan branding FoodGuard
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco_rounded, size: 22, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'FoodGuard',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 19,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded),
          tooltip: 'Scan Barcode',
          onPressed: _openBarcodeScanner,
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Segarkan Data',
          onPressed: () {
            context.read<BahanProvider>().loadBahan();
          },
        ),
      ],
    );
  }

  /// Menampilkan konten berdasarkan tab BottomNavigationBar yang aktif
  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return const FoodListScreen();
      case 2:
        return const ProfileScreen();
      default:
        return _buildDashboardTab();
    }
  }

  /// TAB 0: Dashboard Utama
  Widget _buildDashboardTab() {
    return Consumer<BahanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.bahanList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Memuat data bahan makanan...',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.errorMessage != null && provider.bahanList.isEmpty) {
          return EmptyStateWidget.error(
            errorMessage: 'Gagal memuat inventaris: ${provider.errorMessage}',
            onRetry: () => provider.loadBahan(),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => provider.loadBahan(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Sambutan
                _buildWelcomeHeader(),

                // Summary Cards (Total, Hampir Expired, Expired, Aman)
                _buildSummarySection(provider),

                const SizedBox(height: 16),

                // Baris Filter Kategori Cepat
                _buildKategoriFilterSection(provider),

                const SizedBox(height: 20),

                // Bagian: Perlu Diolah Segera (Hampir Expired)
                _buildUrgentSection(provider),

                const SizedBox(height: 20),

                // Bagian: Bahan Makanan Tersimpan (Preview Ringkas)
                _buildRecentItemsSection(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Header Sambutan
  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Pantau & cegah bahan makanan terbuang sia-sia.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bagian Summary Cards
  Widget _buildSummarySection(BahanProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Inventaris',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Card Total Bahan
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Bahan',
                  count: provider.totalBahan.toString(),
                  icon: Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  bgColor: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              // Card Hampir Expired (0-3 Hari)
              Expanded(
                child: _buildSummaryCard(
                  title: 'Hampir Expired',
                  count: provider.totalHampirExpired.toString(),
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  bgColor: AppColors.dangerLight,
                  subtitle: '≤ 3 hari lagi',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Card Bahan Aman (> 7 Hari)
              Expanded(
                child: _buildSummaryCard(
                  title: 'Kondisi Aman',
                  count: provider.totalAman.toString(),
                  icon: Icons.verified_rounded,
                  color: AppColors.safe,
                  bgColor: AppColors.safeLight,
                  subtitle: '> 7 hari',
                ),
              ),
              const SizedBox(width: 12),
              // Card Sudah Expired
              Expanded(
                child: _buildSummaryCard(
                  title: 'Kadaluarsa',
                  count: provider.totalExpired.toString(),
                  icon: Icons.cancel_outlined,
                  color: AppColors.expired,
                  bgColor: AppColors.expiredLight,
                  subtitle: 'Perlu dibuang',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Desain Individual Summary Card
  Widget _buildSummaryCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bgColor,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              Text(
                count,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Bagian Filter Kategori Cepat
  Widget _buildKategoriFilterSection(BahanProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Kategori Bahan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _kategoriList.length,
            separatorBuilder: (_, unused) => const SizedBox(width: 8),
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
        ),
      ],
    );
  }

  /// Bagian: Bahan yang Perlu Segera Diolah
  Widget _buildUrgentSection(BahanProvider provider) {
    final urgentList = provider.bahanList
        .where((b) => b.isHampirExpired || b.isExpired)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.alarm_on_rounded, size: 18, color: AppColors.danger),
                  SizedBox(width: 6),
                  Text(
                    'Segera Olah!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              Text(
                '${urgentList.length} bahan',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (urgentList.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.safeLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.safe.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.safe, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hebat! Tidak ada bahan makanan yang mendekati kadaluarsa.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.safe,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...urgentList.take(3).map(
                (bahan) => BahanCard(
                  bahan: bahan,
                  onTap: () => _navigateToDetail(bahan),
                  onEdit: () => _navigateToEdit(bahan),
                  onDelete: () => DeleteConfirmationDialog.show(context, bahan: bahan),
                  onStatusChange: (status) => _updateStatus(bahan, status),
                ),
              ),
      ],
    );
  }

  /// Bagian: Daftar Preview Semua Bahan Terakhir
  Widget _buildRecentItemsSection(BahanProvider provider) {
    final displayList = provider.filteredBahanList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Bahan (${provider.filterKategori})',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (displayList.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() => _currentIndex = 1);
                  },
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (displayList.isEmpty)
          if (provider.bahanList.isEmpty)
            EmptyStateWidget(
              icon: Icons.kitchen_outlined,
              title: 'Belum Ada Bahan Makanan',
              message: 'Inventaris Anda masih kosong. Mulai tambahkan bahan makanan untuk memantau masa kedaluwarsanya.',
              buttonText: 'Tambah Bahan Makanan',
              onButtonPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddFoodScreen()),
                );
              },
            )
          else
            EmptyStateWidget.searchEmpty(
              query: provider.filterKategori,
              onReset: () => provider.filter('Semua'),
            )
        else
          ...displayList.take(5).map(
                (bahan) => BahanCard(
                  bahan: bahan,
                  onTap: () => _navigateToDetail(bahan),
                  onEdit: () => _navigateToEdit(bahan),
                  onDelete: () => DeleteConfirmationDialog.show(context, bahan: bahan),
                  onStatusChange: (status) => _updateStatus(bahan, status),
                ),
              ),
      ],
    );
  }

  /// BottomNavigationBar sebagai Navigasi Utama Aplikasi
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Daftar Bahan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

