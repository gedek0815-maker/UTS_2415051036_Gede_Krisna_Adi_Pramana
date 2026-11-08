import 'package:flutter/material.dart';
import '../main.dart';

/// Reusable Widget: KategoriChip
/// Chip pilihan kategori bahan makanan dengan ikon dan status aktif/terpilih
class KategoriChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? customIcon;

  const KategoriChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.customIcon,
  });

  /// Helper untuk memetakan ikon berdasarkan nama kategori
  static IconData getIconForKategori(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'sayur':
      case 'sayuran':
        return Icons.eco_outlined;
      case 'buah':
      case 'buah-buahan':
        return Icons.apple_outlined;
      case 'daging':
      case 'seafood':
      case 'ikan':
        return Icons.set_meal_outlined;
      case 'susu':
      case 'olahan susu':
      case 'dairy':
        return Icons.local_drink_outlined;
      case 'bumbu':
      case 'rempah':
        return Icons.spa_outlined;
      case 'makanan siap saji':
      case 'siap saji':
        return Icons.fastfood_outlined;
      case 'minuman':
        return Icons.emoji_food_beverage_outlined;
      case 'semua':
        return Icons.grid_view_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = customIcon ?? getIconForKategori(label);

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      onSelected: onSelected,
    );
  }
}

