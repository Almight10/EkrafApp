import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Re-export AuthException agar screen tidak perlu import auth_service secara langsung
export '../services/auth_service.dart' show AuthException;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordRecovery = false;

  // ── Getters ──────────────────────────────────────────────────────────────────
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordRecovery => _isPasswordRecovery;

  void setPasswordRecovery(bool value) {
    _isPasswordRecovery = value;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LOGIN
  // ════════════════════════════════════════════════════════════════════════════
  /// Melakukan login menggunakan Firebase Authentication.
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.login(email, password);
      _currentUser = user;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga. Coba lagi.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // REGISTER
  // ════════════════════════════════════════════════════════════════════════════
  /// Mendaftarkan pengguna baru menggunakan Firebase Authentication.
  /// Data pengguna disimpan ke Cloud Firestore.
  /// Melempar [AuthException] jika gagal.
  Future<void> register({
    required String namaLengkap,
    required String email,
    required String password,
    String? noHp,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.register(
        namaLengkap: namaLengkap,
        email: email,
        password: password,
        noHp: noHp,
      );
      // Tidak set currentUser setelah register — pengguna diarahkan ke Login
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // UPDATE PROFILE
  // ════════════════════════════════════════════════════════════════════════════
  /// Memperbarui profil pelaku ekraf di database Supabase.
  Future<void> updateProfile({
    required String nik,
    required String alamat,
    required String kecamatan,
    required String kelurahan,
    String? ktpUrl,
    String? fotoUrl,
    String? noHp,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.updateProfile(
        nik: nik,
        alamat: alamat,
        kecamatan: kecamatan,
        kelurahan: kelurahan,
        ktpUrl: ktpUrl,
        fotoUrl: fotoUrl,
        noHp: noHp,
      );
      _currentUser = user;
      notifyListeners();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfileNameAndPhone({
    required String namaLengkap,
    required String noHp,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.updateProfileNameAndPhone(
        namaLengkap: namaLengkap,
        noHp: noHp,
      );
      _currentUser = user;
      notifyListeners();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword(String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updatePassword(newPassword);
      notifyListeners();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // ════════════════════════════════════════════════════════════════════════════
  /// Mengirim email reset password menggunakan Firebase Authentication.
  /// Melempar [AuthException] jika email tidak ditemukan atau terjadi error.
  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    } finally {
      _setLoading(false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CHECK SESSION
  // ════════════════════════════════════════════════════════════════════════════
  Future<bool> checkSession() async {
    try {
      final user = await _authService.tryRestoreSession();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LOGOUT
  // ════════════════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  // ── Private Helpers ──────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
