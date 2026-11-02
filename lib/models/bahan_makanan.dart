class BahanMakanan {
  final String id;
  final String nama;
  final String kategori;
  final DateTime tanggalBeli;
  final DateTime tanggalExpired;
  final String lokasiSimpan;
  final String jumlah;
  final String? catatan;
  final String? fotoUrl;
  final String status;
  final DateTime createdAt;

  BahanMakanan({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.tanggalBeli,
    required this.tanggalExpired,
    required this.lokasiSimpan,
    required this.jumlah,
    this.catatan,
    this.fotoUrl,
    this.status = 'tersedia',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Hitung sisa hari sebelum expired (berdasarkan perbandingan tanggal kalender)
  int get sisaHari {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      tanggalExpired.year,
      tanggalExpired.month,
      tanggalExpired.day,
    );
    return expiry.difference(today).inDays;
  }

  // Status warna berdasarkan sisa hari
  // 'expired' (< 0 hari), 'bahaya' (0-3 hari), 'warning' (4-7 hari), 'aman' (> 7 hari)
  String get statusWarna {
    if (sisaHari < 0) return 'expired';
    if (sisaHari <= 3) return 'bahaya';
    if (sisaHari <= 7) return 'warning';
    return 'aman';
  }

  // Label status expired untuk kemudahan UI
  String get statusLabel {
    if (sisaHari < 0) return 'Expired (${sisaHari.abs()} hari lalu)';
    if (sisaHari == 0) return 'Expired hari ini!';
    if (sisaHari <= 3) return '$sisaHari hari lagi (Segera gunakan)';
    if (sisaHari <= 7) return '$sisaHari hari lagi';
    return '$sisaHari hari lagi';
  }

  // Helper check status expired
  bool get isExpired => sisaHari < 0;
  bool get isHampirExpired => sisaHari >= 0 && sisaHari <= 3;

  // Konversi JSON Supabase → Object Dart
  factory BahanMakanan.fromJson(Map<String, dynamic> json) {
    return BahanMakanan(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? 'Lainnya',
      tanggalBeli: json['tanggal_beli'] != null
          ? DateTime.parse(json['tanggal_beli'].toString())
          : DateTime.now(),
      tanggalExpired: json['tanggal_expired'] != null
          ? DateTime.parse(json['tanggal_expired'].toString())
          : DateTime.now(),
      lokasiSimpan: json['lokasi_simpan']?.toString() ?? 'Kulkas',
      jumlah: json['jumlah']?.toString() ?? '1',
      catatan: json['catatan']?.toString(),
      fotoUrl: json['foto_url']?.toString(),
      status: json['status']?.toString() ?? 'tersedia',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  // Konversi Object Dart → JSON untuk Supabase (insert / update)
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kategori': kategori,
      'tanggal_beli': tanggalBeli.toIso8601String().split('T')[0],
      'tanggal_expired': tanggalExpired.toIso8601String().split('T')[0],
      'lokasi_simpan': lokasiSimpan,
      'jumlah': jumlah,
      'catatan': catatan,
      'foto_url': fotoUrl,
      'status': status,
    };
  }

  // CopyWith untuk memudahkan update state lokal dan immutability
  BahanMakanan copyWith({
    String? id,
    String? nama,
    String? kategori,
    DateTime? tanggalBeli,
    DateTime? tanggalExpired,
    String? lokasiSimpan,
    String? jumlah,
    String? catatan,
    String? fotoUrl,
    String? status,
    DateTime? createdAt,
  }) {
    return BahanMakanan(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      tanggalBeli: tanggalBeli ?? this.tanggalBeli,
      tanggalExpired: tanggalExpired ?? this.tanggalExpired,
      lokasiSimpan: lokasiSimpan ?? this.lokasiSimpan,
      jumlah: jumlah ?? this.jumlah,
      catatan: catatan ?? this.catatan,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
