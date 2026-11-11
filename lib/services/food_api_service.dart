import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Model representasi data produk dari Open Food Facts REST API
class FoodApiProduct {
  final String barcode;
  final String productName;
  final String? brands;
  final String? categories;
  final String? quantity;
  final String? imageUrl;
  final String? ingredientsText;
  final Map<String, dynamic>? nutriments;

  const FoodApiProduct({
    required this.barcode,
    required this.productName,
    this.brands,
    this.categories,
    this.quantity,
    this.imageUrl,
    this.ingredientsText,
    this.nutriments,
  });

  /// Factory constructor untuk mem-parse JSON response dari Open Food Facts
  factory FoodApiProduct.fromJson(Map<String, dynamic> json) {
    final String code = (json['code'] ?? json['id'] ?? '').toString();
    final String name = (json['product_name_id'] ??
            json['product_name'] ??
            json['product_name_en'] ??
            json['generic_name'] ??
            json['brands'] ??
            '')
        .toString()
        .trim();

    return FoodApiProduct(
      barcode: code,
      productName: name.isNotEmpty ? name : 'Produk Makanan',
      brands: json['brands'] as String?,
      categories: json['categories'] as String?,
      quantity: json['quantity'] as String?,
      imageUrl: (json['image_front_small_url'] ??
              json['image_front_url'] ??
              json['image_url']) as String?,
      ingredientsText: json['ingredients_text'] as String?,
      nutriments: json['nutriments'] as Map<String, dynamic>?,
    );
  }

  /// Ekstraksi kategori yang disesuaikan dengan kategori FoodGuard
  String get foodGuardCategory {
    final text = '${categories ?? ''} $productName ${brands ?? ''}'.toLowerCase();
    if (text.contains('sayur') || text.contains('vegetable') || text.contains('spinach')) {
      return 'Sayuran';
    }
    if (text.contains('buah') || text.contains('fruit') || text.contains('apple')) {
      return 'Buah';
    }
    if (text.contains('daging') || text.contains('meat') || text.contains('chicken') || text.contains('ayam') || text.contains('ikan') || text.contains('fish')) {
      return 'Daging';
    }
    if (text.contains('susu') || text.contains('milk') || text.contains('dairy') || text.contains('cheese') || text.contains('keju') || text.contains('egg') || text.contains('telur')) {
      return 'Susu & Telur';
    }
    if (text.contains('minum') || text.contains('beverage') || text.contains('water') || text.contains('juice') || text.contains('tea') || text.contains('coffee')) {
      return 'Minuman';
    }
    if (text.contains('bumbu') || text.contains('sauce') || text.contains('spice') || text.contains('condiment')) {
      return 'Bumbu';
    }
    if (text.contains('mie') || text.contains('noodle') || text.contains('biscuit') || text.contains('biskuit') || text.contains('snack') || text.contains('bread') || text.contains('roti')) {
      return 'Makanan Olahan';
    }
    return 'Lainnya';
  }

  /// Ekstraksi default hari expired berdasarkan kategori
  int get estimatedExpiryDays {
    switch (foodGuardCategory) {
      case 'Daging':
        return 3;
      case 'Sayuran':
        return 4;
      case 'Buah':
        return 7;
      case 'Susu & Telur':
        return 10;
      case 'Minuman':
        return 30;
      case 'Makanan Olahan':
        return 90;
      case 'Bumbu':
        return 180;
      default:
        return 14;
    }
  }

  /// Ekstraksi jumlah & satuan dari field quantity
  (String, String) get parsedQuantityAndUnit {
    final qty = quantity?.trim() ?? '';
    if (qty.isEmpty) return ('1', 'pcs');
    final match = RegExp(r'^(\d+(?:\.\d+)?)\s*([a-zA-Z]+)?').firstMatch(qty);
    if (match != null) {
      return (match.group(1) ?? '1', match.group(2) ?? 'pcs');
    }
    return ('1', qty);
  }
}

/// Service REST API untuk berinteraksi dengan database Open Food Facts
class FoodApiService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';

  /// 1. Ambil detail produk berdasarkan Barcode
  /// Endpoint: https://world.openfoodfacts.org/api/v0/product/{barcode}.json
  static Future<FoodApiProduct?> getProductByBarcode(String barcode) async {
    final cleanCode = barcode.trim();
    if (cleanCode.isEmpty) return null;

    final uri = Uri.parse('$_baseUrl/api/v0/product/$cleanCode.json');
    try {
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'FoodGuard-Flutter-UTS/1.0 (contact: student@undiksha.ac.id)',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final productJson = data['product'] as Map<String, dynamic>;
          productJson['code'] ??= cleanCode;
          return FoodApiProduct.fromJson(productJson);
        }
      }
    } catch (e) {
      debugPrint('[FoodApiService] Error fetching barcode $cleanCode: $e');
    }
    return null;
  }

  /// 2. Cari daftar produk berdasarkan Nama / Kata Kunci
  /// Endpoint: https://world.openfoodfacts.org/cgi/search.pl?search_terms={query}&search_simple=1&action=process&json=1&page_size=15
  static Future<List<FoodApiProduct>> searchProducts(String query, {int pageSize = 15}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return getPresetPopularProducts();
    }

    final uri = Uri.parse(
      '$_baseUrl/cgi/search.pl?search_terms=${Uri.encodeComponent(cleanQuery)}&search_simple=1&action=process&json=1&page_size=$pageSize',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'FoodGuard-Flutter-UTS/1.0 (contact: student@undiksha.ac.id)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic>? productsJson = data['products'] as List<dynamic>?;
        if (productsJson != null && productsJson.isNotEmpty) {
          final list = productsJson
              .map((p) => FoodApiProduct.fromJson(p as Map<String, dynamic>))
              .where((item) => item.productName.isNotEmpty && item.productName != 'Produk Makanan')
              .toList();

          if (list.isNotEmpty) {
            return list;
          }
        }
      }
    } catch (e) {
      debugPrint('[FoodApiService] Error searching query "$cleanQuery": $e');
    }

    // Fallback: Filter rekomendasi lokal jika API offline atau hasil kosong
    final queryLower = cleanQuery.toLowerCase();
    return getPresetPopularProducts().where((item) {
      return item.productName.toLowerCase().contains(queryLower) ||
          (item.brands?.toLowerCase().contains(queryLower) ?? false) ||
          item.foodGuardCategory.toLowerCase().contains(queryLower);
    }).toList();
  }

  /// Koleksi produk makanan populer rekomendasi awal
  static List<FoodApiProduct> getPresetPopularProducts() {
    return const [
      FoodApiProduct(
        barcode: '8991002101345',
        productName: 'Ultra Milk Susu UHT Rasa Cokelat',
        brands: 'Ultra Jaya',
        categories: 'Beverages, Dairies, Milks, Chocolate milks',
        quantity: '250 ml',
        imageUrl: 'https://images.openfoodfacts.org/images/products/899/100/210/1345/front_en.11.400.jpg',
      ),
      FoodApiProduct(
        barcode: '8991002101116',
        productName: 'Ultra Milk Plain Susu UHT Segar',
        brands: 'Ultra Jaya',
        categories: 'Dairies, Milks, Fresh Milk',
        quantity: '1000 ml',
        imageUrl: 'https://images.openfoodfacts.org/images/products/899/100/210/1116/front_en.11.400.jpg',
      ),
      FoodApiProduct(
        barcode: '8992388111015',
        productName: 'Indomie Mi Goreng Spesial',
        brands: 'Indofood',
        categories: 'Noodles, Instant noodles',
        quantity: '85 g',
        imageUrl: 'https://images.openfoodfacts.org/images/products/899/238/811/1015/front_id.10.400.jpg',
      ),
      FoodApiProduct(
        barcode: '8992753612019',
        productName: 'Sari Roti Tawar Spesial Gandum',
        brands: 'Sari Roti',
        categories: 'Plant-based foods, Breads, Sliced breads',
        quantity: '370 g',
        imageUrl: 'https://images.openfoodfacts.org/images/products/899/275/361/2019/front_id.15.400.jpg',
      ),
      FoodApiProduct(
        barcode: '8998866200234',
        productName: 'Bango Kecap Manis Kedelai Hitam',
        brands: 'Bango',
        categories: 'Sauces, Soy sauces, Sweet soy sauce',
        quantity: '550 ml',
        imageUrl: 'https://images.openfoodfacts.org/images/products/899/886/620/0234/front_id.7.400.jpg',
      ),
      FoodApiProduct(
        barcode: '8993175535111',
        productName: 'Kraft Keju Cheddar All-in-1',
        brands: 'Kraft',
        categories: 'Dairies, Cheeses, Cheddar cheeses',
        quantity: '165 g',
        imageUrl: 'https://images.openfoodfacts.org/images/products/899/317/553/5111/front_id.8.400.jpg',
      ),
      FoodApiProduct(
        barcode: '8996001301018',
        productName: 'Aqua Air Mineral Pegunungan',
        brands: 'Danone Aqua',
        categories: 'Beverages, Waters, Spring waters',
        quantity: '600 ml',
        imageUrl: 'https://images.openfoodfacts.org/images/products/899/600/130/1018/front_id.12.400.jpg',
      ),
      FoodApiProduct(
        barcode: '8992775210118',
        productName: 'Telur Ayam Negeri Fresh Omega 3',
        brands: 'NutriEgg',
        categories: 'Eggs, Fresh Eggs',
        quantity: '10 butir',
      ),
      FoodApiProduct(
        barcode: '8991234567890',
        productName: 'Daging Ayam Fillet Dada Segar',
        brands: 'FreshFarm',
        categories: 'Meats, Poultry, Chickens, Chicken breasts',
        quantity: '500 g',
      ),
      FoodApiProduct(
        barcode: '8998765432109',
        productName: 'Sayur Bayam Hijau Hidroponik',
        brands: 'GreenFresh',
        categories: 'Plant-based foods, Vegetables, Spinaches',
        quantity: '250 g',
      ),
    ];
  }
}
