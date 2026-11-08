import 'package:supabase_flutter/supabase_flutter.dart';

/// Konfigurasi koneksi Supabase untuk FoodGuard.
/// Ganti [supabaseUrl] dan [supabaseAnonKey] dengan kredensial proyek Supabase Anda.
/// (Dapat ditemukan di Supabase Dashboard -> Project Settings -> API)
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Helper untuk mengakses SupabaseClient instance
  static SupabaseClient get client => Supabase.instance.client;
}

