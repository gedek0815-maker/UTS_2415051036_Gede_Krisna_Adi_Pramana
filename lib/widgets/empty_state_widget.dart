import 'package:flutter/material.dart';
import '../main.dart';

/// Reusable Widget: EmptyStateWidget
/// Menampilkan tampilan visual saat data kosong atau hasil pencarian tidak ditemukan
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inventory_2_outlined,
    this.title = 'Belum Ada Bahan Makanan',
    this.message = 'Catat bahan makanan Anda untuk memantau masa simpannya.',
    this.buttonText,
    this.onButtonPressed,
  });

  /// Factory untuk kondisi hasil pencarian kosong
  factory EmptyStateWidget.searchEmpty({
    String query = '',
    VoidCallback? onReset,
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'Tidak Ditemukan',
      message: query.isNotEmpty
          ? 'Tidak ada bahan makanan yang cocok dengan "$query".'
          : 'Bahan makanan dengan filter yang dipilih tidak ditemukan.',
      buttonText: onReset != null ? 'Reset Filter' : null,
      onButtonPressed: onReset,
    );
  }

  /// Factory untuk kondisi error loading
  factory EmptyStateWidget.error({
    required String errorMessage,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_rounded,
      title: 'Terjadi Kendala',
      message: errorMessage,
      buttonText: onRetry != null ? 'Coba Lagi' : null,
      onButtonPressed: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 54,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(buttonText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

