import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bahan_provider.dart';
import 'barcode_scanner_screen.dart';

/// Screen: ProfileScreen (Tahap 19 & Refactor Mockup 3)
/// Menampilkan profil pengguna (Nama, NIM, Kelas), aktivitas inventaris,
/// menu terpisah sebagai kartu putih, footer banner, serta 3 custom dialog.
class ProfileScreen extends StatefulWidget {
  final void Function(int index)? onNavigateTab;
  const ProfileScreen({super.key, this.onNavigateTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifikasiAktif = true;
  bool _notifikasiHarian = true;
  bool _modeGelap = false;

  /// Modal Bottom Sheet Pengaturan Aplikasi
  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF2E7D32),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Pengaturan Aplikasi',
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
                                  'Preferensi notifikasi, tema & data',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
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

                      // Pengaturan 1: Notifikasi Pengingat
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF2E7D32)),
                        title: const Text(
                          'Peringatan Kedaluwarsa',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Kirim pengingat bahan H-3 sebelum kedaluwarsa',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                        value: _notifikasiAktif,
                        // ignore: deprecated_member_use
                        activeColor: const Color(0xFF2E7D32),
                        onChanged: (val) {
                          setSheetState(() => _notifikasiAktif = val);
                          setState(() => _notifikasiAktif = val);
                        },
                      ),

                      // Pengaturan 2: Notifikasi Harian
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.alarm_on_rounded, color: Color(0xFF2E7D32)),
                        title: const Text(
                          'Laporan Ringkasan Pagi',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Periksa bahan makanan setiap pukul 08:00',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                        value: _notifikasiHarian,
                        // ignore: deprecated_member_use
                        activeColor: const Color(0xFF2E7D32),
                        onChanged: (val) {
                          setSheetState(() => _notifikasiHarian = val);
                          setState(() => _notifikasiHarian = val);
                        },
                      ),

                      // Pengaturan 3: Mode Gelap
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: const Icon(Icons.dark_mode_outlined, color: Color(0xFF2E7D32)),
                        title: const Text(
                          'Tema Gelap',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Gunakan tampilan kontras malam',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                        value: _modeGelap,
                        // ignore: deprecated_member_use
                        activeColor: const Color(0xFF2E7D32),
                        onChanged: (val) {
                          setSheetState(() => _modeGelap = val);
                          setState(() => _modeGelap = val);
                        },
                      ),

                      const SizedBox(height: 10),

                      // Status Koneksi Supabase
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.cloud_done_rounded, color: Color(0xFF2E7D32), size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Database Supabase Cloud: Terhubung & Aktif',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pengaturan aplikasi berhasil disimpan.'),
                                backgroundColor: Color(0xFF2E7D32),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Text(
                            'Simpan Pengaturan',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
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
      },
    );
  }

  /// Modal Bottom Sheet Ubah Foto Profil
  void _showChangeAvatarSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const Text(
                    'Ubah Foto Profil',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Gede Krisna Adi Pramana • 2415051036',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.photo_library_rounded, color: Color(0xFF2E7D32)),
                    ),
                    title: const Text('Pilih dari Galeri', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto profil berhasil diperbarui! 🎉'),
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0284C7)),
                    ),
                    title: const Text('Buka Kamera', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kamera siap digunakan.'),
                          backgroundColor: Color(0xFF0284C7),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Dialog 1: Tentang FoodGuard
  void _showTentangDialog() {
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
              // Header Dialog dengan icon daun + X
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Tentang FoodGuard',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'FoodGuard v1.0.0',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
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
              const SizedBox(height: 14),

              // Deskripsi
              const Text(
                'Aplikasi pemantau masa simpan dan kedaluwarsa bahan makanan untuk mencegah pemborosan pangan rumah tangga.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // Bagian Pengembang
              Row(
                children: const [
                  Text(
                    '</> ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    'Pengembang:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _buildDeveloperInfo('• Nama', 'Gede Krisna Adi Pramana'),
              _buildDeveloperInfo('• NIM', '2415051036'),
              _buildDeveloperInfo('• Kelas', '5B'),
              _buildDeveloperInfo('• Prodi', 'Pendidikan Teknik Informatika'),

              const SizedBox(height: 20),

              // Tombol Tutup Hijau Penuh
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Tutup',
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
  }

  Widget _buildDeveloperInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog 2: Bantuan & Panduan
  void _showPanduanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 48,
          ),
          child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Bantuan & Panduan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Tips menggunakan FoodGuard dengan maksimal',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3 Langkah Bernomor
              _buildPanduanStep(
                number: '1',
                text: 'Masukkan bahan makanan yang Anda miliki beserta tanggal kedaluwarsa.',
              ),
              const SizedBox(height: 12),
              _buildPanduanStep(
                number: '2',
                text: 'Aktifkan notifikasi untuk mendapat pengingat sebelum bahan kedaluwarsa.',
              ),
              const SizedBox(height: 12),
              _buildPanduanStep(
                number: '3',
                text: 'Periksa secara berkala daftar bahan Anda.',
              ),

              const SizedBox(height: 22),

              // Tombol Mengerti Hijau Penuh
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Mengerti',
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
      ),
    );
  }

  Widget _buildPanduanStep({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              color: Color(0xFF334155),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  /// Dialog 3: Keluar Akun?
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon Lingkaran Tempat Sampah Merah di Tengah Atas
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFD32F2F),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Keluar Akun?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Apakah Anda yakin ingin keluar dari akun ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 22),

              // 2 Tombol Sejajar: Batal & Keluar
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sesi telah diakhiri.'),
                              backgroundColor: Color(0xFFD32F2F),
                            ),
                          );
                        },
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          children: [
            // Header Lengkung Hijau Gradasi (#1B5E20 ke #43A047, radius 28)
            _buildProfileHeader(),

            const SizedBox(height: 16),

            // Kartu Aktivitas Inventaris (Bisa Diklik menuju Daftar Bahan)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _buildActivityCard(),
            ),

            const SizedBox(height: 16),

            // 5 Menu Profil Sebagai KARTU PUTIH TERPISAH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  // 1. Pengaturan Aplikasi
                  _buildSeparateMenuCard(
                    icon: Icons.tune_rounded,
                    title: 'Pengaturan Aplikasi',
                    onTap: _showSettingsSheet,
                  ),
                  const SizedBox(height: 10),

                  // 2. Notifikasi & Pengingat (dengan Switch hijau)
                  _buildNotificationMenuCard(),
                  const SizedBox(height: 10),

                  // 3. Tentang FoodGuard
                  _buildSeparateMenuCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang FoodGuard',
                    onTap: _showTentangDialog,
                  ),
                  const SizedBox(height: 10),

                  // 4. Bantuan & Panduan
                  _buildSeparateMenuCard(
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan & Panduan',
                    onTap: _showPanduanDialog,
                  ),
                  const SizedBox(height: 10),

                  // 5. Keluar Akun (Latar merah muda lembut #FFF5F5, ikon & teks merah)
                  _buildLogoutMenuCard(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Footer Banner: FoodGuard v1.0.0
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _buildFooterBanner(),
            ),
          ],
        ),
      ),
    );
  }

  /// Header Gradasi Hijau Lengkung (Tanpa AppBar blok hijau tambahan)
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            children: [
              // Baris Atas: Logo daun + FoodGuard di kiri, Ikon QR & Gear di kanan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'FoodGuard',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
                        tooltip: 'Scan Barcode',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        tooltip: 'Pengaturan',
                        onPressed: _showSettingsSheet,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // CircleAvatar utuh dengan badge kamera di kanan bawah (Bisa Diklik untuk Ubah Foto)
              GestureDetector(
                onTap: _showChangeAvatarSheet,
                child: Stack(
                  children: [
                    Container(
                      width: 86,
                      height: 86,
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
                          size: 52,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Nama Mahasiswa
              const Text(
                'Gede Krisna Adi Pramana',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              // Kapsul Transparan NIM & Kelas 5B
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

  /// Kartu Aktivitas Inventaris
  Widget _buildActivityCard() {
    return Consumer<BahanProvider>(
      builder: (context, provider, child) {
        final total = provider.totalBahan;
        final aman = provider.totalAman;
        final berisiko = provider.totalHampirExpired + provider.totalExpired;

        return GestureDetector(
          onTap: () {
            widget.onNavigateTab?.call(1);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF2E7D32), size: 18),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Aktivitas Inventaris',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'Pantau status kesegaran pangan Anda',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                  ],
                ),
                const SizedBox(height: 14),

                // 3 Kotak Statistik Sejajar (Total: Hijau Muda, Aman: Biru Muda, Berisiko: Oranye Muda)
                Row(
                  children: [
                    Expanded(
                      child: _buildColoredStatBox(
                        bgColor: const Color(0xFFE8F5E9),
                        iconColor: const Color(0xFF2E7D32),
                        icon: Icons.inventory_2_rounded,
                        count: '$total',
                        label: 'Total Bahan',
                        onTap: () {
                          provider.filter('Semua');
                          widget.onNavigateTab?.call(1);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildColoredStatBox(
                        bgColor: const Color(0xFFE3F2FD),
                        iconColor: const Color(0xFF0284C7),
                        icon: Icons.check_circle_rounded,
                        count: '$aman',
                        label: 'Kondisi Aman',
                        onTap: () {
                          widget.onNavigateTab?.call(1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$aman bahan dalam kondisi aman (> 7 hari).'),
                              backgroundColor: const Color(0xFF0284C7),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildColoredStatBox(
                        bgColor: const Color(0xFFFFF3E0),
                        iconColor: const Color(0xFFE65100),
                        icon: Icons.warning_amber_rounded,
                        count: '$berisiko',
                        label: 'Berisiko',
                        onTap: () {
                          widget.onNavigateTab?.call(1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$berisiko bahan berisiko kedaluwarsa.'),
                              backgroundColor: const Color(0xFFE65100),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColoredStatBox({
    required Color bgColor,
    required Color iconColor,
    required IconData icon,
    required String count,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: iconColor,
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
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Individual White Menu Card
  Widget _buildSeparateMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Menu Card Notifikasi dengan Switch Hijau yang Responsif
  Widget _buildNotificationMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _notifikasiAktif = !_notifikasiAktif;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_notifikasiAktif
                    ? 'Notifikasi pengingat kedaluwarsa H-3 aktif 🔔'
                    : 'Notifikasi pengingat dinonaktifkan.'),
                backgroundColor: _notifikasiAktif ? const Color(0xFF2E7D32) : const Color(0xFF64748B),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Notifikasi & Pengingat',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Switch(
                  value: _notifikasiAktif,
                  // ignore: deprecated_member_use
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (val) {
                    setState(() {
                      _notifikasiAktif = val;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val
                            ? 'Notifikasi pengingat kedaluwarsa H-3 aktif 🔔'
                            : 'Notifikasi pengingat dinonaktifkan.'),
                        backgroundColor: val ? const Color(0xFF2E7D32) : const Color(0xFF64748B),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Menu Card Keluar Akun (Latar merah muda tipis #FFF5F5, ikon & teks merah)
  Widget _buildLogoutMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLogoutDialog,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFD32F2F),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Keluar Akun',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFD32F2F), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Footer Banner Berlatar Hijau Lembut (#E8F5E9, radius 16)
  Widget _buildFooterBanner() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('FoodGuard v1.0.0 — Dikembangkan oleh Gede Krisna Adi Pramana (NIM: 2415051036)'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 22),
            const SizedBox(width: 8),
            Column(
              children: const [
                Text(
                  'FoodGuard v1.0.0',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Jaga Kesegaran, Hindari Pemborosan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
