import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/siakad_provider.dart';

/// Pembungkus umum: spinner, pesan error + tombol coba lagi, dan pull-to-refresh.
class DataState extends StatelessWidget {
  final Widget Function(SiakadProvider s) builder;
  const DataState({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SiakadProvider>();

    // Data belum pernah dimuat (termasuk frame pertama sebelum loadAll jalan).
    if (s.krs == null && s.error == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (s.error != null && s.krs == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: s.loadAll, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(onRefresh: () => s.loadAll(silent: true), child: builder(s));
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
