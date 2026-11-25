import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/dosen_models.dart';

/// State untuk fitur dosen: daftar kelas, nilai, dan presensi.
class DosenProvider extends ChangeNotifier {
  final ApiClient api;
  DosenProvider(this.api);

  // ----- Daftar kelas -----
  List<DosenKelas> kelas = [];
  bool kelasLoaded = false;
  bool loadingKelas = false;
  String? errorKelas;

  // ----- Nilai peserta satu kelas -----
  List<NilaiMahasiswa> daftar = [];
  bool loadingDaftar = false;
  String? errorDaftar;

  // ----- Pertemuan presensi satu kelas -----
  List<SesiPresensi> sesi = [];
  int jumlahMahasiswa = 0;
  bool loadingSesi = false;
  String? errorSesi;

  // ----- Kehadiran satu pertemuan -----
  List<HadirItem> hadir = [];
  bool loadingHadir = false;
  String? errorHadir;

  Future<void> loadKelas() async {
    loadingKelas = true;
    errorKelas = null;
    notifyListeners();
    try {
      final r = await api.get('/dosen/kelas') as List;
      kelas = r.map((e) => DosenKelas.fromJson(e)).toList();
      kelasLoaded = true;
    } on ApiException catch (e) {
      errorKelas = e.message;
    }
    loadingKelas = false;
    notifyListeners();
  }

  // ===== Nilai =====

  Future<void> loadMahasiswa(int jadwalId, {bool silent = false}) async {
    if (!silent) {
      loadingDaftar = true;
      errorDaftar = null;
      daftar = [];
      notifyListeners();
    }
    try {
      final r = await api.get('/dosen/kelas/$jadwalId/mahasiswa');
      daftar = (r['mahasiswa'] as List).map((e) => NilaiMahasiswa.fromJson(e)).toList();
      errorDaftar = null;
    } on ApiException catch (e) {
      errorDaftar = e.message;
    }
    loadingDaftar = false;
    notifyListeners();
  }

  /// Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> simpanNilai(int jadwalId, int krsId, double nilai) async {
    try {
      await api.put('/dosen/nilai', {'krs_id': krsId, 'nilai_angka': nilai});
      await loadMahasiswa(jadwalId, silent: true);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  // ===== Presensi =====

  Future<void> loadSesi(int jadwalId, {bool silent = false}) async {
    if (!silent) {
      loadingSesi = true;
      errorSesi = null;
      sesi = [];
      notifyListeners();
    }
    try {
      final r = await api.get('/dosen/kelas/$jadwalId/presensi');
      jumlahMahasiswa = r['jumlah_mahasiswa'];
      sesi = (r['sesi'] as List).map((e) => SesiPresensi.fromJson(e)).toList();
      errorSesi = null;
    } on ApiException catch (e) {
      errorSesi = e.message;
    }
    loadingSesi = false;
    notifyListeners();
  }

  /// Membuka pertemuan baru. Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> bukaSesi(int jadwalId, int durasiMenit) async {
    try {
      await api.post('/dosen/kelas/$jadwalId/presensi', {'durasi_menit': durasiMenit});
      await loadSesi(jadwalId, silent: true);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> tutupSesi(int jadwalId, int sesiId) async {
    try {
      await api.post('/dosen/presensi/$sesiId/tutup');
      await loadSesi(jadwalId, silent: true);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> loadHadir(int sesiId) async {
    loadingHadir = true;
    errorHadir = null;
    hadir = [];
    notifyListeners();
    try {
      final r = await api.get('/dosen/presensi/$sesiId');
      hadir = (r['peserta'] as List).map((e) => HadirItem.fromJson(e)).toList();
    } on ApiException catch (e) {
      errorHadir = e.message;
    }
    loadingHadir = false;
    notifyListeners();
  }

  void clear() {
    kelas = [];
    kelasLoaded = false;
    errorKelas = null;
    daftar = [];
    sesi = [];
    hadir = [];
    notifyListeners();
  }
}
