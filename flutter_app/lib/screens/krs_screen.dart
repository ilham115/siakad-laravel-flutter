import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/siakad_provider.dart';
import 'widgets.dart';

class KrsScreen extends StatelessWidget {
  const KrsScreen({super.key});

  Future<void> _aksi(BuildContext context, Future<String?> Function() job, String ok) async {
    final err = await job();
    if (context.mounted) showSnack(context, err ?? ok);
  }

  @override
  Widget build(BuildContext context) {
    return DataState(builder: (s) {
      final krs = s.krs!;
      final diambilIds = krs.items.map((e) => e.jadwalId).toSet();
      final tersedia = s.tersedia.where((j) => !diambilIds.contains(j.jadwalId)).toList();
      final penuh = krs.totalSks >= krs.maksSks;

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
                  Text('Periode ${krs.tahunAjaran}'),
                  const SizedBox(height: 4),
                  Text('${krs.totalSks} / ${krs.maksSks} SKS',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: krs.totalSks / krs.maksSks),
                ],
              ),
            ),
          ),
          _judul(context, 'Kelas diambil (${krs.items.length})'),
          if (krs.items.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('Belum ada.')),
          for (final j in krs.items)
            Card(
              child: ListTile(
                title: Text(j.nama),
                subtitle: Text('${j.hari}, ${j.waktu}  •  ${j.sks} SKS'),
                trailing: IconButton(
                  tooltip: 'Batalkan',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _aksi(
                    context,
                    () => context.read<SiakadProvider>().batal(j.krsId!),
                    'Kelas dibatalkan.',
                  ),
                ),
              ),
            ),
          _judul(context, 'Kelas tersedia (${tersedia.length})'),
          for (final j in tersedia) _kelasTersedia(context, j, penuh),
        ],
      );
    });
  }

  Widget _judul(BuildContext context, String teks) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
        child: Text(teks, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _kelasTersedia(BuildContext context, JadwalItem j, bool penuh) => Card(
        child: ListTile(
          title: Text(j.nama),
          subtitle: Text('${j.hari}, ${j.waktu}  •  ${j.sks} SKS\n${j.dosen}'),
          isThreeLine: true,
          trailing: FilledButton.tonal(
            onPressed: penuh
                ? null
                : () => _aksi(
                      context,
                      () => context.read<SiakadProvider>().ambil(j.jadwalId),
                      'Kelas ditambahkan ke KRS.',
                    ),
            child: const Text('Ambil'),
          ),
        ),
      );
}
