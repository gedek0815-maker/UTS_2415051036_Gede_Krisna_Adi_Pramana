import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/bahan_makanan.dart';
import '../providers/bahan_provider.dart';

/// Dialog konfirmasi penghapusan bahan makanan
/// Menyediakan konfirmasi sebelum menghapus item dari database Supabase / state
class DeleteConfirmationDialog extends StatefulWidget {
  final BahanMakanan bahan;
  final VoidCallback? onDeleted;

  const DeleteConfirmationDialog({
    super.key,
    required this.bahan,
    this.onDeleted,
  });

  /// Static helper untuk menampilkan dialog dengan mudah dari screen mana saja
  static Future<bool?> show(
    BuildContext context, {
    required BahanMakanan bahan,
    VoidCallback? onDeleted,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        bahan: bahan,
        onDeleted: onDeleted,
      ),
    );
  }

  @override
  State<DeleteConfirmationDialog> createState() => _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    try {
      final provider = context.read<BahanProvider>();
      await provider.deleteBahan(widget.bahan.id);

      if (mounted) {
        Navigator.pop(context, true);
        widget.onDeleted?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.bahan.nama} berhasil dihapus.'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.delete_forever_rounded,
          color: AppColors.danger,
          size: 32,
        ),
      ),
      title: const Text(
        'Hapus Bahan Makanan',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: Text(
        'Apakah Anda yakin ingin menghapus "${widget.bahan.nama}"? Tindakan ini akan menghapus data bahan makanan secara permanen.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      actions: [
        OutlinedButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isDeleting ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Hapus'),
        ),
      ],
    );
  }
}
