import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/dosen_provider.dart';
import 'kelas_dosen_screen.dart';

/// Beranda dosen: daftar kelas yang diampu.
class DosenHome extends StatefulWidget {
  const DosenHome({super.key});

  @override
  State<DosenHome> createState() => _DosenHomeState();
}

class _DosenHomeState extends State<DosenHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DosenProvider>().loadKelas();
    });
  }

  Future<void> _logout() async {
    context.read<DosenProvider>().clear();
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final d = context.watch<DosenProvider>();
    final wide = MediaQuery.of(context).size.width >= 720;

    Widget body;
    if (!d.kelasLoaded && d.errorKelas == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (!d.kelasLoaded) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(d.errorKelas!),
            const SizedBox(height: 12),
            FilledButton(onPressed: d.loadKelas, child: const Text('Coba lagi')),
          ],
        ),
      );
    } else if (d.kelas.isEmpty) {
      body = ListView(children: const [
        Padding(
          padding: EdgeInsets.all(32),
          child: Text('Belum ada kelas yang Anda ampu.', textAlign: TextAlign.center),
        ),
      ]);
    } else {
      body = RefreshIndicator(
        onRefresh: d.loadKelas,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final k in d.kelas)
              Card(
                child: ListTile(
                  title: Text(k.nama),
                  subtitle: Text(
                      '${k.hari}, ${k.waktu}  •  ${k.ruang}\n${k.kode}  •  ${k.sks} SKS'),
                  isThreeLine: true,
                  trailing: Text('${k.jumlahMahasiswa} mhs'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => KelasDosenScreen(kelas: k)),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelas yang Diampu'),
        actions: [
          if (wide)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(user.label),
              ),
            ),
          IconButton(tooltip: 'Keluar', icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
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
