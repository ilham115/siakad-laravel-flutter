import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dosen_models.dart';
import '../providers/dosen_provider.dart';
import 'sesi_detail_screen.dart';
import 'widgets.dart';

/// Tab Presensi (dosen): buka pertemuan, bagikan kode angka, tutup, lihat riwayat.
class PresensiTab extends StatefulWidget {
  final DosenKelas kelas;
  const PresensiTab({super.key, required this.kelas});

  @override
  State<PresensiTab> createState() => _PresensiTabState();
}

class _PresensiTabState extends State<PresensiTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DosenProvider>().loadSesi(widget.kelas.jadwalId);
    });
  }

  Future<void> _buka() async {
    final ctrl = TextEditingController(text: '15');
    String? pesanError;

    final durasi = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Buka sesi presensi'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Berlaku selama (menit)',
              border: const OutlineInputBorder(),
              errorText: pesanError,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final v = int.tryParse(ctrl.text.trim());
                if (v == null || v < 1 || v > 120) {
                  setState(() => pesanError = 'Isi angka antara 1 dan 120');
                  return;
                }
                Navigator.pop(ctx, v);
              },
              child: const Text('Buka'),
            ),
          ],
        ),
      ),
    );

    if (durasi == null || !mounted) return;
    final err = await context.read<DosenProvider>().bukaSesi(widget.kelas.jadwalId, durasi);
    if (mounted) showSnack(context, err ?? 'Sesi presensi dibuka. Bagikan kodenya ke mahasiswa.');
  }

  Future<void> _tutup(SesiPresensi s) async {
    final err = await context.read<DosenProvider>().tutupSesi(widget.kelas.jadwalId, s.sesiId);
    if (mounted) showSnack(context, err ?? 'Sesi presensi ditutup.');
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DosenProvider>();
    final aktif = d.sesi.where((s) => s.aktif).firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (aktif != null)
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Pertemuan ke-${aktif.pertemuanKe}  •  sisa ${aktif.sisaMenit} menit'),
                  const SizedBox(height: 8),
                  SelectableText(
                    aktif.kode,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          letterSpacing: 6,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('Hadir ${aktif.jumlahHadir} dari ${d.jumlahMahasiswa} mahasiswa'),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => _tutup(aktif),
                    child: const Text('Tutup sesi'),
                  ),
                ],
              ),
            ),
          )
        else
          FilledButton.icon(
            onPressed: d.loadingSesi ? null : _buka,
            icon: const Icon(Icons.how_to_reg),
            label: const Text('Buka sesi presensi'),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => d.loadSesi(widget.kelas.jadwalId, silent: true),
            icon: const Icon(Icons.refresh),
            label: const Text('Muat ulang'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: Text('Riwayat pertemuan (${d.sesi.length})',
              style: Theme.of(context).textTheme.titleMedium),
        ),
        if (d.loadingSesi && d.sesi.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (d.errorSesi != null && d.sesi.isEmpty)
          Padding(padding: const EdgeInsets.all(24), child: Text(d.errorSesi!))
        else if (d.sesi.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Belum ada pertemuan. Buka sesi presensi untuk memulai.'),
          ),
        for (final s in d.sesi)
          Card(
            child: ListTile(
              title: Text('Pertemuan ke-${s.pertemuanKe}'),
              subtitle: Text('Kode ${s.kode}  •  Hadir ${s.jumlahHadir}/${d.jumlahMahasiswa}'),
              trailing: Text(s.aktif ? 'Aktif' : 'Ditutup'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SesiDetailScreen(sesi: s)),
              ),
            ),
          ),
      ],
    );
  }
}
