import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bahan_makanan.dart';
import 'supabase_config.dart';

/// Service layer untuk menangani interaksi langsung dengan backend Supabase Database.
/// Berisi operasi CRUD (Create, Read, Update, Delete) untuk tabel bahan_makanan.
class SupabaseService {
  final SupabaseClient _client;
  static const String tableName = 'bahan_makanan';

  SupabaseService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  /// READ: Mengambil seluruh daftar bahan makanan
  /// Diurutkan berdasarkan tanggal expired terdekat (ascending)
  Future<List<BahanMakanan>> getAllBahan() async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .order('tanggal_expired', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => BahanMakanan.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data bahan makanan: $e');
    }
  }

  /// READ BY ID: Mengambil detail satu bahan makanan berdasarkan ID
  Future<BahanMakanan?> getBahanById(String id) async {
    try {
      final response = await _client
          .from(tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return BahanMakanan.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail bahan makanan: $e');
    }
  }

  /// CREATE: Menambahkan bahan makanan baru ke Supabase
  Future<BahanMakanan> addBahan(BahanMakanan bahan) async {
    try {
      final response = await _client
          .from(tableName)
          .insert(bahan.toJson())
          .select()
          .single();

      return BahanMakanan.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambahkan bahan makanan: $e');
    }
  }

  /// UPDATE: Memperbarui data bahan makanan yang sudah ada
  Future<BahanMakanan> updateBahan(BahanMakanan bahan) async {
    try {
      final response = await _client
          .from(tableName)
          .update(bahan.toJson())
          .eq('id', bahan.id)
          .select()
          .single();

      return BahanMakanan.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memperbarui data bahan makanan: $e');
    }
  }

  /// DELETE: Menghapus bahan makanan dari Supabase berdasarkan ID
  Future<void> deleteBahan(String id) async {
    try {
      await _client.from(tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus bahan makanan: $e');
    }
  }

  /// SOFT DELETE / STATUS UPDATE: Memperbarui status bahan ('dibuang', 'dikonsumsi', 'tersedia')
  /// Berguna untuk riwayat dan statistik pengelolaan makanan tanpa kehilangan data
  Future<BahanMakanan> updateStatusBahan(String id, String status) async {
    try {
      final response = await _client
          .from(tableName)
          .update({'status': status})
          .eq('id', id)
          .select()
          .single();

      return BahanMakanan.fromJson(response);
    } catch (e) {
      throw Exception('Gagal memperbarui status bahan makanan ($status): $e');
    }
  }

  /// SOFT DELETE: Memperbarui status bahan menjadi 'dibuang'
  Future<BahanMakanan> softDeleteBahan(String id) async {
    return await updateStatusBahan(id, 'dibuang');
  }
}

