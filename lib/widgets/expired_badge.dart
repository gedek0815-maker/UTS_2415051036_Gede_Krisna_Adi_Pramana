import 'package:flutter/material.dart';
import '../main.dart';
import '../models/bahan_makanan.dart';

/// Reusable Widget: ExpiredBadge
/// Menampilkan badge status masa simpan bahan makanan dengan indikator warna:
/// - 'aman' (> 7 hari): Hijau
/// - 'warning' (4-7 hari): Oranye
/// - 'bahaya' (0-3 hari): Merah
/// - 'expired' (< 0 hari): Abu-abu
class ExpiredBadge extends StatelessWidget {
  final int sisaHari;
  final bool isCompact;
  final String status;

  const ExpiredBadge({
    super.key,
    required this.sisaHari,
    this.isCompact = false,
    this.status = 'tersedia',
  });

  factory ExpiredBadge.fromBahan(BahanMakanan bahan, {bool isCompact = false}) {
    return ExpiredBadge(
      sisaHari: bahan.sisaHari,
      isCompact: isCompact,
      status: bahan.status,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (status == 'dikonsumsi') {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF0284C7);
      icon = Icons.task_alt_rounded;
      label = isCompact ? 'Dikonsumsi' : 'Telah Dikonsumsi';
    } else if (status == 'dibuang') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
      icon = Icons.delete_outline_rounded;
      label = isCompact ? 'Dibuang' : 'Telah Dibuang';
    } else if (sisaHari < 0) {
      bg = AppColors.expiredLight;
      fg = AppColors.expired;
      icon = Icons.cancel_outlined;
      label = isCompact ? 'Expired' : 'Expired (${sisaHari.abs()} hr lalu)';
    } else if (sisaHari == 0) {
      bg = AppColors.dangerLight;
      fg = AppColors.danger;
      icon = Icons.warning_rounded;
      label = isCompact ? 'Hari ini' : 'Expired Hari ini!';
    } else if (sisaHari <= 3) {
      bg = AppColors.dangerLight;
      fg = AppColors.danger;
      icon = Icons.warning_amber_rounded;
      label = '$sisaHari hari lagi';
    } else if (sisaHari <= 7) {
      bg = AppColors.warningLight;
      fg = AppColors.warning;
      icon = Icons.access_time_rounded;
      label = '$sisaHari hari lagi';
    } else {
      bg = AppColors.safeLight;
      fg = AppColors.safe;
      icon = Icons.check_circle_outline_rounded;
      label = '$sisaHari hari lagi';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 13 : 15, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

