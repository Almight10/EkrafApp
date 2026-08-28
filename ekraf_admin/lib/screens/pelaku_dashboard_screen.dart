import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/ekraf_data.dart';
import '../providers/ekraf_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'input_form_screen.dart';
import 'detail_screen.dart';
import 'lengkapi_profile_screen.dart';
import 'pelaku_data_list_screen.dart';

class PelakuDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToDataList;
  const PelakuDashboardScreen({super.key, this.onNavigateToDataList});

  @override
  State<PelakuDashboardScreen> createState() => _PelakuDashboardScreenState();
}

class _PelakuDashboardScreenState extends State<PelakuDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late AnimationController _listCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _listFade;
  late Animation<Offset> _listSlide;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
        duration: const Duration(milliseconds: 650), vsync: this);
    _listCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic);
    _heroSlide =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
            .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _listFade = CurvedAnimation(parent: _listCtrl, curve: Curves.easeOutCubic);
    _listSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(CurvedAnimation(parent: _listCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 60), _heroCtrl.forward);
    Future.delayed(const Duration(milliseconds: 280), _listCtrl.forward);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EkrafProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Notifikasi',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Belum ada notifikasi baru',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.help_outline_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Petunjuk Pelaku Ekraf',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildHelpItem(
                number: '1',
                title: 'Ajukan Usaha Anda',
                desc: 'Tekan tombol "Unggah Data Usaha" di kanan bawah untuk mendaftarkan usaha kreatif Anda.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                number: '2',
                title: 'Pantau Verifikasi',
                desc: 'Usaha yang Anda daftarkan akan ditinjau oleh Admin Dinas. Anda bisa memantau statusnya di halaman utama ini.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                number: '3',
                title: 'Revisi Data Usaha',
                desc: 'Jika pengajuan ditolak, baca alasan penolakan dari admin, lalu lakukan perbaikan data dengan menekan tombol perbaikan.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpItem({required String number, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToDataList() {
    final cb = widget.onNavigateToDataList;
    if (cb != null) {
      cb();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PelakuDataListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final ekrafProvider = context.watch<EkrafProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User tidak terautentikasi')),
      );
    }

    final bool hasIncompleteProfile = user.nik == null || user.nik!.trim().isEmpty;

    final userSubmissions = ekrafProvider.data.where((item) {
      return item.userId == user.id ||
          (item.email.isNotEmpty && item.email.toLowerCase() == user.email.toLowerCase()) ||
          (user.nik != null && user.nik!.isNotEmpty && item.nik == user.nik);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final recentSubmissions = userSubmissions.take(3).toList();

    final verified = userSubmissions
        .where((d) => d.status == VerificationStatus.verified)
        .length;
    final pending = userSubmissions
        .where((d) => d.status == VerificationStatus.pending)
        .length;
    final rejected = userSubmissions
        .where((d) => d.status == VerificationStatus.rejected)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 0.38,
                child: Image.asset(
                  'assets/images/logo_dispopar2.png',
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DISPOPAR',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: const Color(0xFFF39200),
                    height: 1.1,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'PROAKTIF',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: const Color(0xFF006885),
                    height: 1.1,
                    letterSpacing: 3.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            color: AppColors.textSecondary,
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, size: 22),
            color: AppColors.textSecondary,
            onPressed: _showHelp,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'pelaku_dashboard_fab',
        onPressed: () async {
          if (hasIncompleteProfile) {
            _showIncompleteProfileAlert();
            return;
          }
          final provider = context.read<EkrafProvider>();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InputFormScreen()),
          );
          if (mounted) provider.loadData();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.upload_file_rounded),
        label: Text('Unggah Data Usaha',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: ekrafProvider.loadData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Custom App Bar inside scroll
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _heroFade,
                child: SlideTransition(
                  position: _heroSlide,
                  child: _buildHeroSection(user),
                ),
              ),
            ),
            if (hasIncompleteProfile)
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _heroFade,
                  child: _buildIncompleteProfileBanner(),
                ),
              ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _heroFade,
                child: _buildStatusSummary(
                    userSubmissions.length, verified, pending, rejected),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _listFade,
                child: SlideTransition(
                  position: _listSlide,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Riwayat Pengajuan',
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary),
                            ),
                            if (userSubmissions.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${userSubmissions.length}',
                                  style: GoogleFonts.inter(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (userSubmissions.length > 3)
                          TextButton(
                            onPressed: _navigateToDataList,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Lihat Usaha',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    size: 11, color: AppColors.primary),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (userSubmissions.isEmpty)
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _listFade,
                  child: SlideTransition(
                    position: _listSlide,
                    child: _buildEmptyState(),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => FadeTransition(
                    opacity: _listFade,
                    child: SubmissionCard(
                      data: recentSubmissions[index],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  DetailScreen(data: recentSubmissions[index])),
                        );
                        if (mounted) ekrafProvider.loadData();
                      },
                    ),
                  ),
                  childCount: recentSubmissions.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(AppUser user) {
    final initials = user.namaLengkap.isNotEmpty
        ? user.namaLengkap.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : 'P';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003A6B), Color(0xFF004787), Color(0xFF0B5FAE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative
          Positioned(
            right: -15,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: ClipOval(
                      child: (user.fotoUrl != null && user.fotoUrl!.isNotEmpty)
                          ? Image.network(
                              user.fotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Text(
                                  initials,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                initials,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.storefront_outlined,
                                  size: 10, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Pelaku Ekraf',
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.namaLengkap,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                        icon: Icons.badge_outlined,
                        text: user.nik ?? '-'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChip(
                        icon: Icons.phone_outlined,
                        text: user.noHp ?? '-'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _InfoChip(icon: Icons.email_outlined, text: user.email),
            ],
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildIncompleteProfileBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // Orange warning bg
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE65100),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Belum Lengkap',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Silakan lengkapi NIK, foto profil, dan alamat lengkap Anda terlebih dahulu agar dapat mengunggah data usaha.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF5D4037),
                        height: 1.4,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LengkapiProfileScreen()),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_note_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Lengkapi Data Diri Sekarang',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showIncompleteProfileAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mohon lengkapi data diri Anda terlebih dahulu sebelum mengunggah data usaha.',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'LENGKAPI',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LengkapiProfileScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusSummary(
      int total, int verified, int pending, int rejected) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: 'Total',
              value: total,
              icon: Icons.folder_outlined,
              color: AppColors.primary,
              bg: AppColors.primaryFixed,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(
              label: 'Disetujui',
              value: verified,
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF005228),
              bg: const Color(0xFFE8F5E9),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(
              label: 'Menunggu',
              value: pending,
              icon: Icons.schedule_rounded,
              color: const Color(0xFFB06000),
              bg: const Color(0xFFFFF3E0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MiniStat(
              label: 'Ditolak',
              value: rejected,
              icon: Icons.cancel_outlined,
              color: AppColors.error,
              bg: AppColors.errorContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_open_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Pengajuan',
            style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Data usaha Anda belum terdaftar.\nTekan tombol di bawah untuk mulai mengajukan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Info Chip ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white70),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Mini Stat Card ────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Submission Card ───────────────────────────────────────────────────────────
class SubmissionCard extends StatefulWidget {
  final EkrafData data;
  final VoidCallback onTap;

  const SubmissionCard({required this.data, required this.onTap, super.key});

  @override
  State<SubmissionCard> createState() => SubmissionCardState();
}

class SubmissionCardState extends State<SubmissionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (data.status) {
      case VerificationStatus.verified:
        statusColor = const Color(0xFF005228);
        statusBg = const Color(0xFFE8F5E9);
        statusIcon = Icons.verified_rounded;
        break;
      case VerificationStatus.rejected:
        statusColor = AppColors.error;
        statusBg = AppColors.errorContainer;
        statusIcon = Icons.cancel_rounded;
        break;
      case VerificationStatus.pending:
        statusColor = const Color(0xFFB06000);
        statusBg = const Color(0xFFFFF3E0);
        statusIcon = Icons.schedule_rounded;
        break;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _pressed ? [] : AppShadows.card,
          border: Border.all(
            color: _pressed
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Transform.scale(
          scale: _pressed ? 0.97 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: (data.productImagePaths.isNotEmpty &&
                              data.productImagePaths.first.trim().isNotEmpty)
                          ? Image.network(
                              data.productImagePaths.first.trim(),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.primaryFixed,
                                child: const Icon(Icons.storefront_rounded,
                                    color: AppColors.primary, size: 22),
                              ),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: AppColors.surfaceContainerLow,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Icon(Icons.storefront_rounded,
                              color: AppColors.primary, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.namaUsaha,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.subSektor,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 11, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          data.statusLabel,
                          style: GoogleFonts.inter(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.outlineVariant),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Diajukan: ${_formatDate(data.createdAt)}',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textHint),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: AppColors.textHint),
                ],
              ),
              if (data.status == VerificationStatus.rejected &&
                  data.catatanAdmin != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data.catatanAdmin!,
                          style: GoogleFonts.inter(
                              color: AppColors.onErrorContainer, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
