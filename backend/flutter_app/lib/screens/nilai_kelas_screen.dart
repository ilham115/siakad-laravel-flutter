import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dosen_models.dart';
import '../providers/dosen_provider.dart';
import 'widgets.dart';

/// Tab Nilai: daftar peserta satu kelas; ketuk peserta untuk mengisi/mengubah nilai.
class NilaiKelasTab extends StatefulWidget {
  final DosenKelas kelas;
  const NilaiKelasTab({super.key, required this.kelas});

  @override
  State<NilaiKelasTab> createState() => _NilaiKelasTabState();
}

class _NilaiKelasTabState extends State<NilaiKelasTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DosenProvider>().loadMahasiswa(widget.kelas.jadwalId);
    });
  }

  Future<void> _input(NilaiMahasiswa m) async {
    final ctrl = TextEditingController(text: m.nilaiAngka?.toStringAsFixed(0) ?? '');
    String? pesanError;

    final nilai = await showDialog<double>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Nilai ${m.nama}'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Nilai angka (0-100)',
              border: const OutlineInputBorder(),
              errorText: pesanError,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text.trim().replaceAll(',', '.'));
                if (v == null || v < 0 || v > 100) {
                  setState(() => pesanError = 'Isi angka antara 0 dan 100');
                  return;
                }
                Navigator.pop(ctx, v);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (nilai == null || !mounted) return;
    final err = await context
        .read<DosenProvider>()
        .simpanNilai(widget.kelas.jadwalId, m.krsId, nilai);
    if (mounted) showSnack(context, err ?? 'Nilai disimpan.');
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DosenProvider>();

    if (d.loadingDaftar && d.daftar.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (d.errorDaftar != null && d.daftar.isEmpty) {
      return Center(child: Text(d.errorDaftar!));
    }
    if (d.daftar.isEmpty) {
      return const Center(child: Text('Belum ada mahasiswa di kelas ini.'));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final m in d.daftar)
          Card(
            child: ListTile(
              title: Text(m.nama),
              subtitle: Text(m.nim),
              trailing: m.nilaiAngka == null
                  ? const Text('Belum dinilai')
                  : Text('${m.huruf} (${m.nilaiAngka!.toStringAsFixed(0)})',
                      style: Theme.of(context).textTheme.titleMedium),
              onTap: () => _input(m),
            ),
          ),
      ],
    );
  }
}
