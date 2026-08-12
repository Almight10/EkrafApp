import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ekraf_data.dart';

/// Service connecting to Supabase database for Creative Economy (Ekraf) submissions
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final _client = Supabase.instance.client;
  List<EkrafData> _cache = [];

  int get totalData => _cache.length;
  int get totalVerified => _cache.where((e) => e.status == VerificationStatus.verified).length;
  int get totalPending => _cache.where((e) => e.status == VerificationStatus.pending).length;
  int get totalRejected => _cache.where((e) => e.status == VerificationStatus.rejected).length;

  Map<VerificationStatus, int> getStatsByStatus() {
    return {
      VerificationStatus.pending: totalPending,
      VerificationStatus.verified: totalVerified,
      VerificationStatus.rejected: totalRejected,
    };
  }

  Map<String, int> getStatsBySubSektor() {
    final Map<String, int> stats = {};
    for (var item in _cache) {
      stats[item.subSektor] = (stats[item.subSektor] ?? 0) + 1;
    }
    return stats;
  }

  Future<List<EkrafData>> getAllData() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('ekraf_data')
          .select('*, users:user_id(nama_lengkap, nik, no_hp, email, alamat, kecamatan, kelurahan, foto_url)')
          .order('created_at', ascending: false);

      final list = response.map((map) => EkrafData.fromSupabase(map)).toList();
      _cache = list;
      return list;
    } catch (e) {
      debugPrint('Eror loadData Supabase: $e');
      return [];
    }
  }

  Future<EkrafData?> getById(String id) async {
    try {
      final response = await _client
          .from('ekraf_data')
          .select('*, users:user_id(nama_lengkap, nik, no_hp, email, alamat, kecamatan, kelurahan, foto_url)')
          .eq('id', id)
          .single();
      return EkrafData.fromSupabase(response);
    } catch (e) {
      debugPrint('Eror getById Supabase: $e');
      return null;
    }
  }

  Future<void> addData(EkrafData data) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      final supabaseMap = data.toSupabase(user.id);
      
      // Hapus ID default agar Supabase autogenerate dari schema (gen_random_uuid())
      supabaseMap.remove('id');

      await _client.from('ekraf_data').insert(supabaseMap);
    } catch (e) {
      debugPrint('Eror addData Supabase: $e');
      rethrow;
    }
  }

  Future<void> updateData(EkrafData data) async {
    try {
      final Map<String, dynamic> updateMap = {
        'nama_usaha': data.namaUsaha,
        'sub_sektor': data.subSektor,
        'deskripsi_usaha': data.deskripsiUsaha,
        'tahun_berdiri': data.tahunBerdiri,
        'jumlah_karyawan': data.jumlahKaryawan,
        'omzet_per_bulan': data.omzetPerBulan,
        'haki_types': data.hakiTypes.map((e) => e.name).join(','),
        'nomor_haki': data.nomorHaki,
        'tahun_haki': data.tahunHaki,
        'product_image_paths': data.productImagePaths.join(','),
        'nama_produk_unggulan': data.namaProdukUnggulan,
        'harga_produk': data.hargaProduk,
        'link_marketplace': data.linkMarketplace,
        'status': data.status.name,
        'catatan_admin': data.catatanAdmin,
      };
      await _client.from('ekraf_data').update(updateMap).eq('id', data.id);
    } catch (e) {
      debugPrint('Eror updateData Supabase: $e');
      rethrow;
    }
  }

  Future<void> updateStatus(
    String id,
    VerificationStatus status,
    String? catatan,
  ) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': status.name,
        'catatan_admin': catatan,
        'verified_at': status == VerificationStatus.verified ? DateTime.now().toIso8601String() : null,
      };
      await _client.from('ekraf_data').update(updateData).eq('id', id);
    } catch (e) {
      debugPrint('Eror updateStatus Supabase: $e');
      rethrow;
    }
  }

  Future<void> deleteData(String id) async {
    try {
      await _client.from('ekraf_data').delete().eq('id', id);
    } catch (e) {
      debugPrint('Eror deleteData Supabase: $e');
      rethrow;
    }
  }
}
