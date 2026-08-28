import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/ekraf_data.dart';
import '../providers/ekraf_provider.dart';
import '../providers/auth_provider.dart';
import 'input_form_screen.dart';

class DetailScreen extends StatefulWidget {
  final EkrafData data;
  const DetailScreen({super.key, required this.data});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final user = context.watch<AuthProvider>().currentUser;
    final isAdmin = user?.isAdmin == true;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (data.status) {
      case VerificationStatus.verified:
        statusColor = AppColors.tertiary;
        statusLabel = 'Terverifikasi';
        statusIcon = Icons.verified_rounded;
        break;
      case VerificationStatus.rejected:
        statusColor = AppColors.error;
        statusLabel = 'Ditolak';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.secondary;
        statusLabel = 'Menunggu Verifikasi';
        statusIcon = Icons.schedule_rounded;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          backgroundImage: (data.fotoUrl != null && data.fotoUrl!.isNotEmpty)
                              ? NetworkImage(data.fotoUrl!)
                              : null,
                          child: (data.fotoUrl != null && data.fotoUrl!.isNotEmpty)
                              ? null
                              : Text(
                                  data.namaLengkap.isNotEmpty
                                      ? data.namaLengkap[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data.namaLengkap,
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              Text(data.namaUsaha,
                                  style: GoogleFonts.inter(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(statusLabel,
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Identitas'),
                Tab(text: 'Usaha & HAKI'),
                Tab(text: 'Produk'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildIdentitasTab(data),
            _buildUsahaTab(data),
            _buildProdukTab(data),
          ],
        ),
      ),
      bottomNavigationBar: isAdmin
          ? (data.status == VerificationStatus.pending
              ? _buildVerificationBar(context, data)
              : _buildEditDeleteBar(context, data))
          : (data.status != VerificationStatus.verified
              ? _buildEditDeleteBar(context, data)
              : null),
    );
  }

  Widget _buildIdentitasTab(EkrafData data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (data.catatanAdmin != null) ...[
          _buildCatatanCard(data),
          const SizedBox(height: 16),
        ],
        _SectionCard(title: 'Data Diri', items: [
          _InfoItem('Nama Lengkap', data.namaLengkap),
          _InfoItem('NIK', data.nik),
          _InfoItem('No. HP / WA', data.noHp),
          _InfoItem('Email', data.email),
        ]),
        const SizedBox(height: 16),
        _SectionCard(title: 'Alamat', items: [
          _InfoItem('Alamat Lengkap', data.alamat),
          _InfoItem('Kecamatan', data.kecamatan),
          _InfoItem('Kelurahan', data.kelurahan),
        ]),
      ],
    );
  }

  Widget _buildUsahaTab(EkrafData data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(title: 'Data Usaha', items: [
          _InfoItem('Nama Usaha', data.namaUsaha),
          _InfoItem('Sub-Sektor', data.subSektor),
          _InfoItem('Tahun Berdiri', data.tahunBerdiri),
          _InfoItem('Jumlah Karyawan', '${data.jumlahKaryawan} orang'),
          _InfoItem('Omzet / Bulan', data.omzetPerBulan),
          _InfoItem('Deskripsi Usaha', data.deskripsiUsaha),
        ]),
        const SizedBox(height: 16),
        _SectionCard(title: 'Lokasi & Tempat Usaha', items: [
          _InfoItem('Alamat Tempat Usaha', data.displayAlamatUsaha),
          _InfoItem('Kecamatan', data.displayKecamatanUsaha),
          _InfoItem('Kelurahan', data.displayKelurahanUsaha),
          if (data.mapsUrl != null && data.mapsUrl!.isNotEmpty)
            _InfoItem('Google Maps', data.mapsUrl!),
        ]),
        const SizedBox(height: 16),
        _SectionCard(title: 'Kekayaan Intelektual (HAKI)', items: [
          _InfoItem(
              'Jenis HAKI',
              data.hakiTypes
                  .map((h) => _hakiLabel(h).$1)
                  .join(', ')),
          if (data.nomorHaki != null)
            _InfoItem('Nomor HAKI', data.nomorHaki!),
          if (data.tahunHaki != null)
            _InfoItem('Tahun Pendaftaran', data.tahunHaki!),
        ]),
      ],
    );
  }

  Widget _buildProdukTab(EkrafData data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(title: 'Produk Unggulan', items: [
          _InfoItem('Nama Produk', data.namaProdukUnggulan),
          _InfoItem('Harga / Kisaran', data.hargaProduk),
          if (data.linkMarketplace != null)
            _InfoItem('Marketplace', data.linkMarketplace!),
        ]),
        const SizedBox(height: 20),
        if (data.productImagePaths.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Foto Produk Unggulan',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.productImagePaths.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, idx) {
                final imageUrl = data.productImagePaths[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppShadows.card,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 160,
                          height: 160,
                          color: AppColors.surfaceContainerLow,
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined, color: AppColors.error, size: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ] else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                const Icon(Icons.photo_library_outlined, color: AppColors.textHint),
                const SizedBox(width: 12),
                Text(
                  'Foto produk belum tersedia.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCatatanCard(EkrafData data) {
    final isRejected = data.status == VerificationStatus.rejected;
    final bgColor = isRejected
        ? AppColors.errorContainer
        : AppColors.primaryFixed.withValues(alpha: 0.5);
    final textColor =
        isRejected ? AppColors.onErrorContainer : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
              isRejected
                  ? Icons.info_rounded
                  : Icons.check_circle_rounded,
              color: textColor,
              size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRejected ? 'Alasan Penolakan' : 'Catatan Admin',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor),
                ),
                const SizedBox(height: 4),
                Text(data.catatanAdmin!,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBar(BuildContext context, EkrafData data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.modal,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showRejectDialog(context, data),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Tolak'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _verify(context, data),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Verifikasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _verify(BuildContext context, EkrafData data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Verifikasi Data Usaha?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin memverifikasi data usaha "${data.namaUsaha}" ini? Status data usaha akan berubah menjadi Terverifikasi.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<EkrafProvider>().updateStatus(
                    data.id,
                    VerificationStatus.verified,
                  );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data usaha berhasil diverifikasi!'),
                    backgroundColor: AppColors.tertiary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Verifikasi',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _editData(BuildContext context, EkrafData data) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InputFormScreen(data: data),
      ),
    );
    if (result == true && context.mounted) {
      context.read<EkrafProvider>().loadData();
      Navigator.pop(context);
    }
  }

  void _confirmDelete(BuildContext context, EkrafData data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Data Usaha?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data pengajuan usaha "${data.namaUsaha}" ini? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<EkrafProvider>().deleteEntry(data.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil dihapus.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditDeleteBar(BuildContext context, EkrafData data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.modal,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, data),
              icon: const Icon(Icons.delete_outline_rounded, size: 16),
              label: const Text('Hapus'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _editData(context, data),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, EkrafData data) {
    _catatanController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tolak Pengajuan',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Berikan catatan alasan penolakan kepada pelaku:',
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Contoh: Dokumen tidak lengkap...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final catatan = _catatanController.text.trim().isEmpty
                  ? 'Ditolak oleh admin'
                  : _catatanController.text.trim();
              await context.read<EkrafProvider>().updateStatus(
                    data.id,
                    VerificationStatus.rejected,
                    catatan: catatan,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  (String, IconData, Color) _hakiLabel(HakiType t) {
    switch (t) {
      case HakiType.merek:
        return ('Merek', Icons.local_offer_outlined, AppColors.primary);
      case HakiType.hakCipta:
        return ('Hak Cipta', Icons.copyright_outlined, const Color(0xFF7B61FF));
      case HakiType.paten:
        return ('Paten', Icons.science_outlined, AppColors.tertiary);
      case HakiType.desainIndustri:
        return ('Desain Industri', Icons.design_services_outlined, const Color(0xFFFF6B35));
      case HakiType.belumAda:
        return ('Belum Ada', Icons.hourglass_empty_outlined, AppColors.textSecondary);
    }
  }
}

// ── Supporting widgets ─────────────────────────────────────────────────────────

class _InfoItem {
  final String label;
  final String value;
  _InfoItem(this.label, this.value);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;
  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          const Divider(height: 1),
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Text(e.value.label,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        child: Text(e.value.value,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 1, indent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}
