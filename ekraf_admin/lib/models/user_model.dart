enum UserRole {
  admin,
  pelaku,
}

class AppUser {
  final String id;
  final String namaLengkap;
  final String email;
  final String? noHp;
  final String role; // 'admin' | 'user'
  final DateTime? createdAt;

  // Profil data pelaku (nullable)
  final String? nik;
  final String? alamat;
  final String? kecamatan;
  final String? kelurahan;
  final String? ktpUrl;
  final String? fotoUrl;

  AppUser({
    required this.id,
    required this.namaLengkap,
    required this.email,
    this.noHp,
    this.role = 'user',
    this.createdAt,
    this.nik,
    this.alamat,
    this.kecamatan,
    this.kelurahan,
    this.ktpUrl,
    this.fotoUrl,
  });

  // Getter helper untuk role-checking
  bool get isAdmin => role == 'admin';
  bool get isPelaku => role == 'user' || role == 'pelaku';

  /// Buat AppUser dari Row Supabase
  factory AppUser.fromSupabase(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] as String? ?? '',
      namaLengkap: data['nama_lengkap'] as String? ?? '',
      email: data['email'] as String? ?? '',
      noHp: data['no_hp'] as String?,
      role: data['role'] as String? ?? 'user',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : null,
      nik: data['nik'] as String?,
      alamat: data['alamat'] as String?,
      kecamatan: data['kecamatan'] as String?,
      kelurahan: data['kelurahan'] as String?,
      ktpUrl: data['ktp_url'] as String?,
      fotoUrl: data['foto_url'] as String?,
    );
  }

  /// Konversi ke Map untuk disimpan ke Supabase
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'email': email,
      'no_hp': noHp ?? '',
      'role': role,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'nik': nik,
      'alamat': alamat,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
      'ktp_url': ktpUrl,
      'foto_url': fotoUrl,
    };
  }

  AppUser copyWith({
    String? id,
    String? namaLengkap,
    String? email,
    String? noHp,
    String? role,
    DateTime? createdAt,
    String? nik,
    String? alamat,
    String? kecamatan,
    String? kelurahan,
    String? ktpUrl,
    String? fotoUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      nik: nik ?? this.nik,
      alamat: alamat ?? this.alamat,
      kecamatan: kecamatan ?? this.kecamatan,
      kelurahan: kelurahan ?? this.kelurahan,
      ktpUrl: ktpUrl ?? this.ktpUrl,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}
