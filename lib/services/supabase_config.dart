import 'package:supabase_flutter/supabase_flutter.dart';

/// Konfigurasi koneksi Supabase untuk FoodGuard.
/// Ganti [supabaseUrl] dan [supabaseAnonKey] dengan kredensial proyek Supabase Anda.
/// (Dapat ditemukan di Supabase Dashboard -> Project Settings -> API)
class SupabaseConfig {
  static const String supabaseUrl = 'https://kffkooavwdswvjkbgisr.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_0cN9n6vOmgMwmrrWPGd3bQ_lKOJULbv';

  /// Helper untuk mengakses SupabaseClient instance
  static SupabaseClient get client => Supabase.instance.client;
}

