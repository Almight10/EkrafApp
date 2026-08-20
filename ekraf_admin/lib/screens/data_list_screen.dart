import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/ekraf_data.dart';
import '../providers/ekraf_provider.dart';
import '../services/export_service.dart';
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
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Laporan',
            onPressed: () => _showExportBottomSheet(context),
          ),
          const SizedBox(width: 8),
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
      child: Row(
        children: [
          Expanded(
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
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: (provider.filterSubSektor != null)
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (provider.filterSubSektor != null)
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
            ),
            child: PopupMenuButton<String>(
              initialValue: provider.filterSubSektor ?? '',
              constraints: const BoxConstraints(maxHeight: 350, minWidth: 200),
              onSelected: (val) {
                provider.setFilterSubSektor(val.isEmpty ? null : val);
              },
              icon: Icon(
                Icons.filter_list_rounded,
                color: (provider.filterSubSektor != null) ? AppColors.primary : AppColors.textSecondary,
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
                        fontWeight: provider.filterSubSektor == null ? FontWeight.bold : FontWeight.normal,
                        color: provider.filterSubSektor == null ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...subSektorEkraf.map((s) => PopupMenuItem<String>(
                    value: s,
                    child: Text(
                      s,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: provider.filterSubSektor == s ? FontWeight.bold : FontWeight.normal,
                        color: provider.filterSubSektor == s ? AppColors.primary : AppColors.textPrimary,
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

  void _showExportBottomSheet(BuildContext context) {
    final provider = context.read<EkrafProvider>();
    final filteredCount = provider.data.length;
    final totalCount = provider.allData.length;

    String selectedFormat = 'excel'; // 'excel' | 'csv'
    String selectedScope = 'filtered'; // 'filtered' | 'all'
    bool isExporting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Pull handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.download_for_offline_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Export Laporan Data',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Format .xlsx spreadsheet atau .csv teks',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section 1: Cakupan Data
                  Text(
                    'PILIH CAKUPAN DATA',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Filtered Data Card
                      Expanded(
                        child: _buildSelectableCard(
                          title: 'Data Terfilter',
                          subtitle: '$filteredCount data',
                          icon: Icons.filter_alt_rounded,
                          isSelected: selectedScope == 'filtered',
                          onTap: () {
                            setModalState(() {
                              selectedScope = 'filtered';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // All Data Card
                      Expanded(
                        child: _buildSelectableCard(
                          title: 'Semua Data',
                          subtitle: '$totalCount data',
                          icon: Icons.all_inbox_rounded,
                          isSelected: selectedScope == 'all',
                          onTap: () {
                            setModalState(() {
                              selectedScope = 'all';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section 2: Format File
                  Text(
                    'PILIH FORMAT FILE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Excel Card
                      Expanded(
                        child: _buildSelectableCard(
                          title: 'Excel Spreadsheet',
                          subtitle: '.xlsx',
                          icon: Icons.table_view_rounded,
                          iconColor: Colors.green.shade700,
                          isSelected: selectedFormat == 'excel',
                          onTap: () {
                            setModalState(() {
                              selectedFormat = 'excel';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // CSV Card
                      Expanded(
                        child: _buildSelectableCard(
                          title: 'CSV Plain Text',
                          subtitle: '.csv',
                          icon: Icons.article_rounded,
                          iconColor: Colors.blue.shade700,
                          isSelected: selectedFormat == 'csv',
                          onTap: () {
                            setModalState(() {
                              selectedFormat = 'csv';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Export Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isExporting
                          ? null
                          : () async {
                              setModalState(() {
                                isExporting = true;
                              });

                              try {
                                final dataToExport = selectedScope == 'filtered'
                                    ? provider.data
                                    : provider.allData;

                                if (dataToExport.isEmpty) {
                                  throw Exception('Tidak ada data untuk diexport');
                                }

                                final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                                final filename = 'laporan_ekraf_$timestamp';

                                final bool isDownloadedDirectly;
                                if (selectedFormat == 'excel') {
                                  isDownloadedDirectly = await ExportService.exportToExcel(dataToExport, filename);
                                } else {
                                  isDownloadedDirectly = await ExportService.exportToCsv(dataToExport, filename);
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  final successMessage = isDownloadedDirectly
                                      ? 'Laporan berhasil diunduh ke folder Download HP Anda!'
                                      : 'Laporan berhasil diexport dalam format ${selectedFormat.toUpperCase()}!';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(successMessage)),
                                        ],
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setModalState(() {
                                  isExporting = false;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.error_rounded, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text('Gagal export: ${e.toString()}')),
                                        ],
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                      child: isExporting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('Export Sekarang'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Widget _buildSelectableCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? AppShadows.card : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? (iconColor ?? AppColors.primary) : AppColors.textSecondary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
                  backgroundImage: (data.fotoUrl != null && data.fotoUrl!.isNotEmpty)
                      ? NetworkImage(data.fotoUrl!)
                      : null,
                  child: (data.fotoUrl != null && data.fotoUrl!.isNotEmpty)
                      ? null
                      : Text(
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
