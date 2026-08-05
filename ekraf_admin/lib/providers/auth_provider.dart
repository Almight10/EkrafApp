import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  final List<AppUser> _users = [
    AppUser(
      id: 'admin-001',
      namaLengkap: 'Admin Dinas Ekraf',
      email: 'admin@ekraf.go.id',
      role: UserRole.admin,
    ),
    AppUser(
      id: 'pelaku-001',
      namaLengkap: 'Budi Santoso',
      email: 'budi.santoso@gmail.com',
      nik: '7471012505900001',
      noHp: '081234567890',
      alamat: 'Jl. Ahmad Yani No. 12, RT 003/RW 004',
      kecamatan: 'Kecamatan Kendari',
      kelurahan: 'Kelurahan Kandai',
      role: UserRole.pelaku,
    ),
    AppUser(
      id: 'pelaku-002',
      namaLengkap: 'Siti Rahmawati',
      email: 'siti.rahmawati@email.com',
      nik: '7471024508950002',
      noHp: '082345678901',
      alamat: 'Jl. Sawerigading No. 45',
      kecamatan: 'Kecamatan Baruga',
      kelurahan: 'Kelurahan Baruga',
      role: UserRole.pelaku,
    ),
  ];

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 800));

    final normalizedEmail = email.trim().toLowerCase();
    
    // Check if user exists in our mock database
    try {
      final user = _users.firstWhere((u) => u.email.toLowerCase() == normalizedEmail);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      // For demo convenience: if it is admin@ekraf.go.id and password is correct, or if user enters anything, let's create a dynamic user.
      // But specifically, if they type "admin@ekraf.go.id" or "@ekraf.go.id", make them admin.
      if (normalizedEmail.endsWith('@ekraf.go.id')) {
        final newAdmin = AppUser(
          id: 'admin-gen-${DateTime.now().millisecondsSinceEpoch}',
          namaLengkap: 'Admin Ekraf',
          email: normalizedEmail,
          role: UserRole.admin,
        );
        _users.add(newAdmin);
        _currentUser = newAdmin;
        notifyListeners();
        return true;
      } else {
        // If not admin, register them dynamically as a mock Pelaku with standard mock details for demo
        final newPelaku = AppUser(
          id: 'pelaku-gen-${DateTime.now().millisecondsSinceEpoch}',
          namaLengkap: normalizedEmail.split('@')[0].toUpperCase(),
          email: normalizedEmail,
          nik: '7471000000000000',
          noHp: '08123456789',
          alamat: 'Jl. Pemuda No. 1',
          kecamatan: 'Kecamatan Wua-Wua',
          kelurahan: 'Kelurahan Wua-Wua',
          role: UserRole.pelaku,
        );
        _users.add(newPelaku);
        _currentUser = newPelaku;
        notifyListeners();
        return true;
      }
    }
  }

  Future<void> register({
    required String namaLengkap,
    required String email,
    required String nik,
    required String noHp,
    required String alamat,
    required String kecamatan,
    required String kelurahan,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final normalizedEmail = email.trim().toLowerCase();

    // Check if user already exists
    _users.removeWhere((u) => u.email.toLowerCase() == normalizedEmail);

    final newUser = AppUser(
      id: 'pelaku-reg-${DateTime.now().millisecondsSinceEpoch}',
      namaLengkap: namaLengkap.trim(),
      email: normalizedEmail,
      nik: nik.trim(),
      noHp: noHp.trim(),
      alamat: alamat.trim(),
      kecamatan: kecamatan,
      kelurahan: kelurahan,
      role: UserRole.pelaku,
    );

    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
