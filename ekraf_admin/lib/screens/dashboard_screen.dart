import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/ekraf_data.dart';
import '../providers/ekraf_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'input_form_screen.dart';
import 'login_screen.dart';
import 'data_list_screen.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToDataList;
  const DashboardScreen({super.key, this.onNavigateToDataList});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late AnimationController _cardsCtrl;
  late AnimationController _listCtrl;
  late AnimationController _chartBarCtrl;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _cardsFade;
  late Animation<double> _listFade;
  late Animation<Offset> _listSlide;
  late Animation<double> _chartBarAnim;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _cardsCtrl = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _listCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _chartBarCtrl = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this);

    _headerFade =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _cardsFade =
        CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOutCubic);
    _listFade = CurvedAnimation(parent: _listCtrl, curve: Curves.easeOutCubic);
    _listSlide = Tween<Offset>(
            begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _listCtrl, curve: Curves.easeOutCubic));
    _chartBarAnim = CurvedAnimation(
        parent: _chartBarCtrl, curve: Curves.easeOutCubic);

    // Stagger the animations
    Future.delayed(const Duration(milliseconds: 50), _headerCtrl.forward);
    Future.delayed(const Duration(milliseconds: 200), _cardsCtrl.forward);
    Future.delayed(const Duration(milliseconds: 350), _listCtrl.forward);
    Future.delayed(const Duration(milliseconds: 450), _chartBarCtrl.forward);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EkrafProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _cardsCtrl.dispose();
    _listCtrl.dispose();
    _chartBarCtrl.dispose();
    super.dispose();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Logout',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final authProvider = context.read<AuthProvider>();
              authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const LoginScreen(),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Keluar', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        heroTag: 'admin_dashboard_fab',
        onPressed: () async {
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
        icon: const Icon(Icons.add_rounded),
        label: Text('Tambah Data', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: Consumer<EkrafProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: provider.loadData,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: _buildWelcomeCard(user),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _cardsFade,
                    child: _buildStatCards(provider),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _listFade,
                    child: SlideTransition(
                      position: _listSlide,
                      child: _buildSubSectorChart(provider),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _listFade,
                    child: SlideTransition(
                      position: _listSlide,
                      child: _buildAntrianSection(context, provider),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(AppUser? user) {
    if (user == null) return const SizedBox.shrink();

    final initials = user.namaLengkap.isNotEmpty
        ? user.namaLengkap.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : 'AD';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                              const Icon(Icons.admin_panel_settings_outlined,
                                  size: 10, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Admin Dinas',
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
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          size: 18, color: Colors.white),
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
                    'Petunjuk Admin',
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
                title: 'Verifikasi Pengajuan',
                desc: 'Anda dapat meninjau data pelaku Ekraf baru yang masuk di bagian antrian verifikasi.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                number: '2',
                title: 'Filter & Cari Data',
                desc: 'Gunakan fitur pencarian untuk mempermudah pengecekan data berdasarkan nama, NIK, atau subsektor.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                number: '3',
                title: 'Ubah Status',
                desc: 'Buka detail pengajuan dan pilih verifikasi untuk menerima, menolak (sertakan alasan), atau meminta perbaikan data.',
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


  Widget _buildStatCards(EkrafProvider provider) {
    final total = provider.data.length;
    final verified =
        provider.data.where((d) => d.status == VerificationStatus.verified).length;
    final pending =
        provider.data.where((d) => d.status == VerificationStatus.pending).length;
    final rejected =
        provider.data.where((d) => d.status == VerificationStatus.rejected).length;

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

  Widget _buildSubSectorChart(EkrafProvider provider) {
    final Map<String, int> subSectorCounts = {};
    for (var item in provider.data) {
      subSectorCounts[item.subSektor] =
          (subSectorCounts[item.subSektor] ?? 0) + 1;
    }
    final sortedSubSectors = subSectorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSubSectors = sortedSubSectors.take(5).toList();
    final maxCount = topSubSectors.isNotEmpty ? topSubSectors.first.value : 1;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Sub-sektor',
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          if (topSubSectors.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada data sub-sektor',
                  style:
                      GoogleFonts.inter(color: AppColors.textHint, fontSize: 13),
                ),
              ),
            )
          else
            ...List.generate(topSubSectors.length, (i) {
              final entry = topSubSectors[i];
              final percentage = entry.value / maxCount;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    // Nama sub-sektor
                    SizedBox(
                      width: 72,
                      child: Text(
                        entry.key,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: AnimatedBuilder(
                          animation: _chartBarAnim,
                          builder: (_, __) => LinearProgressIndicator(
                            value: percentage * _chartBarAnim.value,
                            backgroundColor: AppColors.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                            minHeight: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Angka
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${entry.value}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAntrianSection(BuildContext context, EkrafProvider provider) {
    final pending = provider.data
        .where((d) => d.status == VerificationStatus.pending)
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Antrian Persetujuan',
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  if (pending.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB06000),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pending.length}',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              TextButton(
                onPressed: () {
                  final cb = widget.onNavigateToDataList;
                  if (cb != null) {
                    cb();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DataListScreen()),
                    );
                  }
                },
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pending.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.checklist_rounded,
                        size: 36, color: Color(0xFF005228)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Semua sudah diproses!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tidak ada antrian persetujuan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: AppColors.textHint, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ...pending.take(3).map((data) => _AntrianCard(
                  data: data,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(data: data)),
                  ).then((_) {
                    if (mounted) provider.loadData();
                  }),
                )),
        ],
      ),
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

// ── Antrian Card ──────────────────────────────────────────────────────────────
class _AntrianCard extends StatefulWidget {
  final EkrafData data;
  final VoidCallback onTap;

  const _AntrianCard({required this.data, required this.onTap});

  @override
  State<_AntrianCard> createState() => _AntrianCardState();
}

class _AntrianCardState extends State<_AntrianCard> {
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

    final initials = data.namaLengkap.isNotEmpty
        ? data.namaLengkap.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : 'P';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
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
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryFixed,
                      backgroundImage: (data.fotoUrl != null && data.fotoUrl!.isNotEmpty)
                          ? NetworkImage(data.fotoUrl!)
                          : null,
                      child: (data.fotoUrl != null && data.fotoUrl!.isNotEmpty)
                          ? null
                          : Text(
                              initials,
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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


