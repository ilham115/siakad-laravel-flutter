import 'package:flutter/material.dart';

import '../models/dosen_models.dart';
import 'nilai_kelas_screen.dart';
import 'presensi_tab.dart';

/// Halaman satu kelas untuk dosen, dengan dua tab: Presensi dan Nilai.
class KelasDosenScreen extends StatelessWidget {
  final DosenKelas kelas;
  const KelasDosenScreen({super.key, required this.kelas});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(kelas.nama),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Presensi'),
              Tab(text: 'Nilai'),
            ],
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: TabBarView(
              children: [
                PresensiTab(kelas: kelas),
                NilaiKelasTab(kelas: kelas),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
