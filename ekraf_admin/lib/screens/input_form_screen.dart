import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../models/ekraf_data.dart';
import '../providers/ekraf_provider.dart';
import '../providers/auth_provider.dart';

class InputFormScreen extends StatefulWidget {
  final EkrafData? data;
  const InputFormScreen({super.key, this.data});

  @override
  State<InputFormScreen> createState() => _InputFormScreenState();
}

class _InputFormScreenState extends State<InputFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSaving = false;

  final List<dynamic> _allProductImages = [];
  final ImagePicker _picker = ImagePicker();

  static const int _maxProductImages = 5;

  Future<void> _pickProductImage() async {
    final remaining = _maxProductImages - _allProductImages.length;

    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maksimal $_maxProductImages foto produk.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil dari Kamera'),
              onTap: () async {
                Navigator.of(context).pop();
                final picked = await _picker.pickImage(
                    source: ImageSource.camera, imageQuality: 70);
                if (picked != null) {
                  setState(() {
                    _allProductImages.add(File(picked.path));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Pilih Foto dari Galeri (Maks $remaining foto)'),
              subtitle: Text(
                  'Maks $_maxProductImages foto. Sudah dipilih: ${_allProductImages.length}'),
              onTap: () async {
                Navigator.of(context).pop();
                final pickedList = await _picker.pickMultiImage(
                  imageQuality: 70,
                  limit: remaining,
                );
                if (pickedList.isNotEmpty) {
                  setState(() {
                    for (final img in pickedList) {
                      if (_allProductImages.length < _maxProductImages) {
                        _allProductImages.add(File(img.path));
                      }
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }


  // Step 1 - Identitas
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();
  String? _selectedKecamatan;
  String? _selectedKelurahan;

  // Step 2 - Usaha
  final _namaUsahaController = TextEditingController();
  String? _selectedSubSektor;
  final _deskripsiController = TextEditingController();
  final _tahunBerdiriController = TextEditingController();
  final _karyawanController = TextEditingController();
  String? _selectedOmzet;
  bool _alamatUsahaSamaDenganDomisili = true;
  final _alamatUsahaController = TextEditingController();
  String? _selectedKecamatanUsaha;
  String? _selectedKelurahanUsaha;
  final _mapsUrlController = TextEditingController();

  // Step 3 - Legalitas (HAKI)
  final Set<HakiType> _selectedHaki = {HakiType.belumAda};
  final _nomorHakiController = TextEditingController();
  final _tahunHakiController = TextEditingController();

  // Step 4 - Produk
  final _namaProdukController = TextEditingController();
  final _hargaController = TextEditingController();
  final _marketplaceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      final d = widget.data!;
      _namaController.text = d.namaLengkap;
      _nikController.text = d.nik;
      _noHpController.text = d.noHp;
      _emailController.text = d.email;
      _alamatController.text = d.alamat;
      _selectedKecamatan = d.kecamatan.isEmpty ? null : d.kecamatan;
      _selectedKelurahan = d.kelurahan.isEmpty ? null : d.kelurahan;

      _namaUsahaController.text = d.namaUsaha;
      _selectedSubSektor = d.subSektor.isEmpty ? null : d.subSektor;
      _deskripsiController.text = d.deskripsiUsaha;
      _tahunBerdiriController.text = d.tahunBerdiri;
      _karyawanController.text = d.jumlahKaryawan.toString();
      _selectedOmzet = d.omzetPerBulan.isEmpty ? null : d.omzetPerBulan;

      if (d.alamatUsaha != null && d.alamatUsaha!.trim().isNotEmpty) {
        _alamatUsahaController.text = d.alamatUsaha!;
        _selectedKecamatanUsaha = d.kecamatanUsaha;
        _selectedKelurahanUsaha = d.kelurahanUsaha;
        _mapsUrlController.text = d.mapsUrl ?? '';
        if (d.alamatUsaha != d.alamat ||
            (d.kecamatanUsaha != null && d.kecamatanUsaha != d.kecamatan)) {
          _alamatUsahaSamaDenganDomisili = false;
        }
      }

      _selectedHaki.clear();
      _selectedHaki.addAll(d.hakiTypes);
      _nomorHakiController.text = d.nomorHaki ?? '';
      _tahunHakiController.text = d.tahunHaki ?? '';

      _namaProdukController.text = d.namaProdukUnggulan;
      _hargaController.text = d.hargaProduk;
      _marketplaceController.text = d.linkMarketplace ?? '';

      _allProductImages.addAll(d.productImagePaths);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authProvider = context.read<AuthProvider>();
        final user = authProvider.currentUser;
        if (user != null && user.isPelaku) {
          setState(() {
            _namaController.text = user.namaLengkap;
            _nikController.text = user.nik ?? '';
            _emailController.text = user.email;
            _noHpController.text = user.noHp ?? '';
            _alamatController.text = user.alamat ?? '';
            _selectedKecamatan = user.kecamatan;
            _selectedKelurahan = user.kelurahan;
          });
        }
      });
    }
  }


  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _namaUsahaController.dispose();
    _deskripsiController.dispose();
    _tahunBerdiriController.dispose();
    _karyawanController.dispose();
    _alamatUsahaController.dispose();
    _mapsUrlController.dispose();
    _nomorHakiController.dispose();
    _tahunHakiController.dispose();
    _namaProdukController.dispose();
    _hargaController.dispose();
    _marketplaceController.dispose();
    super.dispose();
  }

  final List<String> _stepTitles = [
    'Identitas',
    'Usaha',
    'Legalitas',
    'Produk',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.data != null ? 'Edit Data Ekraf' : 'Tambah Data Ekraf',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _confirmExit(context),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: _buildCurrentStep(),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(_stepTitles.length, (i) {
              final isActive = i == _currentStep;
              final isDone = i < _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.tertiary
                            : isActive
                                ? AppColors.primary
                                : AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : isDone
                                  ? AppColors.tertiary
                                  : AppColors.outlineVariant,
                        ),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: GoogleFonts.inter(
                                  color: isActive ? Colors.white : AppColors.textHint,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    if (i < _stepTitles.length - 1)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 2,
                          color: isDone ? AppColors.tertiary : AppColors.outlineVariant,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Langkah ${_currentStep + 1}: ${_stepTitles[_currentStep]}',
            style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      case 4:
        return _buildStep5();
      default:
        return const SizedBox();
    }
  }

  // ── STEP 1: Identitas ──────────────────────────────────
  Widget _buildStep1() {
    final isPelaku = context.read<AuthProvider>().currentUser?.isPelaku ?? false;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFieldContainer(
          label: 'Nama Lengkap',
          sensitivity: _Sensitivity.privat,
          child: _buildField(
            controller: _namaController,
            hint: 'Masukkan nama sesuai KTP',
            icon: Icons.person_outline,
            readOnly: isPelaku,
            validator: _required,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'NIK (Nomor Induk Kependudukan)',
          sensitivity: _Sensitivity.sensitif,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                controller: _nikController,
                hint: '16 Digit NIK',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                readOnly: isPelaku,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'NIK wajib diisi';
                  if (v.length != 16) return 'NIK harus 16 digit';
                  return null;
                },
              ),
              const SizedBox(height: 4),
              Text(
                'Harus 16 digit',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'No. WhatsApp',
          sensitivity: _Sensitivity.publik,
          child: _buildField(
            controller: _noHpController,
            hint: 'Contoh: 081234567890',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            readOnly: isPelaku,
            validator: _required,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Email',
          sensitivity: _Sensitivity.privat,
          child: _buildField(
            controller: _emailController,
            hint: 'Contoh: nama@domain.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            readOnly: isPelaku,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Alamat Lengkap',
          sensitivity: _Sensitivity.publik,
          child: _buildField(
            controller: _alamatController,
            hint: 'Jl. Pemuda No. 1...',
            icon: Icons.home_outlined,
            maxLines: 2,
            readOnly: isPelaku,
            validator: _required,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Kecamatan',
          sensitivity: _Sensitivity.publik,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedKecamatan,
            items: () {
              final List<String> effectiveList = List<String>.from(kecamatanList);
              if (_selectedKecamatan != null && !effectiveList.contains(_selectedKecamatan)) {
                effectiveList.add(_selectedKecamatan!);
              }
              return effectiveList
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
                      ))
                  .toList();
            }(),
            onChanged: isPelaku ? null : (v) {
              setState(() {
                _selectedKecamatan = v;
                _selectedKelurahan = null;
              });
            },
            validator: (v) => v == null ? 'Pilih kecamatan' : null,
            dropdownColor: AppColors.surface,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
            decoration: const InputDecoration(
              hintText: 'Pilih Kecamatan',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Kelurahan',
          sensitivity: _Sensitivity.publik,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedKelurahan,
            items: () {
              final List<String> rawKelurahan = probolinggoData[_selectedKecamatan] ?? [];
              final List<String> effectiveList = List<String>.from(rawKelurahan);
              if (_selectedKelurahan != null && !effectiveList.contains(_selectedKelurahan)) {
                effectiveList.add(_selectedKelurahan!);
              }
              return effectiveList
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
                      ))
                  .toList();
            }(),
            onChanged: (isPelaku || _selectedKecamatan == null) ? null : (v) {
              setState(() {
                _selectedKelurahan = v;
              });
            },
            validator: (v) => v == null ? 'Pilih kelurahan' : null,
            dropdownColor: AppColors.surface,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
            decoration: InputDecoration(
              hintText: _selectedKecamatan == null 
                  ? 'Pilih kecamatan terlebih dahulu' 
                  : 'Pilih Kelurahan',
              prefixIcon: const Icon(Icons.apartment_outlined),
            ),
          ),
        ),
      ],
    );
  }

  // ── STEP 2: Usaha ──────────────────────────────────────
  Widget _buildStep2() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFieldContainer(
          label: 'Nama Usaha',
          sensitivity: _Sensitivity.publik,
          child: _buildField(
            controller: _namaUsahaController,
            hint: 'Masukkan nama usaha/brand',
            icon: Icons.storefront_outlined,
            validator: _required,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Sub-Sektor Ekraf',
          sensitivity: _Sensitivity.publik,
          child: _buildDropdown(
            label: 'Pilih Sub-Sektor',
            value: _selectedSubSektor,
            items: subSektorEkraf,
            icon: Icons.category_outlined,
            onChanged: (v) => setState(() => _selectedSubSektor = v),
            validator: (v) => v == null ? 'Pilih sub-sektor' : null,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Deskripsi Usaha',
          sensitivity: _Sensitivity.publik,
          child: _buildField(
            controller: _deskripsiController,
            hint: 'Jelaskan usaha Anda secara singkat...',
            icon: Icons.description_outlined,
            maxLines: 4,
            validator: _required,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFieldContainer(
                label: 'Tahun Berdiri',
                sensitivity: _Sensitivity.publik,
                child: _buildField(
                  controller: _tahunBerdiriController,
                  hint: 'Contoh: 2020',
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    final year = int.tryParse(v);
                    if (year == null || year < 1900 || year > DateTime.now().year) {
                      return 'Tahun tidak valid';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFieldContainer(
                label: 'Jumlah Karyawan',
                sensitivity: _Sensitivity.publik,
                child: _buildField(
                  controller: _karyawanController,
                  hint: 'Karyawan',
                  icon: Icons.group_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _required,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Omzet Per Bulan',
          sensitivity: _Sensitivity.publik,
          child: _buildDropdown(
            label: 'Pilih Rentang Omzet',
            value: _selectedOmzet,
            items: omzetRanges,
            icon: Icons.attach_money_rounded,
            onChanged: (v) => setState(() => _selectedOmzet = v),
            validator: (v) => v == null ? 'Pilih rentang omzet' : null,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Lokasi & Alamat Tempat Usaha (Workshop/Galeri/Toko)',
          sensitivity: _Sensitivity.publik,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _alamatUsahaSamaDenganDomisili
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.outlineVariant,
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  activeTrackColor: AppColors.primary,
                  activeThumbColor: Colors.white,
                  title: Text(
                    'Alamat Usaha sama dengan Domisili Pemilik',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    _alamatUsahaSamaDenganDomisili
                        ? 'Menggunakan alamat domisili pemilik di Step 1 sebagai lokasi usaha.'
                        : 'Usaha/workshop beroperasi di lokasi berbeda dari alamat rumah.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: _alamatUsahaSamaDenganDomisili,
                  onChanged: (val) {
                    setState(() {
                      _alamatUsahaSamaDenganDomisili = val;
                    });
                  },
                ),
              ),
              if (!_alamatUsahaSamaDenganDomisili) ...[
                const SizedBox(height: 16),
                _buildField(
                  controller: _alamatUsahaController,
                  hint: 'Alamat lengkap tempat usaha/workshop (Jl, No, RT/RW)...',
                  icon: Icons.store_mall_directory_outlined,
                  maxLines: 2,
                  validator: (v) {
                    if (!_alamatUsahaSamaDenganDomisili && (v == null || v.trim().isEmpty)) {
                      return 'Alamat usaha wajib diisi jika berbeda dari domisili';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedKecamatanUsaha,
                  items: () {
                    final List<String> effectiveList = List<String>.from(kecamatanList);
                    if (_selectedKecamatanUsaha != null && !effectiveList.contains(_selectedKecamatanUsaha)) {
                      effectiveList.add(_selectedKecamatanUsaha!);
                    }
                    return effectiveList
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
                            ))
                        .toList();
                  }(),
                  onChanged: (v) {
                    setState(() {
                      _selectedKecamatanUsaha = v;
                      _selectedKelurahanUsaha = null;
                    });
                  },
                  validator: (v) {
                    if (!_alamatUsahaSamaDenganDomisili && v == null) {
                      return 'Pilih kecamatan lokasi usaha';
                    }
                    return null;
                  },
                  dropdownColor: AppColors.surface,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  decoration: const InputDecoration(
                    hintText: 'Pilih Kecamatan Lokasi Usaha',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedKelurahanUsaha,
                  items: () {
                    final List<String> rawKelurahan = probolinggoData[_selectedKecamatanUsaha] ?? [];
                    final List<String> effectiveList = List<String>.from(rawKelurahan);
                    if (_selectedKelurahanUsaha != null && !effectiveList.contains(_selectedKelurahanUsaha)) {
                      effectiveList.add(_selectedKelurahanUsaha!);
                    }
                    return effectiveList
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
                            ))
                        .toList();
                  }(),
                  onChanged: _selectedKecamatanUsaha == null
                      ? null
                      : (v) {
                          setState(() {
                            _selectedKelurahanUsaha = v;
                          });
                        },
                  validator: (v) {
                    if (!_alamatUsahaSamaDenganDomisili && v == null) {
                      return 'Pilih kelurahan lokasi usaha';
                    }
                    return null;
                  },
                  dropdownColor: AppColors.surface,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  decoration: InputDecoration(
                    hintText: _selectedKecamatanUsaha == null
                        ? 'Pilih kecamatan terlebih dahulu'
                        : 'Pilih Kelurahan Lokasi Usaha',
                    prefixIcon: const Icon(Icons.apartment_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _mapsUrlController,
                  hint: 'Link Google Maps Lokasi Usaha (opsional, contoh: https://maps.app.goo.gl/...)',
                  icon: Icons.map_outlined,
                  keyboardType: TextInputType.url,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 3: Legalitas (HAKI) ───────────────────────────
  Widget _buildStep3() {
    final hasHaki = !_selectedHaki.contains(HakiType.belumAda);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFieldContainer(
          label: 'Kekayaan Intelektual (HAKI)',
          sensitivity: _Sensitivity.opsional,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih jenis HAKI yang dimiliki (bisa lebih dari satu):',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: HakiType.values.map((t) {
                  final selected = _selectedHaki.contains(t);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (t == HakiType.belumAda) {
                          _selectedHaki.clear();
                          _selectedHaki.add(HakiType.belumAda);
                        } else {
                          _selectedHaki.remove(HakiType.belumAda);
                          if (selected) {
                            _selectedHaki.remove(t);
                            if (_selectedHaki.isEmpty) _selectedHaki.add(HakiType.belumAda);
                          } else {
                            _selectedHaki.add(t);
                          }
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: selected ? AppColors.primary : AppColors.outlineVariant,
                            width: selected ? 1.5 : 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: selected ? AppColors.primary : AppColors.textHint,
                          ),
                          const SizedBox(width: 8),
                          Text(_hakiLabel(t),
                              style: GoogleFonts.inter(
                                  color: selected ? AppColors.primary : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        if (hasHaki) ...[
          const SizedBox(height: 16),
          _buildFieldContainer(
            label: 'Nomor HAKI',
            sensitivity: _Sensitivity.opsional,
            child: _buildField(
              controller: _nomorHakiController,
              hint: 'Contoh: HKI-01.02.03...',
              icon: Icons.tag_rounded,
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldContainer(
            label: 'Tahun Pendaftaran HAKI',
            sensitivity: _Sensitivity.opsional,
            child: _buildField(
              controller: _tahunHakiController,
              hint: 'Contoh: 2022',
              icon: Icons.calendar_month_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
            ),
          ),
        ],
      ],
    );
  }

  // ── STEP 4: Produk ─────────────────────────────────────
  Widget _buildStep4() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFieldContainer(
          label: 'Nama Produk Unggulan',
          sensitivity: _Sensitivity.publik,
          child: _buildField(
            controller: _namaProdukController,
            hint: 'Masukkan nama produk terlaris/unggulan',
            icon: Icons.star_outline_rounded,
            validator: _required,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Harga / Kisaran Harga',
          sensitivity: _Sensitivity.publik,
          child: _buildField(
            controller: _hargaController,
            hint: 'Contoh: Rp 50.000',
            icon: Icons.sell_outlined,
            validator: _required,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Link Marketplace / Toko Online',
          sensitivity: _Sensitivity.opsional,
          child: _buildField(
            controller: _marketplaceController,
            hint: 'https://shopee.co.id/... atau Tokopedia/Instagram',
            icon: Icons.store_outlined,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldContainer(
          label: 'Foto Produk Unggulan',
          sensitivity: _Sensitivity.publik,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_allProductImages.isNotEmpty) ...[
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _allProductImages.length,
                    itemBuilder: (context, index) {
                      final item = _allProductImages[index];
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: item is File 
                                    ? FileImage(item) as ImageProvider
                                    : NetworkImage(item as String),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _allProductImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_allProductImages.length < 5)
                GestureDetector(
                  onTap: _pickProductImage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 24),
                        const SizedBox(height: 8),
                        Text(
                          'Unggah Foto Produk (${_allProductImages.length}/5)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG/PNG (Maksimal 5MB)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 5: Review (Ringkasan Lengkap) ──────────────────
  Widget _buildStep5() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReviewSection(
          title: 'Review Identitas Pelaku',
          icon: Icons.person_outline,
          items: [
            _SummaryRow('Nama', _namaController.text),
            _SummaryRow('NIK', _nikController.text),
            _SummaryRow('WhatsApp', _noHpController.text),
            _SummaryRow('Email', _emailController.text.isEmpty ? '-' : _emailController.text),
            _SummaryRow('Alamat', '${_alamatController.text}, Kel. ${_selectedKelurahan ?? ''}, Kec. ${_selectedKecamatan ?? ''}'),
          ],
        ),
        const SizedBox(height: 16),
        _buildReviewSection(
          title: 'Review Data Usaha',
          icon: Icons.storefront_outlined,
          items: [
            _SummaryRow('Nama Usaha', _namaUsahaController.text),
            _SummaryRow('Sub-Sektor', _selectedSubSektor ?? '-'),
            _SummaryRow('Deskripsi', _deskripsiController.text),
            _SummaryRow('Berdiri', _tahunBerdiriController.text),
            _SummaryRow('Karyawan', '${_karyawanController.text} orang'),
            _SummaryRow('Omzet', _selectedOmzet ?? '-'),
            _SummaryRow(
              'Lokasi Usaha',
              _alamatUsahaSamaDenganDomisili
                  ? 'Sama dengan alamat domisili pemilik'
                  : '${_alamatUsahaController.text}, Kel. ${_selectedKelurahanUsaha ?? ''}, Kec. ${_selectedKecamatanUsaha ?? ''}',
            ),
            if (!_alamatUsahaSamaDenganDomisili && _mapsUrlController.text.isNotEmpty)
              _SummaryRow('Link Maps Usaha', _mapsUrlController.text),
          ],
        ),
        const SizedBox(height: 16),
        _buildReviewSection(
          title: 'Review Legalitas & Produk',
          icon: Icons.gavel_outlined,
          items: [
            _SummaryRow('HAKI', _selectedHaki.map((t) => _hakiLabel(t)).join(', ')),
            if (_nomorHakiController.text.isNotEmpty)
              _SummaryRow('No. HAKI', _nomorHakiController.text),
            _SummaryRow('Produk', _namaProdukController.text),
            _SummaryRow('Harga', _hargaController.text),
            _SummaryRow('Toko Online', _marketplaceController.text.isEmpty ? '-' : _marketplaceController.text),
          ],
        ),
        const SizedBox(height: 16),
        _buildWarningBox('Pastikan semua data di atas sudah benar sebelum menyimpan data.'),
      ],
    );
  }

  // ── Sub-components / Helpers ───────────────────────────
  Widget _buildFieldContainer({
    required String label,
    required _Sensitivity sensitivity,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: sensitivity == _Sensitivity.sensitif 
              ? AppColors.error.withValues(alpha: 0.15) 
              : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildSensitivityBadge(sensitivity),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSensitivityBadge(_Sensitivity s) {
    Color bgColor;
    Color textColor;
    String label;
    IconData? icon;

    switch (s) {
      case _Sensitivity.publik:
        bgColor = AppColors.tertiary.withValues(alpha: 0.1);
        textColor = AppColors.tertiary;
        label = 'PUBLIK';
        break;
      case _Sensitivity.privat:
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        label = 'PRIVAT';
        break;
      case _Sensitivity.sensitif:
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        label = 'SENSITIF';
        icon = Icons.lock_rounded;
        break;
      case _Sensitivity.opsional:
        bgColor = AppColors.surfaceContainer;
        textColor = AppColors.textSecondary;
        label = 'OPSIONAL';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildWarningBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onErrorContainer,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required String title,
    required IconData icon,
    required List<_SummaryRow> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      readOnly: readOnly,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    // Cegah crash jika nilai dari database tidak ada di list pilihan dropdown
    final List<String> effectiveItems = List<String>.from(items);
    if (value != null && !effectiveItems.contains(value)) {
      effectiveItems.add(value);
    }

    return DropdownButtonFormField<String>(
      initialValue: value,
      items: effectiveItems
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text(s, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      dropdownColor: AppColors.surface,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.outlineVariant),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Kembali', style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleNext,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(_currentStep < _stepTitles.length - 1 ? 'Lanjut' : 'Simpan Data'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logic ──────────────────────────────────────────────
  Future<void> _handleNext() async {
    if (_currentStep < _stepTitles.length - 1) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else {
      if (!_formKey.currentState!.validate()) return;
      if (_allProductImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon unggah minimal 1 foto produk unggulan.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() => _isSaving = true);

      try {
        final List<String> uploadedUrls = [];
        final authProvider = context.read<AuthProvider>();
        final userId = authProvider.currentUser?.id ?? '';
        final isAdmin = authProvider.currentUser?.isAdmin == true;
        final ekrafProvider = context.read<EkrafProvider>();

        for (int i = 0; i < _allProductImages.length; i++) {
          final item = _allProductImages[i];
          if (item is String) {
            uploadedUrls.add(item);
          } else if (item is File) {
            final compressedBytes = await FlutterImageCompress.compressWithFile(
              item.absolute.path,
              minWidth: 1080,
              minHeight: 1080,
              quality: 70,
              format: CompressFormat.webp,
            );
            final bytes = compressedBytes ?? await item.readAsBytes();
            final fileExt = compressedBytes != null ? 'webp' : item.path.split('.').last;
            final path = 'products/${userId}_${DateTime.now().millisecondsSinceEpoch}_$i.$fileExt';

            // Unggah ke bucket 'profiles'
            await Supabase.instance.client.storage.from('profiles').uploadBinary(path, bytes);
            final publicUrl = Supabase.instance.client.storage.from('profiles').getPublicUrl(path);
            uploadedUrls.add(publicUrl);
          }
        }

        final effectiveAlamatUsaha = _alamatUsahaSamaDenganDomisili
            ? _alamatController.text.trim()
            : _alamatUsahaController.text.trim();
        final effectiveKecamatanUsaha = _alamatUsahaSamaDenganDomisili
            ? (_selectedKecamatan ?? '')
            : (_selectedKecamatanUsaha ?? '');
        final effectiveKelurahanUsaha = _alamatUsahaSamaDenganDomisili
            ? (_selectedKelurahan ?? '')
            : (_selectedKelurahanUsaha ?? '');
        final effectiveMapsUrl = _mapsUrlController.text.trim().isEmpty
            ? null
            : _mapsUrlController.text.trim();

        if (widget.data != null) {
          // Mode Edit: update data yang sudah ada
          final updatedData = EkrafData(
            id: widget.data!.id,
            userId: widget.data!.userId,
            createdAt: widget.data!.createdAt,
            namaLengkap: _namaController.text.trim(),
            nik: _nikController.text.trim(),
            noHp: _noHpController.text.trim(),
            email: _emailController.text.trim(),
            alamat: _alamatController.text.trim(),
            kecamatan: _selectedKecamatan ?? '',
            kelurahan: _selectedKelurahan ?? '',
            namaUsaha: _namaUsahaController.text.trim(),
            subSektor: _selectedSubSektor ?? '',
            deskripsiUsaha: _deskripsiController.text.trim(),
            tahunBerdiri: _tahunBerdiriController.text.trim(),
            jumlahKaryawan: int.tryParse(_karyawanController.text) ?? 0,
            omzetPerBulan: _selectedOmzet ?? '',
            alamatUsaha: effectiveAlamatUsaha,
            kecamatanUsaha: effectiveKecamatanUsaha,
            kelurahanUsaha: effectiveKelurahanUsaha,
            mapsUrl: effectiveMapsUrl,
            hakiTypes: _selectedHaki.toList(),
            nomorHaki: _nomorHakiController.text.isEmpty ? null : _nomorHakiController.text,
            tahunHaki: _tahunHakiController.text.isEmpty ? null : _tahunHakiController.text,
            productImagePaths: uploadedUrls,
            namaProdukUnggulan: _namaProdukController.text.trim(),
            hargaProduk: _hargaController.text.trim(),
            linkMarketplace: _marketplaceController.text.isEmpty ? null : _marketplaceController.text,
            status: isAdmin
                ? widget.data!.status
                : VerificationStatus.pending,
            catatanAdmin: isAdmin
                ? widget.data!.catatanAdmin
                : null, // Reset catatan admin penolakan jika pelaku mengedit datanya kembali
          );

          await ekrafProvider.updateEntry(updatedData);
        } else {
          // Mode Tambah Baru
          final newData = EkrafData(
            userId: userId,
            namaLengkap: _namaController.text.trim(),
            nik: _nikController.text.trim(),
            noHp: _noHpController.text.trim(),
            email: _emailController.text.trim(),
            alamat: _alamatController.text.trim(),
            kecamatan: _selectedKecamatan ?? '',
            kelurahan: _selectedKelurahan ?? '',
            namaUsaha: _namaUsahaController.text.trim(),
            subSektor: _selectedSubSektor ?? '',
            deskripsiUsaha: _deskripsiController.text.trim(),
            tahunBerdiri: _tahunBerdiriController.text.trim(),
            jumlahKaryawan: int.tryParse(_karyawanController.text) ?? 0,
            omzetPerBulan: _selectedOmzet ?? '',
            alamatUsaha: effectiveAlamatUsaha,
            kecamatanUsaha: effectiveKecamatanUsaha,
            kelurahanUsaha: effectiveKelurahanUsaha,
            mapsUrl: effectiveMapsUrl,
            hakiTypes: _selectedHaki.toList(),
            nomorHaki: _nomorHakiController.text.isEmpty ? null : _nomorHakiController.text,
            tahunHaki: _tahunHakiController.text.isEmpty ? null : _tahunHakiController.text,
            productImagePaths: uploadedUrls,
            namaProdukUnggulan: _namaProdukController.text.trim(),
            hargaProduk: _hargaController.text.trim(),
            linkMarketplace: _marketplaceController.text.isEmpty ? null : _marketplaceController.text,
          );

          await ekrafProvider.addEntry(newData);
        }

        if (mounted) {
          setState(() => _isSaving = false);
          Navigator.pop(context, true); // Return true to indicate data changed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil disimpan!'),
              backgroundColor: AppColors.tertiary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan data: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar Form?', style: GoogleFonts.inter(color: AppColors.textPrimary)),
        content: Text('Data yang sudah diisi akan hilang.',
            style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.isEmpty) ? 'Field ini wajib diisi' : null;

  String _hakiLabel(HakiType t) {
    switch (t) {
      case HakiType.merek: return 'Merek';
      case HakiType.hakCipta: return 'Hak Cipta';
      case HakiType.paten: return 'Paten';
      case HakiType.desainIndustri: return 'Desain Industri';
      case HakiType.belumAda: return 'Belum Ada';
    }
  }
}

enum _Sensitivity {
  publik,
  privat,
  sensitif,
  opsional,
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(label,
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13))),
          const Text(': ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
              child: Text(value,
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
