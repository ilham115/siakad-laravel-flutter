# SIAKAD — Flutter (Android + Web) + Laravel API

```
siakad/
├── backend/       <- file-file Laravel yang DITIMPA/DITAMBAH ke proyek Laravel baru
├── flutter_app/   <- file-file Flutter (lib/ + pubspec.yaml)
└── docs/RANCANGAN-UTS.md   <- bahan dokumen & slide UTS
```

Fitur tahap ini:
- **Mahasiswa**: login NIM, jadwal kuliah, pengisian KRS (aturan: tidak duplikat, maks 24 SKS,
  tidak bentrok, kuota), presensi dengan kode 6 angka, nilai + IPK.
- **Dosen**: login email, daftar kelas yang diampu, buka/tutup sesi presensi (kode angka),
  lihat kehadiran per pertemuan, input/ubah nilai peserta kelas.

Alur presensi: dosen membuka sesi (kode 6 angka dibuat otomatis, berlaku 1–120 menit) → dosen
membagikan kode → mahasiswa memasukkan kode di menu Presensi. Mahasiswa tidak bisa presensi
sebelum dosen membuka sesi atau setelah sesi ditutup/habis waktu.

Akun demo (setelah `php artisan migrate:fresh --seed`):

| Peran | Login | Password |
|---|---|---|
| Mahasiswa | NIM `12230001` s.d. `12230010` | sama dengan NIM |
| Dosen A | `dosen.a@siakad.test` (IF301, IF302, IF312) | `dosen123` |
| Dosen B | `dosen.b@siakad.test` (IF303, IF304, IF305) | `dosen123` |
| Dosen C | `dosen.c@siakad.test` (IF306, IF307, IF308) | `dosen123` |
| Dosen D | `dosen.d@siakad.test` (IF309, IF310, IF311) | `dosen123` |

Data awal: 12 kelas semester ini (tanpa riwayat semester lalu). Akun `12230001` KRS-nya kosong
untuk uji coba; `12230002`–`12230006` sudah mengambil kelas Dosen A, `12230007`–`12230010`
sudah mengambil kelas Dosen B, C, dan D.

## A. Backend Laravel

Prasyarat: PHP 8.2+, Composer, MySQL (XAMPP/Laragon juga boleh).

```bash
composer create-project laravel/laravel siakad-api
cd siakad-api
php artisan install:api          # memasang Laravel Sanctum + routes/api.php
```

1. Ubah `.env`: `DB_CONNECTION=mysql`, `DB_DATABASE=siakad`, `DB_USERNAME`, `DB_PASSWORD`; buat database `siakad`.
2. Salin isi folder `backend/` ke dalam `siakad-api/` (timpa `app/Models/User.php`,
   `routes/api.php`, `database/seeders/DatabaseSeeder.php`).
3. Jalankan:

```bash
php artisan migrate:fresh --seed
php artisan serve --host=0.0.0.0 --port=8000
```

Uji cepat (PowerShell/terminal):

```bash
curl -X POST http://localhost:8000/api/login -H "Accept: application/json" -d "username=12230001&password=12230001"
```

## B. Flutter

```bash
cd flutter_app
flutter create . --platforms=android,web   # membuat folder android/ & web/
flutter pub get
flutter run -d chrome                      # web
flutter run                                # emulator Android
```

`flutter create .` tidak menimpa `lib/` dan `pubspec.yaml` yang sudah ada — tetapi cek dulu
bahwa `lib/main.dart` masih isi dari proyek ini; jika terganti, salin ulang.

Alamat API diatur di `lib/core/config.dart`
(emulator Android memakai `10.0.2.2`, HP asli memakai IP laptop).

Android 9+ memblokir HTTP polos. Untuk pengembangan, tambahkan di
`android/app/src/main/AndroidManifest.xml` pada tag `<application ...>`:
`android:usesCleartextTraffic="true"` — **hapus/ganti HTTPS saat produksi.**

## Endpoint

| Method | Path | Auth | Fungsi |
|---|---|---|---|
| POST | /api/login | – | Login `username` (NIM/email) + password, balas token |
| GET | /api/me | ✔ | Profil mahasiswa |
| POST | /api/logout | ✔ | Cabut token |
| GET | /api/jadwal | ✔ | Kelas yang dibuka periode aktif |
| GET | /api/krs | ✔ | KRS periode aktif + total SKS |
| POST | /api/krs | ✔ | Ambil kelas `{jadwal_id}` |
| DELETE | /api/krs/{id} | ✔ | Batalkan kelas |
| GET | /api/nilai | ✔ | Nilai + IPK |
| GET | /api/dosen/kelas | ✔ dosen | Kelas yang diampu |
| GET | /api/dosen/kelas/{id}/mahasiswa | ✔ dosen | Peserta kelas + nilai |
| PUT | /api/dosen/nilai | ✔ dosen | Simpan nilai `{krs_id, nilai_angka}` |
| GET | /api/presensi | ✔ | Rekap kehadiran per kelas (mahasiswa) |
| POST | /api/presensi | ✔ | Isi presensi `{kode}` (maks 10 percobaan/menit) |
| GET | /api/dosen/kelas/{id}/presensi | ✔ dosen | Daftar pertemuan satu kelas |
| POST | /api/dosen/kelas/{id}/presensi | ✔ dosen | Buka sesi `{durasi_menit}` |
| GET | /api/dosen/presensi/{sesiId} | ✔ dosen | Siapa yang hadir pada satu pertemuan |
| POST | /api/dosen/presensi/{sesiId}/tutup | ✔ dosen | Tutup sesi lebih awal |
