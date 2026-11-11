import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/bahan_makanan.dart';
import '../providers/bahan_provider.dart';
import '../widgets/empty_state_widget.dart';
import 'add_food_screen.dart';
import 'food_detail_screen.dart';
import 'food_list_screen.dart';
import 'profile_screen.dart';

/// Screen utama: HomeScreen Dashboard
/// Menampilkan ringkasan inventaris, status bahan segera olah,
/// filter kategori cepat, dialog notifikasi riil, dan navigasi utama.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'Semua';

  final List<Map<String, dynamic>> _quickCategories = [
    {'name': 'Semua', 'icon': Icons.grid_view_rounded},
    {'name': 'Sayur', 'icon': Icons.eco_rounded},
    {'name': 'Buah', 'icon': Icons.apple_rounded},
    {'name': 'Daging', 'icon': Icons.restaurant_rounded},
    {'name': 'Lainnya', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void initState() {
    super.initState();
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

  /// Menampilkan Bottom Sheet Notifikasi Pengingat Bahan Makanan yang sesuai
  void _showNotificationSheet(BahanProvider provider) {
    final urgentList = provider.bahanList
        .where((b) => b.isHampirExpired || b.isExpired)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: urgentList.isNotEmpty
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          urgentList.isNotEmpty
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          color: urgentList.isNotEmpty
                              ? const Color(0xFFE53935)
                              : const Color(0xFF2E7D32),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notifikasi & Pengingat',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              urgentList.isNotEmpty
                                  ? '${urgentList.length} bahan butuh perhatian Anda'
                                  : 'Semua bahan dalam kondisi aman',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: urgentList.isNotEmpty
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Daftar Notifikasi Bahan
                  if (urgentList.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Hebat! Tidak ada bahan makanan yang mendekati kedaluwarsa saat ini.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: urgentList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final bahan = urgentList[index];
                          final isExp = bahan.isExpired;

                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              _navigateToDetail(bahan);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isExp ? const Color(0xFFFFF1F2) : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isExp ? const Color(0xFFFECDD3) : const Color(0xFFFDE68A),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isExp ? const Color(0xFFFFE4E6) : const Color(0xFFFEF3C7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isExp ? Icons.cancel_outlined : Icons.alarm_rounded,
                                      color: isExp ? const Color(0xFFE11D48) : const Color(0xFFD97706),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bahan.nama,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isExp
                                              ? 'Telah kedaluwarsa! Segera periksa dan buang bila rusak.'
                                              : 'Kedaluwarsa dalam ${bahan.sisaHari} hari lagi. Segera olah!',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11.5,
                                            color: isExp ? const Color(0xFFE11D48) : const Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 18),

                  // Tombol Lihat Semua di Inventaris
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() => _currentIndex = 1);
                      },
                      child: const Text(
                        'Lihat Daftar Bahan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Menampilkan dialog tips keamanan pangan saat banner diklik
  void _showFoodSafetyTipsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Keamanan Pangan di Rumah',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSafetyTipItem('1. Atur Suhu Kulkas', 'Pertahankan suhu kulkas < 4°C dan freezer pada -18°C.'),
              _buildSafetyTipItem('2. Pisahkan Bahan Mentah', 'Pisahkan daging mentah dan sayuran untuk mencegah kontaminasi silang.'),
              _buildSafetyTipItem('3. Terapkan FIFO', 'Gunakan bahan yang tanggal kedaluwarsanya lebih dekat terlebih dahulu.'),
              _buildSafetyTipItem('4. Periksa Berkala', 'Periksa bahan makanan secara rutin melalui aplikasi FoodGuard.'),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyTipItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 600;

        if (isWide) {
          // ── WIDE LAYOUT (tablet / landscape ≥ 600 px) ──
          // Gunakan NavigationRail di kiri, konten di kanan
          return Scaffold(
            backgroundColor: const Color(0xFFF4F7F2),
            floatingActionButton: _currentIndex == 2
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFoodScreen(),
                        ),
                      );
                    },
                    tooltip: 'Tambah Bahan',
                    backgroundColor: const Color(0xFF2E7D32),
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
            body: Row(
              children: [
                // NavigationRail untuk layar lebar
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  backgroundColor: Colors.white,
                  elevation: 1,
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(
                    color: Color(0xFF2E7D32),
                    size: 26,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                  indicatorColor: const Color(0xFFE8F5E9),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: Text('Beranda'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: Text('Daftar Bahan'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: Text('Profil'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Color(0xFFE2E8F0)),
                // Konten utama
                Expanded(child: _buildCurrentTab()),
              ],
            ),
          );
        }

        // ── COMPACT LAYOUT (mobile / portrait < 600 px) ──
        // Gunakan BottomNavigationBar seperti biasa
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F2),
          appBar: null,
          body: _buildCurrentTab(),
          floatingActionButton: _currentIndex == 2
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddFoodScreen(),
                      ),
                    );
                  },
                  tooltip: 'Tambah Bahan',
                  backgroundColor: const Color(0xFF2E7D32),
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
          bottomNavigationBar: _buildCustomBottomBar(),
        );
      },
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return const FoodListScreen();
      case 2:
        return ProfileScreen(
          onNavigateTab: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        );
      default:
        return _buildDashboardTab();
    }
  }

  /// TAB 0: Beranda Dashboard
  Widget _buildDashboardTab() {
    return Consumer<BahanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.bahanList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF2E7D32)),
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

        final urgentList = provider.bahanList
            .where((b) => b.isHampirExpired || b.isExpired)
            .toList();

        return RefreshIndicator(
          color: const Color(0xFF2E7D32),
          onRefresh: () => provider.loadBahan(),
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 90),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Header Custom: Logo daun hijau + FoodGuard di kiri, Lonceng notifikasi di kanan
                    _buildCustomHeader(provider),

                    const SizedBox(height: 16),

                    // Greeting Section: Halo, Gede Adi! + Subteks + Keranjang sayur
                    _buildGreetingSection(),

                    const SizedBox(height: 16),

                    // Banner Utama: Keamanan Pangan di Rumah Anda (Bisa Diklik)
                    _buildBannerUtama(),

                    const SizedBox(height: 16),

                    // Statistik (1 Row berisi 4 Kartu Vertikal Sejajar: Total, Aman, Hampir Expired, Kedaluwarsa)
                    _buildStatsRow(provider),

                    const SizedBox(height: 20),

                    // Kategori Bahan: Header + 5 Kartu Horisontal
                    _buildKategoriSection(provider),

                    const SizedBox(height: 20),

                    // Section: Segera Olah!
                    _buildSegeraOlahSection(urgentList),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Custom Header: Logo daun + Teks FoodGuard & Ikon Lonceng Notifikasi yang membuka Notifikasi Pengingat
  Widget _buildCustomHeader(BahanProvider provider) {
    final hasUrgent = provider.bahanList.any((b) => b.isHampirExpired || b.isExpired);

    return Row(
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
        // Tombol Lonceng Notifikasi (Klik memunculkan notifikasi bahan makanan yang sesuai)
        GestureDetector(
          onTap: () => _showNotificationSheet(provider),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
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
                  Icons.notifications_none_rounded,
                  color: Color(0xFF1E293B),
                  size: 22,
                ),
              ),
              if (hasUrgent)
                Positioned(
                  top: 7,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Greeting Section: Halo Gede Adi & Ilustrasi Keranjang Sayur
  Widget _buildGreetingSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Halo, Gede Adi! 👋',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Yuk, pantau bahan makananmu agar tetap aman dan segar!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildVegetableBasketIllustration(),
      ],
    );
  }

  /// Ilustrasi visual keranjang sayuran
  Widget _buildVegetableBasketIllustration() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 52,
              height: 34,
              margin: const EdgeInsets.only(top: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFD7A15C),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                  top: Radius.circular(4),
                ),
                border: Border.all(color: const Color(0xFFB57C34), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: 2,
                    color: const Color(0xFFB57C34).withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.spa_rounded, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Transform.rotate(
                    angle: 0.25,
                    child: Container(
                      width: 14,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner Utama: Keamanan Pangan di Rumah Anda (Klik membuka tips keamanan)
  Widget _buildBannerUtama() {
    return GestureDetector(
      onTap: _showFoodSafetyTipsDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Keamanan Pangan\ndi Rumah Anda',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  /// Statistik: 1 Row berisi 4 Kartu Vertikal Sejajar (Klik membuka tab daftar bahan sesuai konteks)
  Widget _buildStatsRow(BahanProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildVerticalStatCard(
            icon: Icons.inventory_2_rounded,
            iconColor: const Color(0xFF2E7D32),
            count: provider.totalBahan.toString(),
            label: 'Total Bahan',
            onTap: () {
              provider.filter('Semua');
              setState(() => _currentIndex = 1);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildVerticalStatCard(
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFF2E7D32),
            count: provider.totalAman.toString(),
            label: 'Aman',
            onTap: () {
              setState(() => _currentIndex = 1);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${provider.totalAman} bahan makanan dalam kondisi aman (> 7 hari).'),
                  backgroundColor: const Color(0xFF2E7D32),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildVerticalStatCard(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFE53935),
            count: provider.totalHampirExpired.toString(),
            label: 'Hampir Expired',
            onTap: () {
              _showNotificationSheet(provider);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildVerticalStatCard(
            icon: Icons.event_busy_rounded,
            iconColor: const Color(0xFF4CAF50),
            count: provider.totalExpired.toString(),
            label: 'Kedaluwarsa',
            onTap: () {
              _showNotificationSheet(provider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalStatCard({
    required IconData icon,
    required Color iconColor,
    required String count,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(
              count,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kategori Bahan: Header + 5 kartu kotak vertikal
  Widget _buildKategoriSection(BahanProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.eco_outlined, size: 18, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Text(
                  'Kategori Bahan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() => _currentIndex = 1);
              },
              child: const Text(
                'Lihat Semua >',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: _quickCategories.map((cat) {
            final name = cat['name'] as String;
            final icon = cat['icon'] as IconData;
            final isSelected = _selectedCategory == name;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = name);
                  provider.filter(name);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Section "Segera Olah!" dengan badge merah muda dan kartu pink lembut
  Widget _buildSegeraOlahSection(List<BahanMakanan> urgentList) {
    final hasUrgent = urgentList.isNotEmpty;
    final urgentItem = hasUrgent ? urgentList.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.alarm_rounded, size: 20, color: Color(0xFFE53935)),
                SizedBox(width: 6),
                Text(
                  'Segera Olah!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${urgentList.length} bahan',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE53935),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!hasUrgent)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bagus! Tidak ada bahan yang mendekati batas kedaluwarsa.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFCDD2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Gambar/Ikon Makanan di Kiri
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Center(
                    child: _getCategoryIcon(urgentItem!.kategori),
                  ),
                ),
                const SizedBox(width: 12),
                // Informasi & Tombol Kapsul
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        urgentItem.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Color(0xFFE53935),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              urgentItem.isExpired
                                  ? 'Telah kedaluwarsa'
                                  : 'Kedaluwarsa dalam ${urgentItem.sisaHari} hari',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => _navigateToDetail(urgentItem),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Lihat Detail',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                              ],
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
      ],
    );
  }

  Widget _getCategoryIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'sayuran':
      case 'sayur':
        return const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 28);
      case 'buah':
        return const Icon(Icons.apple_rounded, color: Color(0xFFE53935), size: 28);
      case 'daging':
        return const Icon(Icons.restaurant_rounded, color: Color(0xFFD84315), size: 28);
      case 'susu & telur':
      case 'susu':
        return const Icon(Icons.local_drink_rounded, color: Color(0xFF0284C7), size: 28);
      default:
        return const Icon(Icons.kitchen_rounded, color: Color(0xFF2E7D32), size: 28);
    }
  }

  /// BottomNavigationBar Kustom Berlatar Putih dengan Indikator Garis Hijau di Bawah Tab Aktif
  Widget _buildCustomBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildBottomNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'Beranda',
              ),
              _buildBottomNavItem(
                index: 1,
                icon: Icons.grid_view_rounded,
                label: 'Daftar Bahan',
              ),
              _buildBottomNavItem(
                index: 2,
                icon: Icons.person_rounded,
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 3),
            // Indikator Garis Hijau di Bawah Tab Aktif
            Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
