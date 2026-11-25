/// Satu kelas yang diampu dosen.
class DosenKelas {
  final int jadwalId;
  final String kode;
  final String nama;
  final int sks;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String ruang;
  final int jumlahMahasiswa;

  DosenKelas({
    required this.jadwalId,
    required this.kode,
    required this.nama,
    required this.sks,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruang,
    required this.jumlahMahasiswa,
  });

  factory DosenKelas.fromJson(Map<String, dynamic> j) => DosenKelas(
        jadwalId: j['jadwal_id'],
        kode: j['kode'],
        nama: j['nama'],
        sks: j['sks'],
        hari: j['hari'],
        jamMulai: j['jam_mulai'],
        jamSelesai: j['jam_selesai'],
        ruang: j['ruang'],
        jumlahMahasiswa: j['jumlah_mahasiswa'],
      );

  String get waktu => '$jamMulai - $jamSelesai';
}

/// Satu peserta kelas beserta nilainya (null = belum dinilai).
class NilaiMahasiswa {
  final int krsId;
  final String nim;
  final String nama;
  final double? nilaiAngka;
  final String? huruf;

  NilaiMahasiswa({
    required this.krsId,
    required this.nim,
    required this.nama,
    this.nilaiAngka,
    this.huruf,
  });

  factory NilaiMahasiswa.fromJson(Map<String, dynamic> j) => NilaiMahasiswa(
        krsId: j['krs_id'],
        nim: j['nim'],
        nama: j['nama'],
        nilaiAngka: j['nilai_angka'] == null ? null : (j['nilai_angka'] as num).toDouble(),
        huruf: j['nilai_huruf'],
      );
}

/// Satu pertemuan yang dibuka dosen untuk presensi.
class SesiPresensi {
  final int sesiId;
  final int pertemuanKe;
  final String kode;
  final bool aktif;
  final int sisaDetik;
  final int jumlahHadir;

  SesiPresensi({
    required this.sesiId,
    required this.pertemuanKe,
    required this.kode,
    required this.aktif,
    required this.sisaDetik,
    required this.jumlahHadir,
  });

  factory SesiPresensi.fromJson(Map<String, dynamic> j) => SesiPresensi(
        sesiId: j['sesi_id'],
        pertemuanKe: j['pertemuan_ke'],
        kode: j['kode'],
        aktif: j['aktif'],
        sisaDetik: j['sisa_detik'],
        jumlahHadir: j['jumlah_hadir'],
      );

  /// Sisa waktu dibulatkan ke atas dalam menit.
  int get sisaMenit => (sisaDetik / 60).ceil();
}

/// Status kehadiran satu mahasiswa pada satu pertemuan.
class HadirItem {
  final String nim;
  final String nama;
  final bool hadir;

  HadirItem({required this.nim, required this.nama, required this.hadir});

  factory HadirItem.fromJson(Map<String, dynamic> j) => HadirItem(
        nim: j['nim'],
        nama: j['nama'],
        hadir: j['hadir'],
      );
}
