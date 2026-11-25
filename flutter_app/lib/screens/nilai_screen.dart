import 'package:flutter/material.dart';

import 'widgets.dart';

class NilaiScreen extends StatelessWidget {
  const NilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DataState(builder: (s) {
      final nilai = s.nilai!;

      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat(context, 'IPK', nilai.ipk.toStringAsFixed(2)),
                  _stat(context, 'Total SKS', '${nilai.totalSks}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (nilai.items.isEmpty)
            const Padding(padding: EdgeInsets.all(24), child: Text('Belum ada nilai.')),
          for (final n in nilai.items)
            Card(
              child: ListTile(
                title: Text(n.nama),
                subtitle: Text('${n.kode}  •  ${n.sks} SKS  •  ${n.tahunAjaran}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(n.huruf, style: Theme.of(context).textTheme.titleLarge),
                    Text(n.nilaiAngka.toStringAsFixed(0)),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _stat(BuildContext context, String label, String value) => Column(
        children: [
          Text(label),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
        ],
      );
}
