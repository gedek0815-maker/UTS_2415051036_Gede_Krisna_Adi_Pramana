import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bahan_makanan.dart';
import '../providers/bahan_provider.dart';
import '../services/barcode_service.dart';
import '../services/food_api_service.dart';
import '../widgets/open_food_facts_sheet.dart';
import 'barcode_scanner_screen.dart';

class AddFoodScreen extends StatefulWidget {
  final String? initialBarcode;
  const AddFoodScreen({super.key, this.initialBarcode});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _satuanController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _catatanController = TextEditingController();

  String _selectedKategori = 'Sayuran';
  DateTime? _tanggalBeli;
  DateTime? _tanggalExpired;
  bool _isLoading = false;

  final List<String> _kategoriList = [
    'Sayuran',
    'Buah',
    'Daging',
    'Susu & Telur',
    'Bumbu',
    'Minuman',
    'Makanan Olahan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialBarcode != null && widget.initialBarcode!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _lookupAndFill(widget.initialBarcode!);
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _satuanController.dispose();
    _lokasiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isExpired) async {
    final initial = isExpired
        ? (_tanggalExpired ?? DateTime.now().add(const Duration(days: 7)))
        : (_tanggalBeli ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isExpired) {
          _tanggalExpired = picked;
        } else {
          _tanggalBeli = picked;
        }
      });
    }
  }

  /// Membuka layar scanner barcode dan meng-autofill field form
  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (barcode == null || barcode.trim().isEmpty) return;
    await _lookupAndFill(barcode.trim());
  }

  /// Lookup data barcode dan auto-fill ke form dengan fallback
  Future<void> _lookupAndFill(String barcode) async {
    setState(() => _isLoading = true);

    try {
      final product = await BarcodeService.lookupProduct(barcode);
      if (!mounted) return;

      if (product.isFound) {
        // Auto-fill nama & info produk dari hasil scan
        setState(() {
          _namaController.text = product.nama;
          if (_kategoriList.contains(product.kategori)) {
            _selectedKategori = product.kategori;
          }
          _jumlahController.text = product.jumlah;
          _satuanController.text = product.satuan;
          _lokasiController.text = product.lokasiSimpan;
          _tanggalExpired = DateTime.now().add(Duration(days: product.defaultExpiryDays));

          final note = product.catatan != null && product.catatan!.isNotEmpty
              ? product.catatan!
              : 'Barcode: ${product.barcode}';
          _catatanController.text = note;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ditemukan: ${product.nama}! Data terisi otomatis 🎉',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Fallback jika produk tidak ditemukan: catat barcode & infokan user
        setState(() {
          final existing = _catatanController.text.trim();
          _catatanController.text = existing.isEmpty
              ? 'Barcode: $barcode'
              : '$existing\nBarcode: $barcode';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Barcode ($barcode) tidak ditemukan. Disimpan di Catatan, silakan lengkapi nama bahan.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFF57C00),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses data barcode: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Membuka pencarian Open Food Facts REST API dan auto-fill ke form
  Future<void> _searchOpenFoodFacts() async {
    final FoodApiProduct? product = await OpenFoodFactsSearchSheet.show(context);
    if (product == null || !mounted) return;

    final parsedQty = product.parsedQuantityAndUnit;
    final brandPrefix = product.brands != null && product.brands!.isNotEmpty
        ? '${product.brands} - '
        : '';

    setState(() {
      _namaController.text = '$brandPrefix${product.productName}';
      if (_kategoriList.contains(product.foodGuardCategory)) {
        _selectedKategori = product.foodGuardCategory;
      }
      _jumlahController.text = parsedQty.$1;
      _satuanController.text = parsedQty.$2;
      _tanggalExpired = DateTime.now().add(Duration(days: product.estimatedExpiryDays));

      final note = 'Barcode: ${product.barcode}\nMerek: ${product.brands ?? '-'}\nSumber: Open Food Facts API';
      _catatanController.text = note;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Data "${product.productName}" berhasil diisi dari Open Food Facts! 🎉',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalExpired == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal expired harus diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final qty = _jumlahController.text.trim().isNotEmpty
        ? _jumlahController.text.trim()
        : '1';
    final sat = _satuanController.text.trim().isNotEmpty
        ? _satuanController.text.trim()
        : 'pcs';

    final bahan = BahanMakanan(
      id: '',
      nama: _namaController.text.trim(),
      kategori: _selectedKategori,
      tanggalBeli: _tanggalBeli ?? DateTime.now(),
      tanggalExpired: _tanggalExpired!,
      lokasiSimpan: _lokasiController.text.trim().isNotEmpty
          ? _lokasiController.text.trim()
          : 'Lemari',
      jumlah: '$qty $sat',
      catatan: _catatanController.text.trim().isNotEmpty
          ? _catatanController.text.trim()
          : null,
      status: 'tersedia',
    );

    try {
      final provider = context.read<BahanProvider>();
      await provider.addBahan(bahan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${bahan.nama} berhasil ditambahkan! 🎉'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Bahan Makanan'),
        actions: [
          IconButton(
            tooltip: 'Cari di Open Food Facts API',
            icon: const Icon(Icons.travel_explore_rounded, color: Colors.white),
            onPressed: _isLoading ? null : _searchOpenFoodFacts,
          ),
          IconButton(
            tooltip: 'Scan Barcode',
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: _isLoading ? null : _scanBarcode,
          ),
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: const Text(
              'Simpan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pilihan Input Otomatis: Scan Barcode & Open Food Facts REST API
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA5D6A7)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _isLoading ? null : _scanBarcode,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.qr_code_scanner, color: Color(0xFF2E7D32), size: 22),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Scan Barcode',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        'Kamera / demo',
                                        style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _isLoading ? null : _searchOpenFoodFacts,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.public, color: Color(0xFF0284C7), size: 22),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cari di API',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        'Open Food Facts',
                                        style: TextStyle(fontSize: 10, color: Color(0xFF0284C7)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _buildSectionTitle('Informasi Dasar'),
              const SizedBox(height: 8),

              // Nama
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Bahan *',
                  hintText: 'Contoh: Bayam, Ayam, Susu...',
                  prefixIcon: const Icon(Icons.food_bank_outlined),
                  suffixIcon: IconButton(
                    tooltip: 'Cari di Open Food Facts API',
                    icon: const Icon(Icons.travel_explore_rounded, color: Color(0xFF2E7D32)),
                    onPressed: _searchOpenFoodFacts,
                  ),
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                  if (v.trim().length < 2) return 'Nama terlalu pendek';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _selectedKategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _kategoriList.map((k) {
                  return DropdownMenuItem(value: k, child: Text(k));
                }).toList(),
                onChanged: (v) => setState(() => _selectedKategori = v!),
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Jumlah & Lokasi'),
              const SizedBox(height: 8),

              // Jumlah + Satuan
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _jumlahController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        hintText: '1',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v != null && v.isNotEmpty) {
                          if (int.tryParse(v) == null) return 'Angka saja';
                          if (int.parse(v) <= 0) return 'Min 1';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _satuanController,
                      decoration: const InputDecoration(
                        labelText: 'Satuan',
                        hintText: 'pcs, kg, liter...',
                        prefixIcon: Icon(Icons.scale_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lokasi Simpan
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Simpan',
                  hintText: 'Kulkas, Lemari, Freezer...',
                  prefixIcon: Icon(Icons.kitchen_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Tanggal'),
              const SizedBox(height: 8),

              // Tanggal Beli
              _buildDateTile(
                label: 'Tanggal Beli',
                icon: Icons.shopping_cart_outlined,
                date: _tanggalBeli,
                onTap: () => _pickDate(context, false),
              ),
              const SizedBox(height: 12),

              // Tanggal Expired
              _buildDateTile(
                label: 'Tanggal Expired *',
                icon: Icons.event_busy_outlined,
                date: _tanggalExpired,
                onTap: () => _pickDate(context, true),
                isRequired: true,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Catatan (Opsional)'),
              const SizedBox(height: 8),

              TextFormField(
                controller: _catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Tambahkan catatan khusus...',
                  prefixIcon: Icon(Icons.note_outlined),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Bahan'),
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
    );
  }

  Widget _buildDateTile({
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    final hasDate = date != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: (isRequired && !hasDate) ? Colors.red : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: hasDate ? Colors.green : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                      color: hasDate ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
