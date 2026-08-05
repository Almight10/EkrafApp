import 'dart:async';
import '../models/ekraf_data.dart';

/// Mock service simulating local data storage
/// Will be replaced with Firebase Firestore in next phase
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final List<EkrafData> _data = [
    EkrafData(
      id: 'mock-001',
      namaLengkap: 'Budi Santoso',
      nik: '7471012505900001',
      noHp: '081234567890',
      email: 'budi.santoso@gmail.com',
      alamat: 'Jl. Ahmad Yani No. 12, RT 003/RW 004',
      kecamatan: 'Kecamatan Kendari',
      kelurahan: 'Kelurahan Kandai',
      namaUsaha: 'Batik Kendari Sejati',
      subSektor: 'Kriya',
      deskripsiUsaha: 'Memproduksi batik tulis dan cap dengan motif khas Sulawesi Tenggara, menggunakan bahan alami ramah lingkungan.',
      tahunBerdiri: '2018',
      jumlahKaryawan: 8,
      omzetPerBulan: 'Rp 10 Juta - Rp 50 Juta',
      hakiTypes: [HakiType.merek, HakiType.hak_cipta],
      nomorHaki: 'IDM000987654',
      tahunHaki: '2020',
      productImagePaths: [],
      namaProdukUnggulan: 'Batik Motif Kalo Sara',
      hargaProduk: 'Rp 250.000 - Rp 1.500.000',
      linkMarketplace: 'https://tokopedia.com/batikkendari',
      status: VerificationStatus.verified,
      createdAt: DateTime(2025, 3, 15),
      verifiedAt: DateTime(2025, 3, 20),
    ),
    EkrafData(
      id: 'mock-002',
      namaLengkap: 'Siti Rahmawati',
      nik: '7471024508950002',
      noHp: '082345678901',
      email: 'siti.rahmawati@email.com',
      alamat: 'Jl. Sawerigading No. 45',
      kecamatan: 'Kecamatan Baruga',
      kelurahan: 'Kelurahan Baruga',
      namaUsaha: 'Dapur Siti - Kue Tradisional',
      subSektor: 'Kuliner',
      deskripsiUsaha: 'Produksi kue-kue tradisional Sulawesi Tenggara, termasuk kue cucur, onde-onde, dan dodol cengkeh.',
      tahunBerdiri: '2020',
      jumlahKaryawan: 3,
      omzetPerBulan: 'Rp 5 Juta - Rp 10 Juta',
      hakiTypes: [HakiType.belum_ada],
      productImagePaths: [],
      namaProdukUnggulan: 'Dodol Cengkeh Premium',
      hargaProduk: 'Rp 35.000 - Rp 75.000',
      linkMarketplace: 'https://shopee.co.id/dapursiti',
      status: VerificationStatus.pending,
      createdAt: DateTime(2025, 6, 10),
    ),
    EkrafData(
      id: 'mock-003',
      namaLengkap: 'Andi Pratama',
      nik: '7471031203880003',
      noHp: '085678901234',
      email: 'andi.pratama@dev.com',
      alamat: 'Jl. DI Panjaitan No. 78',
      kecamatan: 'Kecamatan Kambu',
      kelurahan: 'Kelurahan Kambu',
      namaUsaha: 'KendariTech Studio',
      subSektor: 'Aplikasi & Game Developer',
      deskripsiUsaha: 'Studio pengembangan aplikasi mobile dan web untuk UMKM lokal. Spesialis aplikasi kasir dan manajemen stok.',
      tahunBerdiri: '2021',
      jumlahKaryawan: 5,
      omzetPerBulan: 'Rp 10 Juta - Rp 50 Juta',
      hakiTypes: [HakiType.hak_cipta, HakiType.merek],
      nomorHaki: 'EC00202312345',
      tahunHaki: '2023',
      productImagePaths: [],
      namaProdukUnggulan: 'KasirKu - Aplikasi Kasir Mobile',
      hargaProduk: 'Rp 299.000/tahun',
      linkMarketplace: null,
      status: VerificationStatus.verified,
      createdAt: DateTime(2025, 1, 5),
      verifiedAt: DateTime(2025, 1, 12),
    ),
    EkrafData(
      id: 'mock-004',
      namaLengkap: 'Fatimah Az-Zahra',
      nik: '7471030709920004',
      noHp: '087890123456',
      email: 'fatimah.fashion@gmail.com',
      alamat: 'Jl. Malik Raya No. 23',
      kecamatan: 'Kecamatan Kadia',
      kelurahan: 'Kelurahan Kadia',
      namaUsaha: 'Fa-Moda Collection',
      subSektor: 'Fashion',
      deskripsiUsaha: 'Butik busana muslim modern dengan sentuhan tenun Tolaki. Menerima pesanan custom dan ready-to-wear.',
      tahunBerdiri: '2019',
      jumlahKaryawan: 6,
      omzetPerBulan: 'Rp 10 Juta - Rp 50 Juta',
      hakiTypes: [HakiType.merek],
      nomorHaki: 'IDM001234567',
      tahunHaki: '2022',
      productImagePaths: [],
      namaProdukUnggulan: 'Gamis Tenun Tolaki Exclusive',
      hargaProduk: 'Rp 450.000 - Rp 2.000.000',
      linkMarketplace: 'https://instagram.com/famodacollection',
      status: VerificationStatus.rejected,
      createdAt: DateTime(2025, 5, 20),
      catatanAdmin: 'Foto KTP tidak jelas, mohon upload ulang.',
    ),
    EkrafData(
      id: 'mock-005',
      namaLengkap: 'Rahmat Hidayat',
      nik: '7471081501940005',
      noHp: '089012345678',
      email: 'rahmat.foto@gmail.com',
      alamat: 'Jl. Chairil Anwar No. 5',
      kecamatan: 'Kecamatan Mandonga',
      kelurahan: 'Kelurahan Mandonga',
      namaUsaha: 'Rahmat Photography Studio',
      subSektor: 'Fotografi',
      deskripsiUsaha: 'Studio foto profesional untuk wedding, prewedding, dan event korporat. Melayani seluruh wilayah Sulawesi Tenggara.',
      tahunBerdiri: '2017',
      jumlahKaryawan: 4,
      omzetPerBulan: 'Rp 10 Juta - Rp 50 Juta',
      hakiTypes: [HakiType.hak_cipta],
      productImagePaths: [],
      namaProdukUnggulan: 'Paket Wedding Premium',
      hargaProduk: 'Rp 5.000.000 - Rp 15.000.000',
      linkMarketplace: null,
      status: VerificationStatus.pending,
      createdAt: DateTime(2025, 7, 1),
    ),
  ];

  // Simulate async operations
  Future<List<EkrafData>> getAllData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_data);
  }

  Future<EkrafData?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _data.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addData(EkrafData data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _data.insert(0, data);
  }

  Future<void> updateStatus(
    String id,
    VerificationStatus status,
    String? catatan,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _data.indexWhere((e) => e.id == id);
    if (index != -1) {
      _data[index] = _data[index].copyWith(
        status: status,
        catatanAdmin: catatan,
        verifiedAt: status == VerificationStatus.verified ? DateTime.now() : null,
      );
    }
  }

  Future<void> deleteData(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _data.removeWhere((e) => e.id == id);
  }

  // Statistics
  Map<String, int> getStatsBySubSektor() {
    final Map<String, int> stats = {};
    for (final item in _data) {
      stats[item.subSektor] = (stats[item.subSektor] ?? 0) + 1;
    }
    return stats;
  }

  Map<VerificationStatus, int> getStatsByStatus() {
    final Map<VerificationStatus, int> stats = {};
    for (final item in _data) {
      stats[item.status] = (stats[item.status] ?? 0) + 1;
    }
    return stats;
  }

  int get totalData => _data.length;
  int get totalVerified => _data.where((e) => e.status == VerificationStatus.verified).length;
  int get totalPending => _data.where((e) => e.status == VerificationStatus.pending).length;
  int get totalRejected => _data.where((e) => e.status == VerificationStatus.rejected).length;
}
