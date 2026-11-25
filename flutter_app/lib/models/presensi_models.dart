/// Rekap kehadiran mahasiswa pada satu kelas.
class PresensiItem {
  final int jadwalId;
  final String kode;
  final String nama;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final int totalPertemuan;
  final int hadir;

  /// true = dosen sedang membuka presensi dan mahasiswa ini belum mengisinya.
  final bool sesiAktif;

  PresensiItem({
    required this.jadwalId,
    required this.kode,
    required this.nama,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
    required this.totalPertemuan,
    required this.hadir,
    required this.sesiAktif,
  });

  factory PresensiItem.fromJson(Map<String, dynamic> j) => PresensiItem(
        jadwalId: j['jadwal_id'],
        kode: j['kode'],
        nama: j['nama'],
        hari: j['hari'],
        jamMulai: j['jam_mulai'],
        jamSelesai: j['jam_selesai'],
        totalPertemuan: j['total_pertemuan'],
        hadir: j['hadir'],
        sesiAktif: j['sesi_aktif'],
      );

  String get waktu => '$jamMulai - $jamSelesai';
}
