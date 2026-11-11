# 🌿 FoodGuard — Food Expiry Tracker & Waste Prevention

> **Ujian Tengah Semester (UTS) Pemrograman Mobile**  
> **Aplikasi Pemantau Tanggal Kedaluwarsa Bahan Makanan & Pencegah Pemborosan Pangan**

---

## 👨‍🎓 Identitas Mahasiswa
- **Nama**  : Gede Krisna Adi Pramana
- **NIM**   : 2415051036
- **Kelas** : 5B
- **Prodi** : S1 Pendidikan Teknik Informatika (PTI)
- **Mata Kuliah** : Pemrograman Mobile

---

## 📱 Tentang FoodGuard
**FoodGuard** adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu pengguna mencatat, memantau, dan mengelola tanggal kedaluwarsa bahan makanan rumah tangga secara efektif. Dengan integrasi cloud database Supabase, pemindai barcode kamera, dan REST API Open Food Facts global, pengguna dapat mendeteksi serta memanfaatkan bahan makanan sebelum basi atau terbuang sia-sia.

---

## ✨ Fitur Utama

1. **Dashboard & Summary Analytics**:
   - Ringkasan total bahan, bahan aman, hampir expired (≤ 3 hari), dan kedaluwarsa.
   - Peringatan banner *"Perlu Diolah Segera"* untuk konsumsi prioritas.

2. **Manajemen Data CRUD Lengkap**:
   - Tambah bahan makanan baru dengan validasi form lengkap.
   - Edit detail nama, jumlah, satuan, kategori, lokasi simpan, catatan, dan tanggal kedaluwarsa.
   - Hapus bahan dengan dialog konfirmasi keamanan (*Hard Delete*).

3. **Status Konsumsi & Soft Delete**:
   - Status tracking: `tersedia`, `dikonsumsi`, dan `dibuang` (*soft delete*).
   - Riwayat status dapat dipulihkan kembali sewaktu-waktu.

4. **Pemindai Barcode Kemasan (Tahap 17)**:
   - Terintegrasi dengan paket `mobile_scanner`.
   - Mengakses kamera perangkat untuk membaca barcode EAN/UPC kemasan produk pangan.
   - Mendukung flashlight (senter), switch kamera depan/belakang, input barcode manual, dan katalog barcode demo.

5. **Integrasi REST API Open Food Facts (Tahap 13)**:
   - Fetch & parse data produk makanan secara real-time dari API publik Open Food Facts (`world.openfoodfacts.org`).
   - Fitur pencarian produk makanan interaktif dengan pencarian otomatis (*debounce live search*).
   - Auto-fill nama produk, kategori, merek, kuantitas, dan estimasi masa simpan langsung ke formulir.

6. **Desain Responsif (LayoutBuilder)**:
   - Tampilan vertikal *ListView* pada layar kompak ponsel (< 600px).
   - Tampilan multi-kolom *GridView* pada layar tablet atau orientasi landscape (≥ 600px).

7. **Error Handling & Loading States Menyeluruh**:
   - Loading indicator di seluruh layar saat memuat data.
   - Error state dengan pesan jelas dan tombol *"Coba Lagi"*.
   - Widget *Empty State* terarah jika inventaris kosong atau hasil filter tidak ditemukan.

8. **Layar Profil & Pengaturan**:
   - Menampilkan kartu identitas mahasiswa (Nama, NIM, Kelas 5B).
   - Ringkasan statistik aktivitas inventaris.
   - Pengaturan notifikasi, panduan aplikasi, dan dialog tentang aplikasi.

---

## 🏛️ Arsitektur Aplikasi

Aplikasi dibangun mengikuti pola arsitektur bersih (**Clean Architecture & Repository Pattern**):
```
UI (Screens & Reusable Widgets)
       │
       ▼
State Management (ChangeNotifier - BahanProvider)
       │
       ▼
Data Access Layer (BahanRepository)
       │
       ├─────────────────────────┬─────────────────────────┐
       ▼                         ▼                         ▼
SupabaseService           BarcodeService            FoodApiService
(Cloud PostgreSQL)      (Local + Camera)      (Open Food Facts API)
```

---

## 📂 Struktur Direktori

```
lib/
├── main.dart                      # Entry point, tema global, & Supabase init
├── models/
│   └── bahan_makanan.dart         # Model data BahanMakanan & helper expired
├── services/
│   ├── supabase_config.dart       # Konfigurasi URL & Anon Key Supabase
│   ├── supabase_service.dart      # CRUD operations ke Supabase database
│   ├── barcode_service.dart       # Barcode lookup & database lokal
│   └── food_api_service.dart      # Client REST API Open Food Facts
├── repositories/
│   └── bahan_repository.dart     # Abstraksi data access layer (DAL)
├── providers/
│   └── bahan_provider.dart        # State management global (ChangeNotifier)
├── widgets/
│   ├── bahan_card.dart            # Kartu bahan makanan responsif (list & grid)
│   ├── expired_badge.dart         # Badge status warna kedaluwarsa
│   ├── kategori_chip.dart         # Chip pemilih kategori bahan makanan
│   ├── empty_state_widget.dart    # Widget penanganan state kosong & error
│   ├── delete_confirmation_dialog.dart # Dialog konfirmasi penghapusan
│   └── open_food_facts_sheet.dart # Modal bottom sheet pencarian REST API
└── screens/
    ├── home_screen.dart           # Dashboard utama & navigasi tab
    ├── food_list_screen.dart      # Layar daftar inventaris responsif
    ├── food_detail_screen.dart    # Layar rincian detail bahan
    ├── add_food_screen.dart       # Layar formulir tambah bahan
    ├── edit_food_screen.dart      # Layar formulir edit bahan
    ├── barcode_scanner_screen.dart# Layar kamera scanner barcode
    └── profile_screen.dart        # Layar profil mahasiswa & pengaturan
```

---

## 🚀 Panduan Menjalankan Aplikasi

1. **Clone repositori**:
   ```bash
   git clone https://github.com/gedek0815-maker/UTS_2415051036_Gede_Krisna_Adi_Pramana.git
   cd foodguard
   ```

2. **Pasang dependensi**:
   ```bash
   flutter pub get
   ```

3. **Verifikasi analisis kode**:
   ```bash
   flutter analyze
   ```

4. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```

---

## 📌 Riwayat Tahap Pengerjaan (20 Tahap)

| Tahap | Judul Commit | Deskripsi |
| :---: | :--- | :--- |
| **01** | `Initialize FoodGuard Flutter UTS project` | Inisialisasi awal proyek Flutter |
| **02** | `Setup project architecture and folder structure` | Setup folder models, services, repo, provider, widgets, screens |
| **03** | `Add BahanMakanan model with expired helper methods` | Pembuatan data model dan helper kalkulasi kedaluwarsa |
| **04** | `Setup Supabase connection and initialize in main.dart` | Konfigurasi Supabase client dan inisialisasi di main.dart |
| **05** | `Add SupabaseService with CRUD operations` | Operasi Create, Read, Update, Delete ke cloud database |
| **06** | `Add BahanRepository as data access layer` | Implementasi layer repository sebagai perantara |
| **07** | `Implement BahanProvider with ChangeNotifier` | State management global reaktif dengan Provider |
| **08** | `Build app theme, colors, and base UI setup` | Palet warna tema (Forest Green) & konfigurasi font Poppins |
| **09** | `Add reusable widgets: BahanCard, ExpiredBadge, KategoriChip, EmptyState` | Komponen UI modular dan reusable |
| **10** | `Build HomeScreen dashboard with summary cards and bottom navigation` | Dashboard ringkasan inventaris & BottomNavigationBar |
| **11** | `Implement responsive layout using LayoutBuilder for list and grid view` | Desain adaptif ListView dan GridView responsif |
| **12** | `Add FoodDetail screen with navigation and data passing` | Layar detail bahan dan passing data antar screen |
| **13** | `Add AddFoodScreen with form validation and floating action button` | Form penambahan bahan baru & integrasi Open Food Facts |
| **14** | `Add EditFoodScreen and wire edit actions in detail and list screens` | Form pengeditan bahan yang telah tersimpan |
| **15** | `Implement delete confirmation dialog and delete food functionality` | Dialog konfirmasi hapus permanen |
| **16** | `Implement soft delete and food consumption status management` | Status tracking bahan (tersedia, dikonsumsi, dibuang) |
| **17** | `Add barcode scanner feature using mobile_scanner package` | Fitur scan barcode kemasan produk pangan via kamera |
| **18** | `Add loading, error, and empty state handling across all screens` | Penanganan loading spinner, error feedback, dan empty state |
| **19** | `Add Profile screen with app info and settings` | Layar profil mahasiswa (Gede Krisna - 2415051036), info app, & settings |
| **20** | `Refine UI consistency, fix responsive issues, and improve UX` | Polish UI akhir, perbaikan overflow, dan update Kelas 5B |

---

© 2026 Gede Krisna Adi Pramana (NIM: 2415051036) • Pendidikan Teknik Informatika • Undiksha
