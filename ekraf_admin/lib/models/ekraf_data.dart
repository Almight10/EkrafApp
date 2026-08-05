import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum VerificationStatus {
  pending,
  verified,
  rejected,
}

enum HakiType {
  merek,
  hak_cipta,
  paten,
  desain_industri,
  belum_ada,
}

class EkrafData {
  final String id;

  // Identitas Pelaku
  final String namaLengkap;
  final String nik;
  final String? ktpImagePath;
  final String noHp;
  final String email;
  final String alamat;
  final String kecamatan;
  final String kelurahan;

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
    required this.namaLengkap,
    required this.nik,
    this.ktpImagePath,
    required this.noHp,
    required this.email,
    required this.alamat,
    required this.kecamatan,
    required this.kelurahan,
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
      namaLengkap: namaLengkap,
      nik: nik,
      ktpImagePath: ktpImagePath,
      noHp: noHp,
      email: email,
      alamat: alamat,
      kecamatan: kecamatan,
      kelurahan: kelurahan,
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

const List<String> kecamatanList = [
  'Kecamatan Abeli',
  'Kecamatan Baruga',
  'Kecamatan Kambu',
  'Kecamatan Kendari',
  'Kecamatan Kendari Barat',
  'Kecamatan Kadia',
  'Kecamatan Mandonga',
  'Kecamatan Poasia',
  'Kecamatan Puuwatu',
  'Kecamatan Wua-Wua',
];

const List<String> omzetRanges = [
  'Di bawah Rp 1 Juta',
  'Rp 1 Juta - Rp 5 Juta',
  'Rp 5 Juta - Rp 10 Juta',
  'Rp 10 Juta - Rp 50 Juta',
  'Rp 50 Juta - Rp 100 Juta',
  'Di atas Rp 100 Juta',
];
