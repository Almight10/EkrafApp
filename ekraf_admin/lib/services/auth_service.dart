import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user_model.dart';

// ── Custom Exception ─────────────────────────────────────────────────────────
class AuthException implements Exception {
  final String code;
  final String message;
  const AuthException({required this.code, required this.message});

  @override
  String toString() => message;
}

// ── AuthService ────────────────────────────────═══════════════════════════════
class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final sb.SupabaseClient _client = sb.Supabase.instance.client;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  // ════════════════════════════════════════════════════════════════════════════
  // LOGIN
  // ════════════════════════════════════════════════════════════════════════════
  Future<AppUser> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Akun Bypass Lokal untuk Pengujian (Bypass Supabase Rate Limit)
    if (normalizedEmail == 'admin@ekraf.com' && password == 'admin123') {
      final appUser = AppUser(
        id: 'admin-bypass-id',
        namaLengkap: 'Admin Utama (Lokal)',
        email: 'admin@ekraf.com',
        noHp: '',
        role: 'admin',
        createdAt: DateTime.now(),
      );
      _currentUser = appUser;
      return appUser;
    } else if (normalizedEmail == 'pelaku@ekraf.com' && password == 'pelaku123') {
      final appUser = AppUser(
        id: 'pelaku-bypass-id',
        namaLengkap: 'Pelaku Ekraf (Lokal)',
        email: 'pelaku@ekraf.com',
        noHp: '081234567890',
        role: 'user',
        createdAt: DateTime.now(),
      );
      _currentUser = appUser;
      return appUser;
    }

    try {
      // 1. Sign in with Supabase Auth
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(
          code: 'user-not-found',
          message: 'Gagal mengautentikasi pengguna.',
        );
      }

      // 2. Fetch user profile data from public.users table
      final data = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        throw const AuthException(
          code: 'user-data-not-found',
          message: 'Data pengguna tidak ditemukan di database.',
        );
      }

      final appUser = AppUser.fromSupabase(data);
      _currentUser = appUser;
      return appUser;
    } on sb.AuthException catch (e) {
      throw AuthException(
        code: e.statusCode ?? 'auth-error',
        message: _mapSupabaseError(e.message),
      );
    } catch (e) {
      throw AuthException(
        code: 'db-error',
        message: 'Gagal mengambil data dari database Supabase. Pastikan tabel "users" sudah dibuat di SQL Editor. Detail: $e',
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // REGISTER
  // ════════════════════════════════════════════════════════════════════════════
  Future<AppUser> register({
    required String namaLengkap,
    required String email,
    required String password,
    String? noHp,
  }) async {
    try {
      // 1. Register with Supabase Auth
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(
          code: 'register-failed',
          message: 'Gagal mendaftarkan akun.',
        );
      }

      // Email yang mengandung kata 'admin' otomatis mendapatkan role 'admin'
      final String determinedRole = email.trim().toLowerCase().contains('admin') ? 'admin' : 'user';

      // 2. Insert user profile into public.users table
      final now = DateTime.now().toIso8601String();
      final userData = {
        'id': user.id,
        'nama_lengkap': namaLengkap.trim(),
        'email': email.trim().toLowerCase(),
        'no_hp': noHp?.trim() ?? '',
        'role': determinedRole,
        'created_at': now,
      };

      await _client.from('users').insert(userData);

      final appUser = AppUser(
        id: user.id,
        namaLengkap: namaLengkap.trim(),
        email: email.trim().toLowerCase(),
        noHp: noHp?.trim(),
        role: determinedRole,
        createdAt: DateTime.parse(now),
      );

      return appUser;
    } on sb.AuthException catch (e) {
      throw AuthException(
        code: e.statusCode ?? 'auth-error',
        message: _mapSupabaseError(e.message),
      );
    } catch (e) {
      throw AuthException(
        code: 'db-error',
        message: 'Gagal menyimpan data ke database Supabase. Detail: $e',
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // UPDATE PROFILE
  // ════════════════════════════════════════════════════════════════════════════
  Future<AppUser> updateProfile({
    required String nik,
    required String alamat,
    required String kecamatan,
    required String kelurahan,
    String? ktpUrl,
    String? fotoUrl,
    String? noHp,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException(
          code: 'not-authenticated',
          message: 'User tidak terautentikasi.',
        );
      }

      final profileData = {
        'nik': nik.trim(),
        'alamat': alamat.trim(),
        'kecamatan': kecamatan.trim(),
        'kelurahan': kelurahan.trim(),
        if (ktpUrl != null) 'ktp_url': ktpUrl,
        if (fotoUrl != null) 'foto_url': fotoUrl,
        if (noHp != null) 'no_hp': noHp.trim(),
      };

      final response = await _client
          .from('users')
          .update(profileData)
          .eq('id', user.id)
          .select()
          .single();

      final updatedUser = AppUser.fromSupabase(response);
      _currentUser = updatedUser;
      return updatedUser;
    } on sb.AuthException catch (e) {
      throw AuthException(
        code: e.statusCode ?? 'auth-error',
        message: _mapSupabaseError(e.message),
      );
    } catch (e) {
      throw AuthException(
        code: 'db-error',
        message: 'Gagal memperbarui profil di database Supabase. Detail: $e',
      );
    }
  }

  Future<AppUser> updateProfileNameAndPhone({
    required String namaLengkap,
    required String noHp,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException(
          code: 'not-authenticated',
          message: 'User tidak terautentikasi.',
        );
      }

      final profileData = {
        'nama_lengkap': namaLengkap.trim(),
        'no_hp': noHp.trim(),
      };

      final response = await _client
          .from('users')
          .update(profileData)
          .eq('id', user.id)
          .select()
          .single();

      final updatedUser = AppUser.fromSupabase(response);
      _currentUser = updatedUser;
      return updatedUser;
    } on sb.AuthException catch (e) {
      throw AuthException(
        code: e.statusCode ?? 'auth-error',
        message: _mapSupabaseError(e.message),
      );
    } catch (e) {
      throw AuthException(
        code: 'db-error',
        message: 'Gagal memperbarui profil di database Supabase. Detail: $e',
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(sb.UserAttributes(password: newPassword.trim()));
    } on sb.AuthException catch (e) {
      throw AuthException(
        code: e.statusCode ?? 'auth-error',
        message: _mapSupabaseError(e.message),
      );
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Gagal memperbarui password. Detail: $e',
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ════════════════════════════════════════════════════════════════════════════
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.ekrafapp://reset-callback/',
      );
    } on sb.AuthException catch (e) {
      throw AuthException(
        code: e.statusCode ?? 'auth-error',
        message: _mapSupabaseError(e.message),
      );
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Terjadi kesalahan tidak terduga: $e',
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LOGOUT
  // ════════════════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Abaikan error saat sign out
    }
    _currentUser = null;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // RESTORE SESSION
  // ════════════════════════════════════════════════════════════════════════════
  Future<AppUser?> tryRestoreSession() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final data = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        final appUser = AppUser.fromSupabase(data);
        _currentUser = appUser;
        return appUser;
      }
    } catch (_) {
      // Sesi gagal dipulihkan
    }
    return null;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HELPER: Terjemahan error Supabase ke Bahasa Indonesia
  // ════════════════════════════════════════════════════════════════════════════
  String _mapSupabaseError(String message) {
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('invalid login credentials') || lowerMessage.contains('invalid credentials')) {
      return 'Email atau password salah.';
    } else if (lowerMessage.contains('email already registered') || 
               lowerMessage.contains('already in use') || 
               lowerMessage.contains('already registered') || 
               lowerMessage.contains('user already exists')) {
      return 'Email ini sudah terdaftar. Silakan gunakan email lain.';
    } else if (lowerMessage.contains('invalid email') || lowerMessage.contains('email format')) {
      return 'Format email tidak valid.';
    } else if (lowerMessage.contains('signup is disabled') || lowerMessage.contains('disabled')) {
      return 'Pendaftaran akun sedang dinonaktifkan.';
    } else if (lowerMessage.contains('network') || lowerMessage.contains('failed to connect')) {
      return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
    } else if (lowerMessage.contains('password should be') || lowerMessage.contains('password is too weak')) {
      return 'Password terlalu lemah. Gunakan minimal 8 karakter.';
    }
    return message; // fallback ke message asli jika tidak cocok
  }
}
