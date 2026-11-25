import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/siakad_provider.dart';
import 'jadwal_screen.dart';
import 'krs_screen.dart';
import 'nilai_screen.dart';
import 'presensi_screen.dart';

/// Kerangka aplikasi: BottomNavigationBar di layar sempit (HP),
/// NavigationRail di layar lebar (tablet/web).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [JadwalScreen(), KrsScreen(), PresensiScreen(), NilaiScreen()];
  static const _titles = ['Jadwal Kuliah', 'Pengisian KRS', 'Presensi', 'Nilai & IPK'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SiakadProvider>().loadAll();
    });
  }

  Future<void> _logout() async {
    context.read<SiakadProvider>().clear();
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final wide = MediaQuery.of(context).size.width >= 720;

    const destinations = [
      (Icons.calendar_month_outlined, Icons.calendar_month, 'Jadwal'),
      (Icons.edit_note_outlined, Icons.edit_note, 'KRS'),
      (Icons.how_to_reg_outlined, Icons.how_to_reg, 'Presensi'),
      (Icons.grade_outlined, Icons.grade, 'Nilai'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (wide)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(user.label),
              ),
            ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _index,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.$1),
                    selectedIcon: Icon(d.$2),
                    label: Text(d.$3),
                  ),
              ],
            ),
          Expanded(
            // Batasi lebar konten agar nyaman dibaca di monitor besar.
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: _pages[_index],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.$1),
                    selectedIcon: Icon(d.$2),
                    label: d.$3,
                  ),
              ],
            ),
    );
  }
}
