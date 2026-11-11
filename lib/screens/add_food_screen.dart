import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bahan_makanan.dart';
import '../models/food_api_product.dart';
import '../providers/bahan_provider.dart';
import '../services/barcode_service.dart';
import '../widgets/open_food_facts_sheet.dart';
import 'barcode_scanner_screen.dart';

/// Screen: AddFoodScreen (Tahap 17 & Refactor Mockup 2)
/// Menampilkan form penambahan bahan makanan lengkap dengan:
/// - AppBar hijau dengan tombol Back & Home
/// - 2 Tombol aksi atas: Scan Barcode & Cari di API
/// - Struktur form beraksen garis vertikal hijau
/// - 2 Custom Modal Bottom Sheet (Pilih Kategori & Pilih Tanggal)
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

  String _selectedKategori = 'Sayur-Sayuran';
  DateTime? _tanggalBeli;
  DateTime? _tanggalExpired;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _kategoriOptions = [
    {
      'title': 'Sayur-Sayuran',
      'icon': Icons.eco_rounded,
      'color': Color(0xFF2E7D32),
    },
    {
      'title': 'Buah-Buahan',
      'icon': Icons.apple_rounded,
      'color': Color(0xFFE53935),
    },
    {
      'title': 'Daging & Olahan',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFD84315),
    },
    {
      'title': 'Produk Susu',
      'icon': Icons.local_drink_rounded,
      'color': Color(0xFF0284C7),
    },
    {
      'title': 'Bahan Pokok',
      'icon': Icons.bakery_dining_rounded,
      'color': Color(0xFFB57C34),
    },
    {
      'title': 'Minuman',
      'icon': Icons.local_cafe_rounded,
      'color': Color(0xFF00897B),
    },
    {
      'title': 'Lainnya',
      'icon': Icons.more_horiz_rounded,
      'color': Color(0xFF64748B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tanggalBeli = DateTime.now();
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

  String _formatDisplayDate(DateTime? date) {
    if (date == null) return 'Pilih Tanggal';
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Membuka scanner barcode
  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (barcode == null || barcode.trim().isEmpty) return;
    await _lookupAndFill(barcode.trim());
  }

  /// Lookup data barcode dan auto-fill ke form
  Future<void> _lookupAndFill(String barcode) async {
    setState(() => _isLoading = true);

    try {
      final product = await BarcodeService.lookupProduct(barcode);
      if (!mounted) return;

      if (product.isFound) {
        setState(() {
          _namaController.text = product.nama;
          // Normalisasi kategori
          final matchedKat = _kategoriOptions.firstWhere(
            (k) => (k['title'] as String).toLowerCase().contains(product.kategori.toLowerCase()),
            orElse: () => _kategoriOptions.first,
          );
          _selectedKategori = matchedKat['title'] as String;
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
          ),
        );
      } else {
        setState(() {
          final existing = _catatanController.text.trim();
          _catatanController.text = existing.isEmpty
              ? 'Barcode: $barcode'
              : '$existing\nBarcode: $barcode';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barcode ($barcode) disimpan di Catatan.'),
            backgroundColor: const Color(0xFFF57C00),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses barcode: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Membuka dialog pencarian Open Food Facts REST API
  Future<void> _searchOpenFoodFacts() async {
    final FoodApiProduct? product = await OpenFoodFactsSearchSheet.show(context);
    if (product == null || !mounted) return;

    final parsedQty = product.parsedQuantityAndUnit;
    final brandPrefix = product.brands != null && product.brands!.isNotEmpty
        ? '${product.brands} - '
        : '';

    setState(() {
      _namaController.text = '$brandPrefix${product.productName}';
      final matchedKat = _kategoriOptions.firstWhere(
        (k) => (k['title'] as String).toLowerCase().contains(product.foodGuardCategory.toLowerCase()),
        orElse: () => _kategoriOptions.first,
      );
      _selectedKategori = matchedKat['title'] as String;
      _jumlahController.text = parsedQty.$1;
      _satuanController.text = parsedQty.$2;
      _tanggalExpired = DateTime.now().add(Duration(days: product.estimatedExpiryDays));

      final note = 'Barcode: ${product.barcode}\nMerek: ${product.brands ?? '-'}\nSumber: Open Food Facts API';
      _catatanController.text = note;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data "${product.productName}" berhasil diisi dari API! 🎉'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Custom Modal Bottom Sheet 1: Pilih Kategori
  Future<void> _showPilihKategoriSheet() async {
    String tempSelected = _selectedKategori;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.grid_view_rounded,
                              color: Color(0xFF2E7D32),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Pilih Kategori',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  'Pilih kategori bahan makanan',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Daftar Pilihan Kategori
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _kategoriOptions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = _kategoriOptions[index];
                            final title = item['title'] as String;
                            final icon = item['icon'] as IconData;
                            final color = item['color'] as Color;
                            final isSelected = tempSelected == title;

                            return GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  tempSelected = title;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE2E8F0),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(icon, color: color, size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF2E7D32),
                                        size: 20,
                                      )
                                    else
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFFCBD5E1),
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Konfirmasi Pilih Kategori
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(ctx, tempSelected),
                          child: const Text(
                            'Pilih Kategori',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedKategori = result;
      });
    }
  }

  /// Custom Modal Bottom Sheet 2: Pilih Tanggal dengan Kalender Bulanan Kustom
  Future<void> _showPilihTanggalSheet(bool isExpired) async {
    DateTime selectedDate = isExpired
        ? (_tanggalExpired ?? DateTime.now().add(const Duration(days: 7)))
        : (_tanggalBeli ?? DateTime.now());

    DateTime viewingMonth = DateTime(selectedDate.year, selectedDate.month, 1);

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            const monthNames = [
              'Januari',
              'Februari',
              'Maret',
              'April',
              'Mei',
              'Juni',
              'Juli',
              'Agustus',
              'September',
              'Oktober',
              'November',
              'Desember',
            ];

            final daysInMonth = DateTime(viewingMonth.year, viewingMonth.month + 1, 0).day;
            final firstWeekday = DateTime(viewingMonth.year, viewingMonth.month, 1).weekday; // 1 = Mon

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Color(0xFF2E7D32),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Pilih Tanggal',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  'Pilih tanggal yang sesuai',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Month Navigator: < November 2026 >
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF1E293B)),
                            onPressed: () {
                              setSheetState(() {
                                viewingMonth = DateTime(viewingMonth.year, viewingMonth.month - 1, 1);
                              });
                            },
                          ),
                          Text(
                            '${monthNames[viewingMonth.month - 1]} ${viewingMonth.year}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF1E293B)),
                            onPressed: () {
                              setSheetState(() {
                                viewingMonth = DateTime(viewingMonth.year, viewingMonth.month + 1, 1);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Day of week headers: Sen, Sel, Rab, Kam, Jum, Sab, Min
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _CalendarHeaderCell('Sen'),
                          _CalendarHeaderCell('Sel'),
                          _CalendarHeaderCell('Rab'),
                          _CalendarHeaderCell('Kam'),
                          _CalendarHeaderCell('Jum'),
                          _CalendarHeaderCell('Sab'),
                          _CalendarHeaderCell('Min'),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Calendar Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 35,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                        ),
                        itemBuilder: (context, index) {
                          final dayOffset = index - (firstWeekday - 1);
                          if (dayOffset < 0 || dayOffset >= daysInMonth) {
                            return const SizedBox.shrink();
                          }

                          final dayNumber = dayOffset + 1;
                          final cellDate = DateTime(viewingMonth.year, viewingMonth.month, dayNumber);
                          final isSelected = selectedDate.year == cellDate.year &&
                              selectedDate.month == cellDate.month &&
                              selectedDate.day == cellDate.day;

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                selectedDate = cellDate;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kotak Info Hijau Muda
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tanggal akan digunakan untuk menghitung masa kedaluwarsa.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.5,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Konfirmasi
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(ctx, selectedDate),
                          child: const Text(
                            'Konfirmasi',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        if (isExpired) {
          _tanggalExpired = result;
        } else {
          _tanggalBeli = result;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalExpired == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal kedaluwarsa wajib dipilih!'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final qty = _jumlahController.text.trim().isNotEmpty ? _jumlahController.text.trim() : '1';
    final sat = _satuanController.text.trim().isNotEmpty ? _satuanController.text.trim() : 'pcs';

    final bahan = BahanMakanan(
      id: '',
      nama: _namaController.text.trim(),
      kategori: _selectedKategori,
      tanggalBeli: _tanggalBeli ?? DateTime.now(),
      tanggalExpired: _tanggalExpired!,
      lokasiSimpan: _lokasiController.text.trim().isNotEmpty
          ? _lokasiController.text.trim()
          : 'Kulkas',
      jumlah: '$qty $sat',
      catatan: _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
      status: 'tersedia',
    );

    try {
      final provider = context.read<BahanProvider>();
      await provider.addBahan(bahan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${bahan.nama} berhasil disimpan! 🎉'),
            backgroundColor: const Color(0xFF2E7D32),
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
      backgroundColor: const Color(0xFFF4F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Bahan Makanan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: Colors.white),
            tooltip: 'Ke Beranda',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris Tombol Atas: Scan Barcode (Hijau Muda) & Cari di API (Biru Muda)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _scanBarcode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Color(0xFF2E7D32),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Scan Barcode',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    'Scan produk',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10.5,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _searchOpenFoodFacts,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFBBDEFB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.public_rounded,
                                color: Color(0xFF0284C7),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Cari di API',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    'Dari database',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10.5,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // 1. Informasi Dasar
              _buildSectionHeader('Informasi Dasar'),
              const SizedBox(height: 12),

              // Nama Bahan
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextFormField(
                  controller: _namaController,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Nama Bahan *',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(Icons.inventory_2_outlined, color: Color(0xFF2E7D32), size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2E7D32), size: 20),
                      onPressed: _scanBarcode,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama bahan wajib diisi' : null,
                ),
              ),

              const SizedBox(height: 10),

              // Kategori Selector (Membuka Bottom Sheet "Pilih Kategori")
              GestureDetector(
                onTap: _showPilihKategoriSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category_outlined, color: Color(0xFF2E7D32), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedKategori,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // 2. Jumlah & Lokasi
              _buildSectionHeader('Jumlah & Lokasi'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextFormField(
                        controller: _jumlahController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                        decoration: const InputDecoration(
                          hintText: 'Jumlah',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          prefixIcon: Icon(Icons.tag_rounded, color: Color(0xFF2E7D32), size: 20),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextFormField(
                        controller: _satuanController,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                        decoration: const InputDecoration(
                          hintText: 'Satuan',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFF2E7D32), size: 20),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Lokasi Simpan
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextFormField(
                  controller: _lokasiController,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Lokasi Simpan (Kulkas, Lemari, dll)',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: Icon(Icons.place_outlined, color: Color(0xFF2E7D32), size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // 3. Tanggal
              _buildSectionHeader('Tanggal'),
              const SizedBox(height: 12),

              // Tanggal Beli
              GestureDetector(
                onTap: () => _showPilihTanggalSheet(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart_outlined, color: Color(0xFF2E7D32), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Beli',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Color(0xFF64748B)),
                            ),
                            Text(
                              _formatDisplayDate(_tanggalBeli),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8), size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Tanggal Kadaluarsa (Highlighted dengan Border Merah, Background Merah Muda, Badge Tanda Seru)
              GestureDetector(
                onTap: () => _showPilihTanggalSheet(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEF5350), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFFE53935), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Kadaluarsa *',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE53935),
                              ),
                            ),
                            Text(
                              _formatDisplayDate(_tanggalExpired),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF5350),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // 4. Catatan (Opsional)
              _buildSectionHeader('Catatan (Opsional)'),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextFormField(
                  controller: _catatanController,
                  maxLines: 3,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'Catatan...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.description_outlined, color: Color(0xFF2E7D32), size: 20),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Tombol Bawah Penuh: + Simpan Bahan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          '+ Simpan Bahan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper untuk Judul Grup beraksen garis vertikal hijau di kiri
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _CalendarHeaderCell extends StatelessWidget {
  final String label;
  const _CalendarHeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
