import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/ekraf_data.dart';
import '../providers/ekraf_provider.dart';
import '../providers/auth_provider.dart';
import 'input_form_screen.dart';
import 'login_screen.dart';
import 'data_list_screen.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    final initials = user?.namaLengkap.isNotEmpty == true
        ? user!.namaLengkap.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : 'AD';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.store_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'Ekraf Admin',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: GestureDetector(
              onTap: _logout,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryContainer, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
                      child: _buildWelcomeCard(user?.namaLengkap ?? 'Admin'),
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

  Widget _buildWelcomeCard(String name) {
    final greeting = _getGreeting();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004787), Color(0xFF0B5FAE), Color(0xFF1A73C8)],
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
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: 30,
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
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.admin_panel_settings_outlined,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Admin Dinas',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                greeting,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name.split(' ').first,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kelola data pelaku ekonomi kreatif Kota Kendari',
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Data',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total',
                  value: total,
                  icon: Icons.dataset_outlined,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF414751), Color(0xFF727783)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconBg: const Color(0xFFEDEEEF),
                  iconColor: const Color(0xFF414751),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'Menunggu',
                  value: pending,
                  icon: Icons.pending_actions_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB06000), Color(0xFFD97B00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconBg: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFB06000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Disetujui',
                  value: verified,
                  icon: Icons.check_circle_outline_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF005228), Color(0xFF006D37)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF005228),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'Ditolak',
                  value: rejected,
                  icon: Icons.cancel_outlined,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBA1A1A), Color(0xFFD32F2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconBg: const Color(0xFFFFEBEB),
                  iconColor: const Color(0xFFBA1A1A),
                ),
              ),
            ],
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

    final barColors = [
      AppColors.primary,
      const Color(0xFF006D37),
      const Color(0xFFB06000),
      const Color(0xFF7B1FA2),
      const Color(0xFFBA1A1A),
    ];

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'Sub-sektor Terbanyak',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
              final color = barColors[i % barColors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${entry.value} usaha',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: AnimatedBuilder(
                        animation: _chartBarAnim,
                        builder: (_, __) => LinearProgressIndicator(
                          value: percentage * _chartBarAnim.value,
                          backgroundColor: AppColors.surfaceContainer,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.pending_actions_rounded,
                        size: 18, color: Color(0xFFB06000)),
                  ),
                  const SizedBox(width: 10),
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DataListScreen()),
                ),
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
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.card,
              ),
              child: Column(
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
                    style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tidak ada antrian persetujuan',
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

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final LinearGradient gradient;
  final Color iconBg;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) =>
                gradient.createShader(bounds),
            child: const Icon(Icons.trending_up_rounded,
                size: 18, color: Colors.white),
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
    final dt = widget.data.createdAt;
    final dateStr =
        '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Transform.scale(
          scale: _pressed ? 0.97 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryFixed, Color(0xFFD5E3FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.namaUsaha,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.data.subSektor,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(
                            fontSize: 10, color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 10, color: Color(0xFFB06000)),
                      const SizedBox(width: 3),
                      Text(
                        'Review',
                        style: GoogleFonts.inter(
                            color: const Color(0xFFB06000),
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


