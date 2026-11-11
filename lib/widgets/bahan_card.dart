import 'package:flutter/material.dart';
import '../models/bahan_makanan.dart';

/// Reusable Widget: BahanCard
/// Menampilkan bahan makanan dalam format kartu putih (radius 16)
/// sesuai dengan desain mockup:
/// - Thumbnail gambar/ikon bahan di kiri
/// - Nama bahan bold + Exp: [Tanggal] di tengah
/// - Badge status kapsul (Aman / X hari lagi / Kedaluwarsa) + chevron di kanan
class BahanCard extends StatelessWidget {
  final BahanMakanan bahan;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final void Function(String newStatus)? onStatusChange;
  final bool isGrid;

  const BahanCard({
    super.key,
    required this.bahan,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
    this.isGrid = false,
  });

  String _formatExpDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return 'Exp: ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Thumbnail Gambar Bahan di Kiri
                _buildThumbnail(),
                const SizedBox(width: 14),

                // Nama Bahan + Tanggal Expired di Tengah
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bahan.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.5,
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
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatExpDate(bahan.tanggalExpired),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Status Kapsul di Kanan
                _buildStatusCapsule(),

                const SizedBox(width: 6),

                // Chevron Kanan
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Thumbnail Kategori / Bahan
  Widget _buildThumbnail() {
    Color bgColor;
    IconData icon;
    Color iconColor;

    final lower = bahan.nama.toLowerCase();
    final lowerKat = bahan.kategori.toLowerCase();

    if (lowerKat.contains('sayur') || lower.contains('sayur') || lower.contains('kol') || lower.contains('bayam') || lower.contains('sawi') || lower.contains('selada')) {
      bgColor = const Color(0xFFE8F5E9);
      icon = Icons.eco_rounded;
      iconColor = const Color(0xFF2E7D32);
    } else if (lowerKat.contains('buah') || lower.contains('buah') || lower.contains('tomat') || lower.contains('apel') || lower.contains('jeruk')) {
      bgColor = const Color(0xFFFFEBEE);
      icon = Icons.apple_rounded;
      iconColor = const Color(0xFFE53935);
    } else if (lowerKat.contains('daging') || lower.contains('daging') || lower.contains('ayam') || lower.contains('sapi') || lower.contains('kebab') || lower.contains('sosis') || lower.contains('nugget') || lower.contains('bakso')) {
      bgColor = const Color(0xFFFFE0B2);
      icon = Icons.restaurant_rounded;
      iconColor = const Color(0xFFE65100);
    } else if (lowerKat.contains('susu') || lower.contains('susu') || lower.contains('telur') || lower.contains('keju') || lower.contains('yogurt')) {
      bgColor = const Color(0xFFE0F2FE);
      icon = Icons.local_drink_rounded;
      iconColor = const Color(0xFF0284C7);
    } else if (lowerKat.contains('pokok') || lowerKat.contains('olahan') || lower.contains('mie') || lower.contains('indomie') || lower.contains('pasta') || lower.contains('beras') || lower.contains('roti') || lower.contains('nouilles')) {
      bgColor = const Color(0xFFFFF7ED);
      icon = Icons.bakery_dining_rounded;
      iconColor = const Color(0xFFB45309);
    } else if (lowerKat.contains('minum') || lower.contains('minum') || lower.contains('energen') || lower.contains('teh') || lower.contains('kopi') || lower.contains('jus')) {
      bgColor = const Color(0xFFE0F2FE);
      icon = Icons.local_cafe_rounded;
      iconColor = const Color(0xFF00897B);
    } else {
      bgColor = const Color(0xFFF1F5F9);
      icon = Icons.kitchen_rounded;
      iconColor = const Color(0xFF64748B);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }

  /// Badge Kapsul Status: Aman (Hijau) / X hari lagi (Merah/Oranye) / Kedaluwarsa (Abu)
  Widget _buildStatusCapsule() {
    if (bahan.isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.cancel_outlined, size: 13, color: Color(0xFF64748B)),
            SizedBox(width: 4),
            Text(
              'Kedaluwarsa',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    if (bahan.isHampirExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFE53935)),
            const SizedBox(width: 4),
            Text(
              '${bahan.sisaHari} hari lagi',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE53935),
              ),
            ),
          ],
        ),
      );
    }

    if (bahan.sisaHari > 3 && bahan.sisaHari <= 7) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              '${bahan.sisaHari} hari lagi',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    // Default: Aman
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF2E7D32)),
          SizedBox(width: 4),
          Text(
            'Aman',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
