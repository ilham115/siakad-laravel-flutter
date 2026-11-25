import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_client.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient api;
  AuthProvider(this.api);

  static const _tokenKey = 'auth_token';

  AppUser? user;
  bool initialized = false; // sudah selesai cek token tersimpan?
  bool loading = false;
  String? error;

  bool get isLoggedIn => user != null;

  /// Dipanggil sekali saat aplikasi dibuka: pakai token lama bila masih valid.
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey);
    if (saved != null) {
      api.token = saved;
      try {
        user = AppUser.fromJson(await api.get('/me'));
      } on ApiException {
        api.token = null;
        await prefs.remove(_tokenKey);
      }
    }
    initialized = true;
    notifyListeners();
  }

  /// [username] = NIM (mahasiswa) atau email (dosen).
  Future<bool> login(String username, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await api.post('/login', {'username': username, 'password': password});
      api.token = res['token'];
      user = AppUser.fromJson(res['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, res['token']);
      loading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await api.post('/logout');
    } on ApiException {
      // tetap lanjut keluar secara lokal
    }
    api.token = null;
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    notifyListeners();
  }
}
