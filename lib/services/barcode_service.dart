import 'package:flutter/foundation.dart';
import 'food_api_service.dart';

/// Model hasil lookup barcode makanan/produk
class BarcodeProduct {
  final String barcode;
  final String nama;
  final String kategori;
  final String jumlah;
  final String satuan;
  final String lokasiSimpan;
  final int defaultExpiryDays;
  final String? catatan;
  final String? brand;
  final String? imageUrl;
  final bool isFound;

  const BarcodeProduct({
    required this.barcode,
    required this.nama,
    required this.kategori,
    required this.jumlah,
    required this.satuan,
    required this.lokasiSimpan,
    required this.defaultExpiryDays,
    this.catatan,
    this.brand,
    this.imageUrl,
    this.isFound = true,
  });

  /// Fallback jika produk tidak ditemukan di database manapun
  factory BarcodeProduct.notFound(String barcode) {
    return BarcodeProduct(
      barcode: barcode,
      nama: '',
      kategori: 'Lainnya',
      jumlah: '1',
      satuan: 'pcs',
      lokasiSimpan: 'Lemari',
      defaultExpiryDays: 7,
      catatan: 'Barcode: $barcode',
      isFound: false,
    );
  }
}

/// Service untuk lookup informasi produk berdasarkan scan barcode
class BarcodeService {
  /// Katalog lokal offline untuk produk bahan makanan populer di Indonesia
  static final Map<String, BarcodeProduct> _localCatalog = {
    // Mie Instan & Olahan
    '8992388111015': const BarcodeProduct(
      barcode: '8992388111015',
      nama: 'Indomie Mi Instan Goreng',
      kategori: 'Makanan Olahan',
      jumlah: '1',
      satuan: 'bungkus',
      lokasiSimpan: 'Lemari',
      defaultExpiryDays: 180,
      brand: 'Indomie',
      catatan: 'Simpan di tempat kering dan sejuk',
    ),
    '8992388111022': const BarcodeProduct(
      barcode: '8992388111022',
      nama: 'Indomie Rasa Ayam Bawang',
      kategori: 'Makanan Olahan',
      jumlah: '1',
      satuan: 'bungkus',
      lokasiSimpan: 'Lemari',
      defaultExpiryDays: 180,
      brand: 'Indomie',
    ),
    '8998866200234': const BarcodeProduct(
      barcode: '8998866200234',
      nama: 'Bango Kecap Manis 550ml',
      kategori: 'Bumbu',
      jumlah: '1',
      satuan: 'botol',
      lokasiSimpan: 'Dapur',
      defaultExpiryDays: 365,
      brand: 'Bango',
    ),
    // Susu & Olahan Susu
    '8991002101345': const BarcodeProduct(
      barcode: '8991002101345',
      nama: 'Ultra Milk Cokelat 250ml',
      kategori: 'Minuman',
      jumlah: '1',
      satuan: 'kotak',
      lokasiSimpan: 'Kulkas',
      defaultExpiryDays: 30,
      brand: 'Ultra Milk',
      catatan: 'Setelah dibuka habiskan dalam 4 hari',
    ),
    '8991002101116': const BarcodeProduct(
      barcode: '8991002101116',
      nama: 'Ultra Milk Plain 1000ml',
      kategori: 'Susu & Telur',
      jumlah: '1',
      satuan: 'liter',
      lokasiSimpan: 'Kulkas',
      defaultExpiryDays: 14,
      brand: 'Ultra Milk',
    ),
    '8993175535111': const BarcodeProduct(
      barcode: '8993175535111',
      nama: 'Kraft Cheddar Cheese 165g',
      kategori: 'Susu & Telur',
      jumlah: '1',
      satuan: 'kotak',
      lokasiSimpan: 'Kulkas',
      defaultExpiryDays: 60,
      brand: 'Kraft',
    ),
    // Roti & Tepung
    '8992753612019': const BarcodeProduct(
      barcode: '8992753612019',
      nama: 'Sari Roti Tawar Spesial',
      kategori: 'Makanan Olahan',
      jumlah: '1',
      satuan: 'bungkus',
      lokasiSimpan: 'Meja Makan',
      defaultExpiryDays: 5,
      brand: 'Sari Roti',
      catatan: 'Roti segar, konsumsi sebelum berjamur',
    ),
    // Telur & Daging
    '8992775210118': const BarcodeProduct(
      barcode: '8992775210118',
      nama: 'Telur Ayam Negeri Fresh',
      kategori: 'Susu & Telur',
      jumlah: '10',
      satuan: 'butir',
      lokasiSimpan: 'Kulkas',
      defaultExpiryDays: 14,
      catatan: 'Simpan di egg rack kulkas',
    ),
    '8991234567890': const BarcodeProduct(
      barcode: '8991234567890',
      nama: 'Daging Ayam Fillet Dada',
      kategori: 'Daging',
      jumlah: '500',
      satuan: 'gram',
      lokasiSimpan: 'Freezer',
      defaultExpiryDays: 3,
      catatan: 'Simpan di freezer jika belum diolah',
    ),
    // Sayuran & Buah Segar
    '8998765432109': const BarcodeProduct(
      barcode: '8998765432109',
      nama: 'Bayam Hijau Segar Organik',
      kategori: 'Sayuran',
      jumlah: '1',
      satuan: 'ikat',
      lokasiSimpan: 'Kulkas',
      defaultExpiryDays: 3,
      catatan: 'Segera olah dalam 1-3 hari',
    ),
    '8993456789012': const BarcodeProduct(
      barcode: '8993456789012',
      nama: 'Tomat Ceri Segar',
      kategori: 'Sayuran',
      jumlah: '500',
      satuan: 'gram',
      lokasiSimpan: 'Kulkas',
      defaultExpiryDays: 7,
    ),
    '8992745321012': const BarcodeProduct(
      barcode: '8992745321012',
      nama: 'Apel Fuji Manis',
      kategori: 'Buah',
      jumlah: '1',
      satuan: 'kg',
      lokasiSimpan: 'Kulkas',
      defaultExpiryDays: 14,
    ),
    // Minuman Segar
    '8996001301018': const BarcodeProduct(
      barcode: '8996001301018',
      nama: 'Aqua Air Mineral 600ml',
      kategori: 'Minuman',
      jumlah: '1',
      satuan: 'botol',
      lokasiSimpan: 'Kulkas',
      defaultExpiryDays: 365,
      brand: 'Danone Aqua',
    ),
    '8999999001234': const BarcodeProduct(
      barcode: '8999999001234',
      nama: 'Susu Sapi Murni Pasteur',
      kategori: 'Susu & Telur',
      jumlah: '1',
      satuan: 'liter',
      lokasiSimpan: 'Kulkas',
      defaultExpiryDays: 5,
      brand: 'FreshFarm',
      catatan: 'Susu segar tanpa pengawet',
    ),
  };

  /// Mencari data produk dari database lokal atau Open Food Facts API
  static Future<BarcodeProduct> lookupProduct(String barcode) async {
    final cleanCode = barcode.trim();
    if (cleanCode.isEmpty) {
      return BarcodeProduct.notFound(barcode);
    }

    // 1. Cek katalog lokal terlebih dahulu (cepat & akurat)
    if (_localCatalog.containsKey(cleanCode)) {
      debugPrint('[BarcodeService] Produk ditemukan di katalog lokal: ${_localCatalog[cleanCode]!.nama}');
      return _localCatalog[cleanCode]!;
    }

    // 2. Coba fetch dari Open Food Facts REST API via FoodApiService
    try {
      final apiProduct = await FoodApiService.getProductByBarcode(cleanCode);
      if (apiProduct != null && apiProduct.productName.isNotEmpty) {
        final parsedQty = apiProduct.parsedQuantityAndUnit;
        final brandPrefix = apiProduct.brands != null && apiProduct.brands!.isNotEmpty
            ? '${apiProduct.brands} - '
            : '';

        return BarcodeProduct(
          barcode: cleanCode,
          nama: '$brandPrefix${apiProduct.productName}',
          kategori: apiProduct.foodGuardCategory,
          jumlah: parsedQty.$1,
          satuan: parsedQty.$2,
          lokasiSimpan: _guessLocation(apiProduct.foodGuardCategory),
          defaultExpiryDays: apiProduct.estimatedExpiryDays,
          brand: apiProduct.brands,
          imageUrl: apiProduct.imageUrl,
          catatan: 'Barcode: $cleanCode\nSumber: Open Food Facts API',
          isFound: true,
        );
      }
    } catch (e) {
      debugPrint('[BarcodeService] FoodApiService lookup failed: $e');
    }

    // 3. Fallback jika tidak ditemukan
    return BarcodeProduct.notFound(cleanCode);
  }

  /// Memprediksi lokasi simpan berdasarkan kategori
  static String _guessLocation(String kategori) {
    switch (kategori) {
      case 'Daging':
        return 'Freezer';
      case 'Sayuran':
      case 'Buah':
      case 'Susu & Telur':
      case 'Minuman':
        return 'Kulkas';
      default:
        return 'Lemari';
    }
  }

  /// Daftar barcode demo yang bisa langsung dicoba pengguna untuk testing
  static List<BarcodeProduct> get demoProducts => _localCatalog.values.toList();
}

