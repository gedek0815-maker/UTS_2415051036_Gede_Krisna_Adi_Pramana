import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food_api_product.dart';
import '../services/food_api_service.dart';

/// Modal Bottom Sheet untuk mencari & memilih produk dari Open Food Facts REST API
class OpenFoodFactsSearchSheet extends StatefulWidget {
  const OpenFoodFactsSearchSheet({super.key});

  /// Helper statis untuk menampilkan bottom sheet
  static Future<FoodApiProduct?> show(BuildContext context) {
    return showModalBottomSheet<FoodApiProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const OpenFoodFactsSearchSheet(),
    );
  }

  @override
  State<OpenFoodFactsSearchSheet> createState() => _OpenFoodFactsSearchSheetState();
}

class _OpenFoodFactsSearchSheetState extends State<OpenFoodFactsSearchSheet> {
  final _searchController = TextEditingController();
  List<FoodApiProduct> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  Timer? _debounceTimer;

  final List<String> _quickKeywords = [
    'Susu',
    'Indomie',
    'Roti',
    'Biskuit',
    'Keju',
    'Telur',
    'Aqua',
    'Daging',
    'Bayam',
  ];

  @override
  void initState() {
    super.initState();
    // Tampilkan rekomendasi produk populer langsung saat sheet dibuka
    _searchResults = FoodApiService.getPresetPopularProducts();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Debounce search saat pengguna mengetik di textfield
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final clean = query.trim();

    if (clean.isEmpty) {
      setState(() {
        _searchResults = FoodApiService.getPresetPopularProducts();
        _hasSearched = false;
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    // Debounce 400ms agar tidak spam API setiap ketikan
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(clean);
    });
  }

  Future<void> _performSearch(String query) async {
    _debounceTimer?.cancel();
    final clean = query.trim();
    if (clean.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final results = await FoodApiService.searchProducts(clean);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal menghubungi Open Food Facts API: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.public, color: Color(0xFF2E7D32), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cari di Open Food Facts API',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'REST API database produk makanan global',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field dengan onChanged pencarian otomatis
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            onSubmitted: _performSearch,
            decoration: InputDecoration(
              hintText: 'Ketik nama makanan (misal: susu, indomie, roti)...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2E7D32)),
                    onPressed: () => _performSearch(_searchController.text),
                  ),
                ],
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),

          // Quick Keywords Chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickKeywords.length,
              separatorBuilder: (_, unused) => const SizedBox(width: 6),
              itemBuilder: (ctx, index) {
                final kw = _quickKeywords[index];
                return ActionChip(
                  label: Text(kw, style: const TextStyle(fontSize: 12)),
                  backgroundColor: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () {
                    _searchController.text = kw;
                    _performSearch(kw);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Judul bagian hasil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                !_hasSearched
                    ? 'Rekomendasi Produk Populer'
                    : 'Hasil Pencarian (${_searchResults.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E7D32)),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Konten Hasil Pencarian
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 12),
            Text(
              'Menghubungi Open Food Facts REST API...',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.orange),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _performSearch(_searchController.text),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 54, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'Tidak ada produk ditemukan untuk "${_searchController.text}"',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (_, unused) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stack) => const Icon(
                        Icons.fastfood,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  )
                : const Icon(Icons.fastfood, color: Color(0xFF2E7D32)),
          ),
          title: Text(
            product.productName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.brands != null && product.brands!.isNotEmpty)
                Text(
                  'Merek: ${product.brands}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.foodGuardCategory,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  if (product.quantity != null && product.quantity!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      product.quantity!,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(60, 32),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.pop(context, product);
            },
            child: const Text('Pilih'),
          ),
        );
      },
    );
  }
}
