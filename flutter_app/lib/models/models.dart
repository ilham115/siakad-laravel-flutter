/// Pengguna yang login: mahasiswa atau dosen (dibedakan oleh [role]).
/// Field khusus mahasiswa (nim, prodi, ...) bernilai null untuk dosen.
class AppUser {
  final String nama;
  final String role; // 'mahasiswa' | 'dosen'
  final String? email;
  final String? nim;
  final String? prodi;
  final int? angkatan;
  final int? semesterAktif;

  AppUser({
    required this.nama,
    required this.role,
    this.email,
    this.nim,
    this.prodi,
    this.angkatan,
    this.semesterAktif,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        nama: j['nama'],
        role: j['role'],
        email: j['email'],
        nim: j['nim'],
        prodi: j['prodi'],
        angkatan: j['angkatan'],
        semesterAktif: j['semester_aktif'],
      );

  bool get isDosen => role == 'dosen';

  /// Teks singkat untuk AppBar, mis. "Mahasiswa Demo (12230001)".
  String get label => nim != null ? '$nama ($nim)' : nama;
}

/// Satu kelas/jadwal. [krsId] terisi bila kelas ini sudah ada di KRS mahasiswa.
class JadwalItem {
  final int jadwalId;
  final int? krsId;
  final String kode;
  final String nama;
  final int sks;
  final String dosen;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String ruang;

  JadwalItem({
    required this.jadwalId,
    this.krsId,
    required this.kode,
    required this.nama,
    required this.sks,
    required this.dosen,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruang,
  });

  factory JadwalItem.fromJson(Map<String, dynamic> j) => JadwalItem(
        jadwalId: j['jadwal_id'],
        krsId: j['krs_id'],
        kode: j['kode'],
        nama: j['nama'],
        sks: j['sks'],
        dosen: j['dosen'],
        hari: j['hari'],
        jamMulai: j['jam_mulai'],
        jamSelesai: j['jam_selesai'],
        ruang: j['ruang'],
      );

  String get waktu => '$jamMulai - $jamSelesai';
}

class KrsSummary {
  final String tahunAjaran;
  final int totalSks;
  final int maksSks;
  final List<JadwalItem> items;

  KrsSummary({
    required this.tahunAjaran,
    required this.totalSks,
    required this.maksSks,
    required this.items,
  });

  factory KrsSummary.fromJson(Map<String, dynamic> j) => KrsSummary(
        tahunAjaran: j['tahun_ajaran'],
        totalSks: j['total_sks'],
        maksSks: j['maks_sks'],
        items: (j['items'] as List).map((e) => JadwalItem.fromJson(e)).toList(),
      );
}

class NilaiItem {
  final String kode;
  final String nama;
  final int sks;
  final String tahunAjaran;
  final double nilaiAngka;
  final String huruf;
  final double bobot;

  NilaiItem({
    required this.kode,
    required this.nama,
    required this.sks,
    required this.tahunAjaran,
    required this.nilaiAngka,
    required this.huruf,
    required this.bobot,
  });

  factory NilaiItem.fromJson(Map<String, dynamic> j) => NilaiItem(
        kode: j['kode'],
        nama: j['nama'],
        sks: j['sks'],
        tahunAjaran: j['tahun_ajaran'],
        nilaiAngka: (j['nilai_angka'] as num).toDouble(),
        huruf: j['nilai_huruf'],
        bobot: (j['bobot'] as num).toDouble(),
      );
}

class NilaiSummary {
  final double ipk;
  final int totalSks;
  final List<NilaiItem> items;

  NilaiSummary({required this.ipk, required this.totalSks, required this.items});

  factory NilaiSummary.fromJson(Map<String, dynamic> j) => NilaiSummary(
        ipk: (j['ipk'] as num).toDouble(),
        totalSks: j['total_sks'],
        items: (j['items'] as List).map((e) => NilaiItem.fromJson(e)).toList(),
      );
}
