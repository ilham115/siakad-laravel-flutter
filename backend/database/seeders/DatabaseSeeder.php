<?php

namespace Database\Seeders;

use App\Models\Jadwal;
use App\Models\Krs;
use App\Models\Mahasiswa;
use App\Models\MataKuliah;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ---------- Akun dosen ----------
        // Login dengan email, password: dosen123
        $dosen = [];
        $daftarDosen = [
            'A' => 'Dosen A, M.Kom.',
            'B' => 'Dosen B, M.T.',
            'C' => 'Dosen C, M.Cs.',
            'D' => 'Dosen D, M.Kom.',
        ];
        foreach ($daftarDosen as $huruf => $nama) {
            $dosen[$huruf] = User::create([
                'name' => $nama,
                'email' => 'dosen.'.strtolower($huruf).'@siakad.test',
                'password' => 'dosen123', // di-hash otomatis oleh cast 'hashed'
                'role' => 'dosen',
            ]);
        }

        // ---------- Mata kuliah + kelas semester ini ----------
        // [kode, nama, sks, dosen, hari, mulai, selesai, ruang]
        $kelasData = [
            ['IF301', 'Pemrograman Web', 3, 'A', 'Senin', '08:00', '10:30', 'Lab 1'],
            ['IF302', 'Pemrograman Berbasis Platform 2', 3, 'A', 'Selasa', '10:00', '12:30', 'Lab 2'],
            ['IF312', 'Etika Profesi', 2, 'A', 'Sabtu', '08:00', '10:00', 'R.208'],

            ['IF303', 'Rekayasa Perangkat Lunak', 3, 'B', 'Rabu', '08:00', '10:30', 'R.201'],
            ['IF304', 'Jaringan Komputer', 3, 'B', 'Rabu', '09:00', '11:30', 'R.202'], // sengaja bentrok dengan IF303
            ['IF305', 'Kecerdasan Buatan', 3, 'B', 'Kamis', '13:00', '15:30', 'R.203'],

            ['IF306', 'Keamanan Informasi', 3, 'C', 'Senin', '13:00', '15:30', 'R.204'],
            ['IF307', 'Interaksi Manusia dan Komputer', 3, 'C', 'Selasa', '08:00', '10:00', 'R.205'],
            ['IF308', 'Sistem Operasi', 3, 'C', 'Kamis', '08:00', '10:30', 'R.206'],

            ['IF309', 'Data Mining', 3, 'D', 'Jumat', '08:00', '10:30', 'Lab 3'],
            ['IF310', 'Manajemen Proyek TI', 2, 'D', 'Jumat', '13:00', '15:00', 'R.207'],
            ['IF311', 'Komputasi Awan', 3, 'D', 'Rabu', '13:00', '15:30', 'Lab 4'],
        ];

        $jadwal = [];
        foreach ($kelasData as [$kode, $nama, $sks, $kodeDosen, $hari, $mulai, $selesai, $ruang]) {
            $mk = MataKuliah::create([
                'kode' => $kode,
                'nama' => $nama,
                'sks' => $sks,
                'semester' => 5,
            ]);

            $jadwal[$kode] = Jadwal::create([
                'mata_kuliah_id' => $mk->id,
                'tahun_ajaran' => Krs::TAHUN_AJARAN,
                'dosen_id' => $dosen[$kodeDosen]->id,
                'dosen' => $dosen[$kodeDosen]->name,
                'hari' => $hari,
                'jam_mulai' => $mulai,
                'jam_selesai' => $selesai,
                'ruang' => $ruang,
                'kuota' => 40,
            ]);
        }

        // ---------- Akun mahasiswa demo ----------
        // NIM otomatis: 12230001, 12230002, ... Password masing-masing = NIMnya sendiri
        $daftarNama = [
            'Mahasiswa Demo',
            'Andi Pratama',
            'Budi Santoso',
            'Citra Lestari',
            'Dewi Anggraini',
            'Eko Prasetyo',
            'Fitri Handayani',
            'Gilang Ramadhan',
            'Hana Permata',
            'Indra Wijaya',
        ];

        foreach ($daftarNama as $i => $nama) {
            $nim = sprintf('1223%04d', $i + 1);

            $user = User::create([
                'name' => $nama,
                'email' => $nim.'@siakad.test',
                'password' => $nim, // password = NIM
                'role' => 'mahasiswa',
            ]);

            $mhs = Mahasiswa::create([
                'user_id' => $user->id,
                'nim' => $nim,
                'prodi' => 'Informatika',
                'angkatan' => 2023,
                'semester_aktif' => 5,
            ]);

            // KRS awal supaya tiap dosen punya peserta untuk dinilai / dipresensi.
            // Akun demo (nomor 1) sengaja dikosongkan untuk uji coba pengisian KRS.
            $kelasDiambil = match (true) {
                $i >= 1 && $i <= 5 => ['IF301', 'IF302'],           // kelas Dosen A
                $i >= 6 => ['IF303', 'IF306', 'IF309'],             // kelas Dosen B, C, D
                default => [],
            };

            foreach ($kelasDiambil as $kode) {
                Krs::create([
                    'mahasiswa_id' => $mhs->id,
                    'jadwal_id' => $jadwal[$kode]->id,
                    'tahun_ajaran' => Krs::TAHUN_AJARAN,
                ]);
            }
        }
    }
}
