import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/barcode_service.dart';

/// Layar pemindai barcode kamera menggunakan paket mobile_scanner
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late final MobileScannerController _controller;
  bool _isScanned = false;
  bool _isTorchOn = false;
  CameraFacing _cameraFacing = CameraFacing.back;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue ?? barcode.displayValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _isScanned = true);
        Navigator.pop(context, code);
        break;
      }
    }
  }

  void _manualInputDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.keyboard_alt_outlined, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Input Barcode Manual'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan nomor barcode produk secara manual jika kamera tidak dapat memindai:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Contoh: 8992388111015',
                prefixIcon: Icon(Icons.qr_code),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = textController.text.trim();
              if (val.isNotEmpty) {
                Navigator.pop(ctx);
                Navigator.pop(context, val);
              }
            },
            child: const Text('Gunakan'),
          ),
        ],
      ),
    );
  }

  void _showDemoBarcodeSheet() {
    final demoList = BarcodeService.demoProducts;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 12),
              const Text(
                'Pilih Contoh Barcode Demo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Text(
                'Uji coba fitur auto-fill dengan barcode bahan makanan populer:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: demoList.length,
                  separatorBuilder: (_, unused) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final item = demoList[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: const Icon(Icons.shopping_bag, color: Color(0xFF2E7D32)),
                      ),
                      title: Text(
                        item.nama,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        '${item.kategori} • ${item.barcode}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context, item.barcode);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        elevation: 0,
        title: const Text(
          'Scan Barcode Bahan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Senter',
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? Colors.yellow : Colors.white,
            ),
            onPressed: () async {
              await _controller.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
          ),
          IconButton(
            tooltip: 'Ganti Kamera',
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () async {
              await _controller.switchCamera();
              setState(() {
                _cameraFacing = _cameraFacing == CameraFacing.back
                    ? CameraFacing.front
                    : CameraFacing.back;
              });
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Kamera Viewfinder
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak dapat mengakses kamera: ${error.errorDetails?.message ?? error.toString()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _manualInputDialog,
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Input Barcode Manual'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Scanning Overlay Box
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2E7D32), width: 3),
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
              ),
              child: Stack(
                children: [
                  // Corner accents
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(width: 24, height: 4, color: Colors.white),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(width: 4, height: 24, color: Colors.white),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(width: 24, height: 4, color: Colors.white),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(width: 4, height: 24, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(width: 24, height: 4, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(width: 4, height: 24, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(width: 24, height: 4, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(width: 4, height: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Petunjuk di atas & bawah
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Arahkan kamera ke barcode kemasan produk makanan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),

          // Bottom Action Panel
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        foregroundColor: const Color(0xFF1E293B),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _manualInputDialog,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Input Manual'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _showDemoBarcodeSheet,
                      icon: const Icon(Icons.list_alt, size: 18),
                      label: const Text('Barcode Demo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
