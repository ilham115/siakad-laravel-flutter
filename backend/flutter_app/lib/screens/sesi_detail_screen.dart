import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dosen_models.dart';
import '../providers/dosen_provider.dart';

/// Daftar kehadiran mahasiswa pada satu pertemuan.
class SesiDetailScreen extends StatefulWidget {
  final SesiPresensi sesi;
  const SesiDetailScreen({super.key, required this.sesi});

  @override
  State<SesiDetailScreen> createState() => _SesiDetailScreenState();
}

class _SesiDetailScreenState extends State<SesiDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DosenProvider>().loadHadir(widget.sesi.sesiId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DosenProvider>();
    final jumlahHadir = d.hadir.where((h) => h.hadir).length;

    Widget body;
    if (d.loadingHadir && d.hadir.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (d.errorHadir != null && d.hadir.isEmpty) {
      body = Center(child: Text(d.errorHadir!));
    } else if (d.hadir.isEmpty) {
      body = const Center(child: Text('Belum ada mahasiswa di kelas ini.'));
    } else {
      body = ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Text('Hadir $jumlahHadir dari ${d.hadir.length} mahasiswa',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          for (final h in d.hadir)
            Card(
              child: ListTile(
                leading: Icon(
                  h.hadir ? Icons.check_circle : Icons.cancel_outlined,
                  color: h.hadir ? Colors.green : Colors.grey,
                ),
                title: Text(h.nama),
                subtitle: Text(h.nim),
                trailing: Text(h.hadir ? 'Hadir' : 'Belum'),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Pertemuan ke-${widget.sesi.pertemuanKe}')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: body,
        ),
      ),
    );
  }
}
