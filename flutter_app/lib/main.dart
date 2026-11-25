import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/dosen_provider.dart';
import 'providers/siakad_provider.dart';
import 'screens/dosen_home.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

void main() => runApp(const SiakadApp());

class SiakadApp extends StatelessWidget {
  const SiakadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiClient()),
        ChangeNotifierProvider(
          create: (c) => AuthProvider(c.read<ApiClient>())..tryAutoLogin(),
        ),
        ChangeNotifierProvider(
          create: (c) => SiakadProvider(c.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (c) => DosenProvider(c.read<ApiClient>()),
        ),
      ],
      child: MaterialApp(
        title: 'SIAKAD',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const _Root(),
      ),
    );
  }
}

/// Memilih layar awal berdasarkan status login.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isLoggedIn) return const LoginScreen();
    // Tampilan dipilih berdasarkan peran akun.
    return auth.user!.isDosen ? const DosenHome() : const HomeShell();
  }
}
