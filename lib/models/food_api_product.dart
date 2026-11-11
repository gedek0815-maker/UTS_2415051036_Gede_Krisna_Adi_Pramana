/// Model representasi data produk dari Open Food Facts REST API.
/// Dipisahkan ke dalam models/ agar screens tidak perlu import services/ secara langsung.
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
    if (text.contains('daging') || text.contains('meat') || text.contains('chicken') ||
        text.contains('ayam') || text.contains('ikan') || text.contains('fish')) {
      return 'Daging';
    }
    if (text.contains('susu') || text.contains('milk') || text.contains('dairy') ||
        text.contains('cheese') || text.contains('keju') || text.contains('egg') ||
        text.contains('telur')) {
      return 'Susu & Telur';
    }
    if (text.contains('minum') || text.contains('beverage') || text.contains('water') ||
        text.contains('juice') || text.contains('tea') || text.contains('coffee')) {
      return 'Minuman';
    }
    if (text.contains('bumbu') || text.contains('sauce') || text.contains('spice') ||
        text.contains('condiment')) {
      return 'Bumbu';
    }
    if (text.contains('mie') || text.contains('noodle') || text.contains('biscuit') ||
        text.contains('biskuit') || text.contains('snack') || text.contains('bread') ||
        text.contains('roti')) {
      return 'Makanan Olahan';
    }
    return 'Lainnya';
  }

  /// Estimasi hari expired berdasarkan kategori
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
