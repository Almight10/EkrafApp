import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../models/ekraf_data.dart';

class LengkapiProfileScreen extends StatefulWidget {
  const LengkapiProfileScreen({super.key});

  @override
  State<LengkapiProfileScreen> createState() => _LengkapiProfileScreenState();
}

class _LengkapiProfileScreenState extends State<LengkapiProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();

  String? _selectedKecamatan;
  String? _selectedKelurahan;
  File? _fotoFile;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Prefill data dari profil user secara sinkron agar langsung muncul tanpa kedipan/delay
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      if (user.noHp != null) {
        _noHpController.text = user.noHp!;
      }
      if (user.nik != null) {
        _nikController.text = user.nik!;
      }
      if (user.alamat != null) {
        _alamatController.text = user.alamat!;
      }
      if (user.kecamatan != null) {
        _selectedKecamatan = user.kecamatan;
      }
      if (user.kelurahan != null) {
        _selectedKelurahan = user.kelurahan;
      }
    }
  }

  @override
  void dispose() {
    _nikController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
                final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                if (picked != null) {
                  setState(() {
                    _fotoFile = File(picked.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.of(context).pop();
                final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                if (picked != null) {
                  setState(() {
                    _fotoFile = File(picked.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadToStorage(File file, String folder, String userId) async {
    final bytes = await file.readAsBytes();
    final fileExt = file.path.split('.').last;
    final path = '$folder/${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    try {
      // Upload ke bucket 'profiles'
      await Supabase.instance.client.storage.from('profiles').uploadBinary(path, bytes);
      final publicUrl = Supabase.instance.client.storage.from('profiles').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception(
        'Gagal mengunggah foto ke Storage. Pastikan Anda telah membuat bucket PUBLIC bernama "profiles" dan menyetel RLS Permission (Policy) di dashboard Supabase Anda. Detail: $e',
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    final existingFotoUrl = authProvider.currentUser?.fotoUrl;

    // Foto profil wajib diisi jika belum ada di database
    if (_fotoFile == null && (existingFotoUrl == null || existingFotoUrl.isEmpty)) {
      _showErrorSnackBar('Mohon unggah foto diri (profil) Anda.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = authProvider.currentUser!.id;

      // 1. Upload Foto ke Supabase Storage jika memilih file baru
      String? fotoUrl = existingFotoUrl;
      if (_fotoFile != null) {
        fotoUrl = await _uploadToStorage(_fotoFile!, 'foto_diri', userId);
      }

      // 2. Update data profil pelaku di database
      await authProvider.updateProfile(
        nik: _nikController.text,
        alamat: _alamatController.text,
        kecamatan: _selectedKecamatan ?? '',
        kelurahan: _selectedKelurahan ?? '',
        ktpUrl: null, // Diisi null karena KTP dihapus
        fotoUrl: fotoUrl,
        noHp: _noHpController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profil pelaku ekraf berhasil diperbarui!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF005228),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profil & Data Diri',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Profil Pelaku Ekraf',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mohon isi data di bawah dengan benar untuk keperluan verifikasi oleh dinas terkait.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // NIK
                  _buildLabel('NIK (Nomor Induk Kependudukan)'),
                  TextFormField(
                    controller: _nikController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan 16 digit NIK Anda',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    style: GoogleFonts.inter(),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'NIK wajib diisi.';
                      if (v.length != 16) return 'NIK harus tepat 16 digit.';
                      if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'NIK hanya boleh berisi angka.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Nomor HP / WA
                  _buildLabel('Nomor WhatsApp / HP'),
                  TextFormField(
                    controller: _noHpController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 081234567890',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    style: GoogleFonts.inter(),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Nomor HP/WA wajib diisi.';
                      if (v.length < 10 || v.length > 15) return 'Nomor HP harus berdurasi 10-15 digit.';
                      if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Nomor HP hanya boleh berisi angka.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Alamat Lengkap
                  _buildLabel('Alamat Lengkap'),
                  TextFormField(
                    controller: _alamatController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Jalan, RT/RW, Dusun',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                    style: GoogleFonts.inter(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Alamat lengkap wajib diisi.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Kecamatan Dropdown
                  _buildLabel('Kecamatan'),
                  DropdownButtonFormField<String>(
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
                    onChanged: (v) {
                      setState(() {
                        _selectedKecamatan = v;
                        _selectedKelurahan = null; // Reset Kelurahan saat Kecamatan berubah
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
                  const SizedBox(height: 20),

                  // Kelurahan Dropdown
                  _buildLabel('Kelurahan'),
                  DropdownButtonFormField<String>(
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
                    onChanged: _selectedKecamatan == null 
                        ? null 
                        : (v) => setState(() => _selectedKelurahan = v),
                    validator: (v) => v == null ? 'Pilih kelurahan' : null,
                    dropdownColor: AppColors.surface,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    decoration: InputDecoration(
                      hintText: _selectedKecamatan == null 
                          ? 'Pilih kecamatan terlebih dahulu' 
                          : 'Pilih Kelurahan',
                      prefixIcon: const Icon(Icons.map_outlined),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Upload Section (Hanya Foto Diri / Profil)
                  Center(
                    child: SizedBox(
                      width: 220,
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return _buildImageSelector(
                            'Foto Diri (Profil)',
                            _fotoFile,
                            auth.currentUser?.fotoUrl,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 20),
                        Text(
                          'Sedang menyimpan perubahan...',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mohon tunggu sebentar',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildImageSelector(String title, File? file, String? networkUrl) {
    final bool hasImage = file != null || (networkUrl != null && networkUrl.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLabel(title),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: hasImage ? Colors.white : AppColors.primary.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasImage ? AppColors.primary : AppColors.divider,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: hasImage
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.5),
                        child: file != null
                            ? Image.file(
                                file,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                networkUrl!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image_outlined, color: AppColors.error, size: 36),
                                ),
                              ),
                      ),
                      // Overlay edit indicator
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cached_rounded, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Ubah',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Checkmark badge
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_search_outlined,
                          size: 26,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Unggah Foto Profil',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap untuk pilih berkas',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
