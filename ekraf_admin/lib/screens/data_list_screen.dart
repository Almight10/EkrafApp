import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/ekraf_data.dart';
import '../providers/ekraf_provider.dart';
import 'detail_screen.dart';
import 'input_form_screen.dart';

class DataListScreen extends StatefulWidget {
  const DataListScreen({super.key});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

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
    final status = _statusMap[_tabController.index];
    context.read<EkrafProvider>().setFilterStatus(status);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Data Ekraf',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<EkrafProvider>().clearFilters();
              _searchController.clear();
              _tabController.index = 0;
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Filter',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'admin_datalist_fab',
        onPressed: () async {
          final provider = context.read<EkrafProvider>();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InputFormScreen()),
          );
          if (mounted) provider.loadData();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: Consumer<EkrafProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildSearchBar(provider),
              _buildSubSectorChips(provider),
              _buildTabBar(),
              _buildResultInfo(provider),
              Expanded(child: _buildList(context, provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(EkrafProvider provider) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: provider.setSearch,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Cari nama, usaha, NIK...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearch('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSubSectorChips(EkrafProvider provider) {
    final subSectors = [
      'Semua Sektor',
      'Kuliner',
      'Kriya',
      'Fesyen',
      'Musik',
      'Aplikasi',
      'Film & Animasi',
    ];

    return Container(
      color: AppColors.surface,
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: subSectors.length,
        itemBuilder: (context, i) {
          final label = subSectors[i];
          final isAll = label == 'Semua Sektor';
          final isSelected = isAll
              ? provider.filterSubSektor == null
              : provider.filterSubSektor == label;

          return FilterChip(
            label: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.onPrimary : AppColors.textSecondary)),
            selected: isSelected,
            onSelected: (_) {
              provider.setFilterSubSektor(isAll ? null : label);
            },
            showCheckmark: false,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceContainerLow,
            side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.outlineVariant),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          );
        },
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

  Widget _buildResultInfo(EkrafProvider provider) {
    final count = provider.data.length;
    return Container(
      color: AppColors.surfaceContainerLow,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        '$count data ditemukan',
        style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildList(BuildContext context, EkrafProvider provider) {
    final data = provider.data;

    if (data.isEmpty) {
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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: provider.loadData,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => _EkrafListItem(
          data: data[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(data: data[i])),
          ).then((_) => provider.loadData()),
        ),
      ),
    );
  }
}

// ── List item card ─────────────────────────────────────────────────────────────

class _EkrafListItem extends StatelessWidget {
  final EkrafData data;
  final VoidCallback onTap;
  const _EkrafListItem({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;

    switch (data.status) {
      case VerificationStatus.verified:
        statusColor = AppColors.tertiary;
        statusLabel = 'Approved';
        break;
      case VerificationStatus.rejected:
        statusColor = AppColors.error;
        statusLabel = 'Rejected';
        break;
      default:
        statusColor = AppColors.secondary;
        statusLabel = 'Submitted';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.surfaceContainer,
                  child: Text(
                    data.namaLengkap.isNotEmpty ? data.namaLengkap[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data.namaLengkap,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              statusLabel,
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.namaUsaha,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              data.subSektor,
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                                const SizedBox(width: 2),
                                Text(
                                  data.kecamatan,
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
