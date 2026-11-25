import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/siakad_provider.dart';
import 'widgets.dart';

/// Presensi mahasiswa: isi kode 6 angka dari dosen + rekap kehadiran per kelas.
class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  final _kode = TextEditingController();
  bool _mengirim = false;

  @override
  void dispose() {
    _kode.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    final kode = _kode.text.trim();
    if (kode.length != 6) {
      showSnack(context, 'Masukkan kode presensi 6 angka.');
      return;
    }
    setState(() => _mengirim = true);
    final hasil = await context.read<SiakadProvider>().isiPresensi(kode);
    if (!mounted) return;
    setState(() => _mengirim = false);
    if (hasil.ok) _kode.clear();
    showSnack(context, hasil.pesan);
  }

  @override
  Widget build(BuildContext context) {
    return DataState(builder: (s) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Masukkan kode presensi dari dosen'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _kode,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '6 angka',
                            counterText: '',
                          ),
                          onSubmitted: (_) => _kirim(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _mengirim ? null : _kirim,
                        child: const Text('Kirim'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
            child: Text('Kehadiran per mata kuliah',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          if (s.presensi.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada kelas di KRS. Isi KRS terlebih dahulu.',
                textAlign: TextAlign.center,
              ),
            ),
          for (final p in s.presensi)
            Card(
              child: ListTile(
                title: Text(p.nama),
                subtitle: Text(
                    '${p.hari}, ${p.waktu}\nHadir ${p.hadir} dari ${p.totalPertemuan} pertemuan'),
                isThreeLine: true,
                trailing: p.sesiAktif ? const Chip(label: Text('Dibuka')) : null,
              ),
            ),
        ],
      );
    });
  }
}
