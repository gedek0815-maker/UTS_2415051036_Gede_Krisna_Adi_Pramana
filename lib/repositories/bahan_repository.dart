import '../models/bahan_makanan.dart';
import '../services/supabase_service.dart';

/// Repository layer yang bertindak sebagai Data Access Layer (DAL)
/// Menjembatani antara State Management (Provider) dan Service Layer (SupabaseService)
/// Sesuai arsitektur: UI → Provider → Repository → Service → Database
class BahanRepository {
  final SupabaseService _supabaseService;

  BahanRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  /// Mengambil semua data bahan makanan
  Future<List<BahanMakanan>> getAllBahan() async {
    return await _supabaseService.getAllBahan();
  }

  /// Mengambil detail satu bahan makanan berdasarkan ID
  Future<BahanMakanan?> getBahanById(String id) async {
    return await _supabaseService.getBahanById(id);
  }

  /// Menambahkan data bahan makanan baru
  Future<BahanMakanan> addBahan(BahanMakanan bahan) async {
    return await _supabaseService.addBahan(bahan);
  }

  /// Memperbarui data bahan makanan
  Future<BahanMakanan> updateBahan(BahanMakanan bahan) async {
    return await _supabaseService.updateBahan(bahan);
  }

  /// Menghapus data bahan makanan secara permanen (hard delete)
  Future<void> deleteBahan(String id) async {
    return await _supabaseService.deleteBahan(id);
  }

  /// Memperbarui status bahan makanan menjadi 'dibuang' (soft delete)
  Future<BahanMakanan> softDeleteBahan(String id) async {
    return await _supabaseService.softDeleteBahan(id);
  }

  /// Memperbarui status bahan makanan ('dibuang', 'dikonsumsi', 'tersedia')
  Future<BahanMakanan> updateStatusBahan(String id, String status) async {
    return await _supabaseService.updateStatusBahan(id, status);
  }

  /// Mengambil daftar bahan yang hampir expired (<= 3 hari) atau sudah expired
  Future<List<BahanMakanan>> getBahanHampirExpired() async {
    final allBahan = await _supabaseService.getAllBahan();
    return allBahan.where((bahan) => bahan.isHampirExpired || bahan.isExpired).toList();
  }

  /// Mengambil daftar bahan makanan berdasarkan kategori
  Future<List<BahanMakanan>> getBahanByKategori(String kategori) async {
    final allBahan = await _supabaseService.getAllBahan();
    if (kategori.toLowerCase() == 'semua') return allBahan;
    return allBahan
        .where((bahan) => bahan.kategori.toLowerCase() == kategori.toLowerCase())
        .toList();
  }

  /// Mencari bahan makanan berdasarkan nama atau catatan
  Future<List<BahanMakanan>> searchBahan(String query) async {
    final allBahan = await _supabaseService.getAllBahan();
    final lowerQuery = query.toLowerCase();
    return allBahan.where((bahan) {
      final matchNama = bahan.nama.toLowerCase().contains(lowerQuery);
      final matchCatatan = bahan.catatan?.toLowerCase().contains(lowerQuery) ?? false;
      return matchNama || matchCatatan;
    }).toList();
  }
}

