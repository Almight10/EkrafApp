import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/ekraf_data.dart';
import '../providers/ekraf_provider.dart';
import '../providers/auth_provider.dart';
import 'detail_screen.dart';
import 'pelaku_dashboard_screen.dart';
import 'input_form_screen.dart';
import 'lengkapi_profile_screen.dart';

class PelakuDataListScreen extends StatefulWidget {
  const PelakuDataListScreen({super.key});

  @override
  State<PelakuDataListScreen> createState() => _PelakuDataListScreenState();
}

class _PelakuDataListScreenState extends State<PelakuDataListScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  VerificationStatus? _filterStatus;
  String? _filterSubSektor;

  final List<String> _statusTabs = ['Semua', 'Menunggu', 'Terverifikasi', 'Ditolak'];
  final Map<int, VerificationStatus?> _statusMap = {
    0: null,
    1: VerificationStatus.pending,
    2: VerificationStatus.verified,
    3: VerificationStatus.rejected,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EkrafProvider>().loadData();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _filterStatus = _statusMap[_tabController.index];
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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

    // Get only this user's submissions
    final userSubmissions = ekrafProvider.data.where((item) {
      return item.userId == user.id ||
          (item.email.isNotEmpty && item.email.toLowerCase() == user.email.toLowerCase()) ||
          (user.nik != null && user.nik!.isNotEmpty && item.nik == user.nik);
    }).toList();

    // Apply local filters
    final filteredList = userSubmissions.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.namaUsaha.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.namaLengkap.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _filterStatus == null || item.status == _filterStatus;
      final matchesSubSektor = _filterSubSektor == null || item.subSektor == _filterSubSektor;

      return matchesSearch && matchesStatus && matchesSubSektor;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daftar Usaha Saya',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'pelaku_datalist_fab',
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
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          _buildResultInfo(filteredList.length),
          Expanded(child: _buildList(filteredList)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari nama usaha...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: (_filterSubSektor != null)
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (_filterSubSektor != null)
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
            ),
            child: PopupMenuButton<String>(
              initialValue: _filterSubSektor ?? '',
              constraints: const BoxConstraints(maxHeight: 350, minWidth: 200),
              onSelected: (val) {
                setState(() {
                  _filterSubSektor = val.isEmpty ? null : val;
                });
              },
              icon: Icon(
                Icons.filter_list_rounded,
                color: (_filterSubSektor != null) ? AppColors.primary : AppColors.textSecondary,
              ),
              tooltip: 'Filter Sub-sektor',
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              offset: const Offset(0, 50),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: '',
                    child: Text(
                      'Semua Sektor',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: _filterSubSektor == null ? FontWeight.bold : FontWeight.normal,
                        color: _filterSubSektor == null ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...subSektorEkraf.map((s) => PopupMenuItem<String>(
                    value: s,
                    child: Text(
                      s,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: _filterSubSektor == s ? FontWeight.bold : FontWeight.normal,
                        color: _filterSubSektor == s ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  )),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          const Divider(height: 1),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: _statusTabs.map((t) => Tab(text: t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultInfo(int count) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        'Menampilkan $count usaha',
        style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildList(List<EkrafData> filteredList) {
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text('Tidak ada data ditemukan',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Coba ubah filter atau kata kunci pencarian',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textHint)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      itemCount: filteredList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, i) => SubmissionCard(
        data: filteredList[i],
        onTap: () {
          final provider = context.read<EkrafProvider>();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(data: filteredList[i])),
          ).then((_) {
            if (mounted) {
              provider.loadData();
            }
          });
        },
      ),
    );
  }
}
