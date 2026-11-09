import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bahan_makanan.dart';
import '../providers/bahan_provider.dart';

class EditFoodScreen extends StatefulWidget {
  final BahanMakanan bahan;

  const EditFoodScreen({super.key, required this.bahan});

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _jumlahController;
  late TextEditingController _satuanController;
  late TextEditingController _lokasiController;
  late TextEditingController _catatanController;

  late String _selectedKategori;
  late DateTime _tanggalBeli;
  late DateTime _tanggalExpired;
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
    _namaController = TextEditingController(text: widget.bahan.nama);

    // Parse jumlah & satuan jika ada spasi (e.g., '2 kg')
    final parts = widget.bahan.jumlah.split(' ');
    if (parts.length >= 2) {
      _jumlahController = TextEditingController(text: parts[0]);
      _satuanController = TextEditingController(text: parts.sublist(1).join(' '));
    } else {
      _jumlahController = TextEditingController(text: widget.bahan.jumlah);
      _satuanController = TextEditingController(text: 'pcs');
    }

    _lokasiController = TextEditingController(text: widget.bahan.lokasiSimpan);
    _catatanController = TextEditingController(text: widget.bahan.catatan ?? '');

    // Pastikan kategori ada di list atau fallback
    if (_kategoriList.contains(widget.bahan.kategori)) {
      _selectedKategori = widget.bahan.kategori;
    } else {
      _selectedKategori = 'Lainnya';
    }

    _tanggalBeli = widget.bahan.tanggalBeli;
    _tanggalExpired = widget.bahan.tanggalExpired;
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
    final initial = isExpired ? _tanggalExpired : _tanggalBeli;

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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final qty = _jumlahController.text.trim().isNotEmpty
        ? _jumlahController.text.trim()
        : '1';
    final sat = _satuanController.text.trim().isNotEmpty
        ? _satuanController.text.trim()
        : 'pcs';

    final updated = widget.bahan.copyWith(
      nama: _namaController.text.trim(),
      kategori: _selectedKategori,
      tanggalBeli: _tanggalBeli,
      tanggalExpired: _tanggalExpired,
      lokasiSimpan: _lokasiController.text.trim().isNotEmpty
          ? _lokasiController.text.trim()
          : 'Lemari',
      jumlah: '$qty $sat',
      catatan: _catatanController.text.trim().isNotEmpty
          ? _catatanController.text.trim()
          : null,
    );

    try {
      final provider = context.read<BahanProvider>();
      await provider.updateBahan(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updated.nama} berhasil diperbarui! ✨'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui: $e'),
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
        title: const Text('Edit Bahan Makanan'),
        actions: [
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
              _buildSectionTitle('Informasi Dasar'),
              const SizedBox(height: 8),

              // Nama
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Bahan *',
                  hintText: 'Contoh: Bayam, Ayam, Susu...',
                  prefixIcon: Icon(Icons.food_bank_outlined),
                  border: OutlineInputBorder(),
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
                initialValue: _selectedKategori,
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
                      : const Icon(Icons.check_rounded),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Perbarui Bahan'),
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
    required DateTime date,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isRequired ? Colors.grey : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
