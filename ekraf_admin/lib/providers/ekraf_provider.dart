import 'package:flutter/foundation.dart';
import '../models/ekraf_data.dart';
import '../services/mock_service.dart';

class EkrafProvider extends ChangeNotifier {
  final MockDataService _service = MockDataService();

  List<EkrafData> _allData = [];
  List<EkrafData> _filteredData = [];
  bool _isLoading = false;
  String _searchQuery = '';
  VerificationStatus? _filterStatus;
  String? _filterSubSektor;

  List<EkrafData> get data => _filteredData;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  VerificationStatus? get filterStatus => _filterStatus;
  String? get filterSubSektor => _filterSubSektor;

  int get totalData => _service.totalData;
  int get totalVerified => _service.totalVerified;
  int get totalPending => _service.totalPending;
  int get totalRejected => _service.totalRejected;

  Map<String, int> get statsBySubSektor => _service.getStatsBySubSektor();
  Map<VerificationStatus, int> get statsByStatus => _service.getStatsByStatus();

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    _allData = await _service.getAllData();
    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  void _applyFilters() {
    _filteredData = _allData.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.namaLengkap.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.namaUsaha.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.nik.contains(_searchQuery);

      final matchesStatus = _filterStatus == null || item.status == _filterStatus;
      final matchesSubSektor = _filterSubSektor == null || item.subSektor == _filterSubSektor;

      return matchesSearch && matchesStatus && matchesSubSektor;
    }).toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilterStatus(VerificationStatus? status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void setFilterSubSektor(String? subSektor) {
    _filterSubSektor = subSektor;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    _filterSubSektor = null;
    _applyFilters();
    notifyListeners();
  }

  Future<void> addEntry(EkrafData data) async {
    await _service.addData(data);
    await loadData();
  }

  Future<void> updateStatus(
    String id,
    VerificationStatus status, {
    String? catatan,
  }) async {
    await _service.updateStatus(id, status, catatan);
    await loadData();
  }

  Future<void> deleteEntry(String id) async {
    await _service.deleteData(id);
    await loadData();
  }
}
