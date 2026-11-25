import 'package:flutter/material.dart';

import '../models/models.dart';
import 'widgets.dart';

const _urutanHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

/// Jadwal kuliah mahasiswa = kelas yang sudah masuk KRS, dikelompokkan per hari.
class JadwalScreen extends StatelessWidget {
  const JadwalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DataState(builder: (s) {
      final items = s.krs?.items ?? <JadwalItem>[];

      if (items.isEmpty) {
        return ListView(children: const [
          Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Belum ada kelas. Isi KRS terlebih dahulu di menu KRS.',
              textAlign: TextAlign.center,
            ),
          ),
        ]);
      }

      final perHari = <String, List<JadwalItem>>{};
      for (final j in items) {
        perHari.putIfAbsent(j.hari, () => []).add(j);
      }
      final hariList = perHari.keys.toList()
        ..sort((a, b) => _urutanHari.indexOf(a).compareTo(_urutanHari.indexOf(b)));

      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final hari in hariList) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
              child: Text(hari, style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final j in (perHari[hari]!..sort((a, b) => a.jamMulai.compareTo(b.jamMulai))))
              Card(
                child: ListTile(
                  title: Text(j.nama),
                  subtitle: Text('${j.waktu}  •  ${j.ruang}\n${j.dosen}'),
                  isThreeLine: true,
                  trailing: Text('${j.sks} SKS'),
                ),
              ),
          ],
        ],
      );
    });
  }
}
