import 'package:flutter/material.dart';
import '../main.dart';
import '../models/bahan_makanan.dart';
import 'expired_badge.dart';
import 'kategori_chip.dart';

/// Reusable Widget: BahanCard
/// Menampilkan ringkasan bahan makanan dalam format card.
/// Mendukung mode ListView (horizontal layout) dan GridView (vertical layout).
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

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  /// Tampilan Card untuk mode ListView
  Widget _buildListCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar / Ikon Kategori
              _buildCategoryAvatar(size: 48),
              const SizedBox(width: 14),

              // Detail Informasi Bahan
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          bahan.lokasiSimpan,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.scale_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          bahan.jumlah,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ExpiredBadge.fromBahan(bahan, isCompact: true),
                  ],
                ),
              ),

              // Menu Opsi (Status / Edit / Hapus)
              if (onEdit != null || onDelete != null || onStatusChange != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                    if (value == 'status_dikonsumsi') onStatusChange?.call('dikonsumsi');
                    if (value == 'status_dibuang') onStatusChange?.call('dibuang');
                    if (value == 'status_tersedia') onStatusChange?.call('tersedia');
                  },
                  itemBuilder: (context) => [
                    if (onStatusChange != null) ...[
                      if (bahan.status != 'dikonsumsi')
                        const PopupMenuItem(
                          value: 'status_dikonsumsi',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 18, color: AppColors.safe),
                              SizedBox(width: 8),
                              Text('Tandai Dikonsumsi', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                            ],
                          ),
                        ),
                      if (bahan.status != 'dibuang')
                        const PopupMenuItem(
                          value: 'status_dibuang',
                          child: Row(
                            children: [
                              Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.warning),
                              SizedBox(width: 8),
                              Text('Tandai Dibuang', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                            ],
                          ),
                        ),
                      if (bahan.status != 'tersedia')
                        const PopupMenuItem(
                          value: 'status_tersedia',
                          child: Row(
                            children: [
                              Icon(Icons.restore_rounded, size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Pulihkan Status', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                            ],
                          ),
                        ),
                      const PopupMenuDivider(),
                    ],
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                          ],
                        ),
                      ),
                  ],
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  /// Tampilan Card untuk mode GridView (Responsive Layout)
  Widget _buildGridCard(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryAvatar(size: 40),
                  if (onEdit != null || onDelete != null || onStatusChange != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                        if (value == 'status_dikonsumsi') onStatusChange?.call('dikonsumsi');
                        if (value == 'status_dibuang') onStatusChange?.call('dibuang');
                        if (value == 'status_tersedia') onStatusChange?.call('tersedia');
                      },
                      itemBuilder: (context) => [
                        if (onStatusChange != null) ...[
                          if (bahan.status != 'dikonsumsi')
                            const PopupMenuItem(
                              value: 'status_dikonsumsi',
                              child: Text('Tandai Dikonsumsi', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.safe)),
                            ),
                          if (bahan.status != 'dibuang')
                            const PopupMenuItem(
                              value: 'status_dibuang',
                              child: Text('Tandai Dibuang', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.warning)),
                            ),
                          if (bahan.status != 'tersedia')
                            const PopupMenuItem(
                              value: 'status_tersedia',
                              child: Text('Pulihkan Status', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.primary)),
                            ),
                          const PopupMenuDivider(),
                        ],
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.danger)),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bahan.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${bahan.jumlah} • ${bahan.lokasiSimpan}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ExpiredBadge.fromBahan(bahan, isCompact: true),
            ],
          ),
        ),
      ),
    );
  }

  /// Avatar ikon kategori
  Widget _buildCategoryAvatar({required double size}) {
    final icon = KategoriChip.getIconForKategori(bahan.kategori);

    if (bahan.fotoUrl != null && bahan.fotoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 4),
        child: Image.network(
          bahan.fotoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stack) => _buildFallbackAvatar(icon, size),
        ),
      );
    }

    return _buildFallbackAvatar(icon, size);
  }

  Widget _buildFallbackAvatar(IconData icon, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(
        icon,
        size: size * 0.55,
        color: AppColors.primary,
      ),
    );
  }
}

