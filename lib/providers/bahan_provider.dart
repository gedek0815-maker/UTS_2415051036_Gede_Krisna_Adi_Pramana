import 'package:flutter/foundation.dart';
import '../models/bahan_makanan.dart';
import '../repositories/bahan_repository.dart';

/// Provider state management untuk BahanMakanan menggunakan ChangeNotifier.
/// Mengelola state global aplikasi: loading, error, data list, filter kategori, dan pencarian.
/// Alur arsitektur: UI → BahanProvider → BahanRepository → SupabaseService
class BahanProvider with ChangeNotifier {
  final BahanRepository _repository;

  BahanProvider({BahanRepository? repository})
      : _repository = repository ?? BahanRepository();

  // -------------------------------------------------------------
  // STATE VARIABLES
  // -------------------------------------------------------------
  List<BahanMakanan> _bahanList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _filterKategori = 'Semua';
  String _searchQuery = '';

  // -------------------------------------------------------------
  // GETTERS
  // -------------------------------------------------------------
  List<BahanMakanan> get bahanList => _bahanList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterKategori => _filterKategori;
  String get searchQuery => _searchQuery;

  /// Daftar bahan makanan setelah disaring berdasarkan kategori dan query pencarian
  List<BahanMakanan> get filteredBahanList {
    return _bahanList.where((bahan) {
      // Filter kategori
      final matchKategori = _filterKategori == 'Semua' ||
          bahan.kategori.toLowerCase() == _filterKategori.toLowerCase();

      // Filter pencarian (nama atau catatan)
      final query = _searchQuery.toLowerCase().trim();
      final matchSearch = query.isEmpty ||
          bahan.nama.toLowerCase().contains(query) ||
          (bahan.catatan?.toLowerCase().contains(query) ?? false);

      return matchKategori && matchSearch;
    }).toList();
  }

  /// Ringkasan statistik untuk dashboard (Tahap 10)
  int get totalBahan => _bahanList.length;

  int get totalHampirExpired =>
      _bahanList.where((b) => b.isHampirExpired).length;

  int get totalExpired =>
      _bahanList.where((b) => b.isExpired).length;

  int get totalAman =>
      _bahanList.where((b) => !b.isExpired && !b.isHampirExpired).length;

  // -------------------------------------------------------------
  // ACTIONS / METHODS
  // -------------------------------------------------------------

  /// Mengambil semua data bahan makanan dari repository
  Future<void> loadBahan() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _bahanList = await _repository.getAllBahan();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Menambahkan bahan makanan baru ke database dan memperbarui state lokal
  Future<bool> addBahan(BahanMakanan bahan) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final baru = await _repository.addBahan(bahan);
      _bahanList.insert(0, baru);
      // Urutkan kembali berdasarkan tanggal expired terdekat
      _sortBahanList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Memperbarui data bahan makanan dan memperbarui state lokal
  Future<bool> updateBahan(BahanMakanan bahan) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updated = await _repository.updateBahan(bahan);
      final index = _bahanList.indexWhere((item) => item.id == updated.id);
      if (index != -1) {
        _bahanList[index] = updated;
        _sortBahanList();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Menghapus bahan makanan secara permanen (hard delete)
  Future<bool> deleteBahan(String id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _repository.deleteBahan(id);
      _bahanList.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Melakukan soft delete: mengubah status bahan menjadi 'dibuang'
  Future<bool> softDeleteBahan(String id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final updated = await _repository.softDeleteBahan(id);
      final index = _bahanList.indexWhere((item) => item.id == updated.id);
      if (index != -1) {
        _bahanList[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mengatur filter kategori ('Semua', 'Sayur', 'Buah', 'Daging', dll.)
  void filter(String kategori) {
    _filterKategori = kategori;
    notifyListeners();
  }

  /// Mengatur query pencarian
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Mereset semua filter dan pencarian
  void resetFilter() {
    _filterKategori = 'Semua';
    _searchQuery = '';
    notifyListeners();
  }

  // -------------------------------------------------------------
  // HELPER METHODS
  // -------------------------------------------------------------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _sortBahanList() {
    _bahanList.sort((a, b) => a.tanggalExpired.compareTo(b.tanggalExpired));
  }
}

