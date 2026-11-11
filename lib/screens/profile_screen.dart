import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/bahan_provider.dart';

/// Screen: ProfileScreen (Tahap 19)
/// Menampilkan profil mahasiswa (Nama, NIM, Kelas), ringkasan statistik inventaris,
/// pengaturan aplikasi, informasi aplikasi FoodGuard, serta dialog panduan & bantuan.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifikasiAktif = true;
  bool _darkTheme = false;

  void _showTentangDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            const Text(
              'Tentang FoodGuard',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FoodGuard v1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aplikasi pemantau masa simpan dan kedaluwarsa bahan makanan untuk mencegah pemborosan pangan rumah tangga.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const Divider(height: 20),
            const Text(
              'Pengembang:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const Text('• Nama: Gede Krisna Adi Pramana', style: TextStyle(fontSize: 12)),
            const Text('• NIM: 2415051036', style: TextStyle(fontSize: 12)),
            const Text('• Kelas: 5B', style: TextStyle(fontSize: 12)),
            const Text('• Prodi: Pendidikan Teknik Informatika', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            const Text(
              'Tugas Ujian Tengah Semester (UTS) - Pemrograman Mobile',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPanduanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              'Bantuan & Panduan',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Menambah Bahan:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Gunakan tombol (+) di dashboard atau scan barcode kemasan untuk auto-fill nama produk.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              SizedBox(height: 10),
              Text(
                '2. Kategori Warna Kedaluwarsa:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '• Hijau (Aman): > 7 hari tersisa\n• Oranye (Perhatian): 4 - 7 hari tersisa\n• Merah (Segera Olah): 0 - 3 hari tersisa\n• Abu-abu (Expired): Telah melewati batas waktu',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              SizedBox(height: 10),
              Text(
                '3. Status Bahan Makanan:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Tandai bahan sebagai "Dikonsumsi" atau "Dibuang" di halaman detail bahan.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pengaturan Aplikasi',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                  title: const Text('Notifikasi Kedaluwarsa', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Ingatkan saat bahan mendekati expired', style: TextStyle(fontSize: 12)),
                  value: _notifikasiAktif,
                  // ignore: deprecated_member_use
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setSheetState(() => _notifikasiAktif = val);
                    setState(() => _notifikasiAktif = val);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                  title: const Text('Mode Gelap (Dark Mode)', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Ikuti tema sistem perangkat', style: TextStyle(fontSize: 12)),
                  value: _darkTheme,
                  // ignore: deprecated_member_use
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setSheetState(() => _darkTheme = val);
                    setState(() => _darkTheme = val);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari sesi aplikasi FoodGuard?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sesi telah diakhiri.'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            // Header Lengkung Hijau dengan Avatar & Info Mahasiswa
            _buildProfileHeader(),

            const SizedBox(height: 16),

            // Aktivitas & Statistik Bahan Makanan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildActivityCard(),
            ),

            const SizedBox(height: 16),

            // Menu Pengaturan & Navigasi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildMenuSection(),
            ),

            const SizedBox(height: 24),

            // Footer Branding Aplikasi
            _buildFooterBranding(),
          ],
        ),
      ),
    );
  }

  /// Header Lengkung Hijau dengan Identitas Mahasiswa
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              // Baris Judul & Tombol Pengaturan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profil Mahasiswa',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    tooltip: 'Pengaturan',
                    onPressed: _showSettingsSheet,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Avatar Pengguna dengan Icon Kamera
              Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(
                        Icons.person_rounded,
                        size: 54,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nama Mahasiswa
              const Text(
                'Gede Krisna Adi Pramana',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),

              // NIM & Kelas Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NIM: 2415051036 • Kelas 5B',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card Aktivitas & Statistik Bahan
  Widget _buildActivityCard() {
    return Consumer<BahanProvider>(
      builder: (context, provider, child) {
        final total = provider.totalBahan;
        final aman = provider.totalAman;
        final berisiko = provider.totalHampirExpired + provider.totalExpired;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
                    child: const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktivitas Inventaris',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Pantau status kesegaran pangan Anda',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      label: 'Total Bahan',
                      value: '$total',
                      icon: Icons.inventory_2_outlined,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Kondisi Aman',
                      value: '$aman',
                      icon: Icons.check_circle_outline,
                      color: AppColors.safe,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Berisiko',
                      value: '$berisiko',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Menu Pengaturan, Info, Panduan, dan Keluar
  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.tune_rounded,
            title: 'Pengaturan Aplikasi',
            subtitle: 'Notifikasi, preferensi tema, & penyimpanan',
            onTap: _showSettingsSheet,
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.notifications_none_rounded,
            title: 'Notifikasi & Pengingat',
            subtitle: _notifikasiAktif ? 'Aktif (H-3 sebelum expired)' : 'Nonaktif',
            trailing: Switch(
              value: _notifikasiAktif,
              // ignore: deprecated_member_use
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() => _notifikasiAktif = val);
              },
            ),
            onTap: () {
              setState(() => _notifikasiAktif = !_notifikasiAktif);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            title: 'Tentang FoodGuard',
            subtitle: 'Informasi pengembang, versi, & deskripsi',
            onTap: _showTentangDialog,
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Bantuan & Panduan',
            subtitle: 'Panduan penggunaan fitur & masa simpan',
            onTap: _showPanduanDialog,
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Keluar Akun',
            subtitle: 'Keluar dari sesi aplikasi saat ini',
            iconColor: AppColors.danger,
            textColor: AppColors.danger,
            onTap: _logoutConfirmDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color iconColor = AppColors.primary,
    Color textColor = AppColors.textPrimary,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  /// Footer Branding FoodGuard
  Widget _buildFooterBranding() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'FoodGuard',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Jaga Kesegaran, Hindari Pemborosan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Versi 1.0.0 • UTS Pemrograman Mobile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
