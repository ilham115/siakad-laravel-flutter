import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/models.dart';
import '../models/presensi_models.dart';

/// State data akademik mahasiswa: kelas tersedia, KRS, nilai, dan presensi.
class SiakadProvider extends ChangeNotifier {
  final ApiClient api;
  SiakadProvider(this.api);

  List<JadwalItem> tersedia = [];
  KrsSummary? krs;
  NilaiSummary? nilai;
  List<PresensiItem> presensi = [];
  bool loading = false;
  String? error;

  Future<void> loadAll({bool silent = false}) async {
    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      final r = await Future.wait([
        api.get('/jadwal'),
        api.get('/krs'),
        api.get('/nilai'),
        api.get('/presensi'),
      ]);
      tersedia = (r[0] as List).map((e) => JadwalItem.fromJson(e)).toList();
      krs = KrsSummary.fromJson(r[1]);
      nilai = NilaiSummary.fromJson(r[2]);
      presensi = (r[3] as List).map((e) => PresensiItem.fromJson(e)).toList();
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    }
    loading = false;
    notifyListeners();
  }

  /// Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> ambil(int jadwalId) async {
    try {
      await api.post('/krs', {'jadwal_id': jadwalId});
      await loadAll(silent: true);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> batal(int krsId) async {
    try {
      await api.delete('/krs/$krsId');
      await loadAll(silent: true);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  /// Mengisi presensi dengan kode 6 angka dari dosen.
  Future<({bool ok, String pesan})> isiPresensi(String kode) async {
    try {
      final r = await api.post('/presensi', {'kode': kode});
      await loadAll(silent: true);
      return (ok: true, pesan: (r['message'] ?? 'Presensi berhasil.').toString());
    } on ApiException catch (e) {
      final pesan = e.statusCode == 429
          ? 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.'
          : e.message;
      return (ok: false, pesan: pesan);
    }
  }

  void clear() {
    tersedia = [];
    krs = null;
    nilai = null;
    presensi = [];
    error = null;
    notifyListeners();
  }
}
