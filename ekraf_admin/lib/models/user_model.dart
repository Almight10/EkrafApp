enum UserRole {
  admin,
  pelaku,
}

class AppUser {
  final String id;
  final String namaLengkap;
  final String email;
  final String? nik;
  final String? noHp;
  final String? alamat;
  final String? kecamatan;
  final String? kelurahan;
  final UserRole role;

  AppUser({
    required this.id,
    required this.namaLengkap,
    required this.email,
    this.nik,
    this.noHp,
    this.alamat,
    this.kecamatan,
    this.kelurahan,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isPelaku => role == UserRole.pelaku;
}
