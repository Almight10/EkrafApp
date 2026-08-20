import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum VerificationStatus {
  pending,
  verified,
  rejected,
}

enum HakiType {
  merek,
  hakCipta,
  paten,
  desainIndustri,
  belumAda,
}

class EkrafData {
  final String id;
  final String userId;

  // Identitas Pelaku
  final String namaLengkap;
  final String nik;
  final String? ktpImagePath;
  final String noHp;
  final String email;
  final String alamat;
  final String kecamatan;
  final String kelurahan;
  final String? fotoUrl;

  // Data Usaha
  final String namaUsaha;
  final String subSektor;
  final String deskripsiUsaha;
  final String tahunBerdiri;
  final int jumlahKaryawan;
  final String omzetPerBulan;

  // HAKI
  final List<HakiType> hakiTypes;
  final String? nomorHaki;
  final String? tahunHaki;

  // Produk
  final List<String> productImagePaths;
  final String namaProdukUnggulan;
  final String hargaProduk;
  final String? linkMarketplace;

  // Metadata
  final VerificationStatus status;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? catatanAdmin;

  EkrafData({
    String? id,
    required this.userId,
    required this.namaLengkap,
    required this.nik,
    this.ktpImagePath,
    required this.noHp,
    required this.email,
    required this.alamat,
    required this.kecamatan,
    required this.kelurahan,
    this.fotoUrl,
    required this.namaUsaha,
    required this.subSektor,
    required this.deskripsiUsaha,
    required this.tahunBerdiri,
    required this.jumlahKaryawan,
    required this.omzetPerBulan,
    required this.hakiTypes,
    this.nomorHaki,
    this.tahunHaki,
    required this.productImagePaths,
    required this.namaProdukUnggulan,
    required this.hargaProduk,
    this.linkMarketplace,
    this.status = VerificationStatus.pending,
    DateTime? createdAt,
    this.verifiedAt,
    this.catatanAdmin,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  EkrafData copyWith({
    VerificationStatus? status,
    String? catatanAdmin,
    DateTime? verifiedAt,
  }) {
    return EkrafData(
      id: id,
      userId: userId,
      namaLengkap: namaLengkap,
      nik: nik,
      ktpImagePath: ktpImagePath,
      noHp: noHp,
      email: email,
      alamat: alamat,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
      fotoUrl: fotoUrl,
      namaUsaha: namaUsaha,
      subSektor: subSektor,
      deskripsiUsaha: deskripsiUsaha,
      tahunBerdiri: tahunBerdiri,
      jumlahKaryawan: jumlahKaryawan,
      omzetPerBulan: omzetPerBulan,
      hakiTypes: hakiTypes,
      nomorHaki: nomorHaki,
      tahunHaki: tahunHaki,
      productImagePaths: productImagePaths,
      namaProdukUnggulan: namaProdukUnggulan,
      hargaProduk: hargaProduk,
      linkMarketplace: linkMarketplace,
      status: status ?? this.status,
      createdAt: createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      catatanAdmin: catatanAdmin ?? this.catatanAdmin,
    );
  }

  String get statusLabel {
    switch (status) {
      case VerificationStatus.verified:
        return 'Terverifikasi';
      case VerificationStatus.rejected:
        return 'Ditolak';
      case VerificationStatus.pending:
        return 'Menunggu';
    }
  }

  factory EkrafData.fromSupabase(Map<String, dynamic> map) {
    final users = map['users'] as Map<String, dynamic>?;
    return EkrafData(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      // Kolom identitas diambil dari tabel users (JOIN), bukan dari ekraf_data
      namaLengkap: users?['nama_lengkap'] as String? ?? '',
      nik: users?['nik'] as String? ?? '',
      ktpImagePath: null,
      noHp: users?['no_hp'] as String? ?? '',
      email: users?['email'] as String? ?? '',
      alamat: users?['alamat'] as String? ?? '',
      kecamatan: users?['kecamatan'] as String? ?? '',
      kelurahan: users?['kelurahan'] as String? ?? '',
      fotoUrl: users?['foto_url'] as String?,
      namaUsaha: map['nama_usaha'] as String? ?? '',
      subSektor: map['sub_sektor'] as String? ?? '',
      deskripsiUsaha: map['deskripsi_usaha'] as String? ?? '',
      tahunBerdiri: map['tahun_berdiri'] as String? ?? '',
      jumlahKaryawan: map['jumlah_karyawan'] as int? ?? 0,
      omzetPerBulan: map['omzet_per_bulan'] as String? ?? '',
      hakiTypes: (map['haki_types'] as String? ?? '')
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => HakiType.values.firstWhere((e) => e.name == s, orElse: () => HakiType.belumAda))
          .toList(),
      nomorHaki: map['nomor_haki'] as String?,
      tahunHaki: map['tahun_haki'] as String?,
      productImagePaths: (map['product_image_paths'] as String? ?? '')
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      namaProdukUnggulan: map['nama_produk_unggulan'] as String? ?? '',
      hargaProduk: map['harga_produk'] as String? ?? '',
      linkMarketplace: map['link_marketplace'] as String?,
      status: VerificationStatus.values.firstWhere((e) => e.name == (map['status'] as String? ?? 'pending'), orElse: () => VerificationStatus.pending),
      createdAt: DateTime.parse(map['created_at'] as String),
      verifiedAt: map['verified_at'] != null ? DateTime.parse(map['verified_at'] as String) : null,
      catatanAdmin: map['catatan_admin'] as String?,
    );
  }

  Map<String, dynamic> toSupabase(String userId) {
    return {
      'user_id': userId,
      'nama_usaha': namaUsaha,
      'sub_sektor': subSektor,
      'deskripsi_usaha': deskripsiUsaha,
      'tahun_berdiri': tahunBerdiri,
      'jumlah_karyawan': jumlahKaryawan,
      'omzet_per_bulan': omzetPerBulan,
      'haki_types': hakiTypes.map((e) => e.name).join(','),
      'nomor_haki': nomorHaki,
      'tahun_haki': tahunHaki,
      'product_image_paths': productImagePaths.join(','),
      'nama_produk_unggulan': namaProdukUnggulan,
      'harga_produk': hargaProduk,
      'link_marketplace': linkMarketplace,
      'status': status.name,
      'catatan_admin': catatanAdmin,
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }
}

// Sub-sektor Ekraf berdasarkan Perpres No. 142/2018
const List<String> subSektorEkraf = [
  'Aplikasi & Game Developer',
  'Arsitektur',
  'Desain Interior',
  'Desain Komunikasi Visual',
  'Desain Produk',
  'Fashion',
  'Film, Animasi & Video',
  'Fotografi',
  'Kriya',
  'Kuliner',
  'Musik',
  'Penerbitan',
  'Periklanan',
  'Seni Pertunjukan',
  'Seni Rupa',
  'Televisi & Radio',
  'Lainnya',
];

const Map<String, List<String>> probolinggoData = {
  'Kecamatan Kademangan': [
    'Kelurahan Kademangan',
    'Kelurahan Ketapang',
    'Kelurahan Pilang',
    'Kelurahan Pohsangit Kidul',
    'Kelurahan Triwung Kidul',
    'Kelurahan Triwung Lor',
  ],
  'Kecamatan Kanigaran': [
    'Kelurahan Curahgrinting',
    'Kelurahan Kanigaran',
    'Kelurahan Kebonsari Kulon',
    'Kelurahan Kebonsari Wetan',
    'Kelurahan Tisnonegaran',
  ],
  'Kecamatan Kedopok': [
    'Kelurahan Jrebeng Lor',
    'Kelurahan Jrebeng Wetan',
    'Kelurahan Kedopok',
    'Kelurahan Kopian',
    'Kelurahan Sumber Wetan',
    'Kelurahan Kareng Lor',
  ],
  'Kecamatan Mayangan': [
    'Kelurahan Jati',
    'Kelurahan Mangunharjo',
    'Kelurahan Mayangan',
    'Kelurahan Sukabumi',
    'Kelurahan Wiroborang',
  ],
  'Kecamatan Wonoasih': [
    'Kelurahan Jrebeng Kidul',
    'Kelurahan Kedunggaleng',
    'Kelurahan Kedungasem',
    'Kelurahan Pakistaji',
    'Kelurahan Sumbertaman',
    'Kelurahan Wonoasih',
  ],
};

List<String> get kecamatanList => probolinggoData.keys.toList();

const List<String> omzetRanges = [
  'Di bawah Rp 1 Juta',
  'Rp 1 Juta - Rp 5 Juta',
  'Rp 5 Juta - Rp 10 Juta',
  'Rp 10 Juta - Rp 50 Juta',
  'Rp 50 Juta - Rp 100 Juta',
  'Di atas Rp 100 Juta',
];
