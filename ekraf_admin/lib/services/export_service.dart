import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/ekraf_data.dart';

class ExportService {
  static const _mediaScannerChannel =
      MethodChannel('com.ekraf.ekraf_admin/media_scanner');

  static final List<String> _headers = [
    'ID Usaha',
    'Nama Pelaku',
    'NIK',
    'Email',
    'No. HP',
    'Alamat Domisili',
    'Kecamatan Domisili',
    'Kelurahan Domisili',
    'Nama Usaha',
    'Sub Sektor',
    'Alamat Tempat Usaha',
    'Kecamatan Usaha',
    'Kelurahan Usaha',
    'Link Maps Usaha',
    'Deskripsi Usaha',
    'Tahun Berdiri',
    'Jumlah Karyawan',
    'Omzet Per Bulan',
    'HAKI',
    'Nomor HAKI',
    'Tahun HAKI',
    'Produk Unggulan',
    'Harga Produk',
    'Link Marketplace',
    'Status Verifikasi',
    'Tanggal Pengajuan',
    'Tanggal Verifikasi',
    'Catatan Admin',
  ];

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static List<List<dynamic>> _generateDataRows(List<EkrafData> dataList) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    List<List<dynamic>> rows = [_headers];

    for (var item in dataList) {
      final hakiLabel = item.hakiTypes.map((e) {
        switch (e) {
          case HakiType.merek:
            return 'Merek';
          case HakiType.hakCipta:
            return 'Hak Cipta';
          case HakiType.paten:
            return 'Paten';
          case HakiType.desainIndustri:
            return 'Desain Industri';
          case HakiType.belumAda:
            return 'Belum Ada';
        }
      }).join(', ');

      rows.add([
        item.id,
        item.namaLengkap,
        item.nik,
        item.email,
        item.noHp,
        item.alamat,
        item.kecamatan,
        item.kelurahan,
        item.namaUsaha,
        item.subSektor,
        item.displayAlamatUsaha,
        item.displayKecamatanUsaha,
        item.displayKelurahanUsaha,
        item.mapsUrl ?? '',
        item.deskripsiUsaha,
        item.tahunBerdiri,
        item.jumlahKaryawan,
        item.omzetPerBulan,
        hakiLabel,
        item.nomorHaki ?? '',
        item.tahunHaki ?? '',
        item.namaProdukUnggulan,
        item.hargaProduk,
        item.linkMarketplace ?? '',
        item.statusLabel,
        dateFormat.format(item.createdAt),
        item.verifiedAt != null ? dateFormat.format(item.verifiedAt!) : '',
        item.catatanAdmin ?? '',
      ]);
    }
    return rows;
  }

  // ── Private helpers ──────────────────────────────────────────────────────────

  /// Save via MediaStore (Android 10+, no permission needed, saves directly to Downloads)
  static Future<bool> _saveViaMediaStore(
      String fileName, String mimeType, List<int> bytes) async {
    try {
      final result = await _mediaScannerChannel.invokeMethod<String>(
        'saveToDownloads',
        {
          'name': fileName,
          'mimeType': mimeType,
          'bytes': bytes,
        },
      );
      return result != null;
    } catch (_) {
      return false;
    }
  }

  /// Share via Share Sheet (ultimate fallback for all Android versions)
  static Future<void> _shareFile(
      String tmpPath, String mimeType, String subject) async {
    await Share.shareXFiles(
      [XFile(tmpPath, mimeType: mimeType)],
      subject: subject,
    );
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Exports to CSV.
  /// 1st: Shows native "Pilih lokasi" SAF dialog (exactly like Chrome download dialog)
  /// 2nd fallback: Saves directly to Downloads via MediaStore (no dialog)
  /// 3rd fallback: Share Sheet
  /// Returns `true` if saved to device storage, `false` if via Share Sheet.
  static Future<bool> exportToCsv(
      List<EkrafData> dataList, String filename) async {
    final rows = _generateDataRows(dataList);
    final csvData = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csvData);

    // ── Approach 1: Native SAF "Save As" dialog (like Chrome download dialog) ──
    try {
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Pilih lokasi untuk menyimpan',
        fileName: '$filename.csv',
        bytes: bytes,
      );
      if (savedPath != null) return true;
      // User cancelled the dialog — fall through to MediaStore silent save
    } catch (_) {
      // SAF not available — fall through to MediaStore
    }

    // ── Approach 2: Silent save to Downloads via MediaStore (Android 10+) ──
    if (Platform.isAndroid) {
      final saved = await _saveViaMediaStore(
          '$filename.csv', 'text/csv', bytes);
      if (saved) return true;
    }

    // ── Approach 3: Share Sheet (ultimate fallback) ──
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename.csv');
    await file.writeAsBytes(bytes);
    await _shareFile(file.path, 'text/csv', 'Laporan Data Usaha Ekraf (CSV)');
    return false;
  }

  /// Exports to Excel.
  /// 1st: Shows native "Pilih lokasi" SAF dialog (exactly like Chrome download dialog)
  /// 2nd fallback: Saves directly to Downloads via MediaStore (no dialog)
  /// 3rd fallback: Share Sheet
  /// Returns `true` if saved to device storage, `false` if via Share Sheet.
  static Future<bool> exportToExcel(
      List<EkrafData> dataList, String filename) async {
    var excelFile = Excel.createExcel();

    const sheetName = 'Data Usaha Ekraf';
    final defaultSheetName = excelFile.sheets.keys.first;
    excelFile.rename(defaultSheetName, sheetName);
    final sheet = excelFile[sheetName];

    final rows = _generateDataRows(dataList);
    for (var row in rows) {
      sheet.appendRow(row.map((e) => TextCellValue(e.toString())).toList());
    }

    // Header styling (Deep Blue + white text)
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#004787'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    for (int col = 0; col < _headers.length; col++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.cellStyle = headerStyle;
    }

    final fileBytes = excelFile.save();
    if (fileBytes == null) throw Exception('Gagal membuat file Excel');
    final bytes = Uint8List.fromList(fileBytes);
    const mimeType =
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

    // ── Approach 1: Native SAF "Save As" dialog (like Chrome download dialog) ──
    try {
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Pilih lokasi untuk menyimpan',
        fileName: '$filename.xlsx',
        bytes: bytes,
      );
      if (savedPath != null) return true;
    } catch (_) {
      // SAF not available — fall through to MediaStore
    }

    // ── Approach 2: Silent save to Downloads via MediaStore (Android 10+) ──
    if (Platform.isAndroid) {
      final saved = await _saveViaMediaStore(
          '$filename.xlsx', mimeType, bytes);
      if (saved) return true;
    }

    // ── Approach 3: Share Sheet (ultimate fallback) ──
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename.xlsx');
    await file.writeAsBytes(bytes);
    await _shareFile(file.path, mimeType, 'Laporan Data Usaha Ekraf (Excel)');
    return false;
  }
}
