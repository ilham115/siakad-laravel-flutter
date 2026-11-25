<?php

namespace Database\Seeders;

use App\Models\Jadwal;
use App\Models\Krs;
use App\Models\Mahasiswa;
use App\Models\MataKuliah;
use App\Models\Nilai;
use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Akun demo: login NIM 12230001 / password "password"
        $user = User::create([
            'name' => 'Mahasiswa Demo',
            'email' => '12230001@siakad.test',
            'password' => 'password', // di-hash otomatis oleh cast 'hashed'
            'role' => 'mahasiswa',
        ]);
        $mhs = Mahasiswa::create([
            'user_id' => $user->id,
            'nim' => '12230001',
            'prodi' => 'Informatika',
            'angkatan' => 2023,
            'semester_aktif' => 5,
        ]);

        // [kode, nama, sks, semester]
        $mkData = [
            ['IF101', 'Algoritma dan Pemrograman', 3, 1],
            ['IF201', 'Basis Data', 3, 3],
            ['IF301', 'Pemrograman Web', 3, 5],
            ['IF302', 'Pemrograman Berbasis Platform 2', 3, 5],
            ['IF303', 'Rekayasa Perangkat Lunak', 3, 5],
            ['IF304', 'Jaringan Komputer', 3, 5],
            ['IF305', 'Kecerdasan Buatan', 3, 5],
        ];
        $mk = [];
        foreach ($mkData as [$kode, $nama, $sks, $smt]) {
            $mk[$kode] = MataKuliah::create(compact('kode', 'nama', 'sks') + ['semester' => $smt]);
        }

        // [kode MK, dosen, hari, mulai, selesai, ruang]
        $jadwalData = [
            ['IF301', 'Dosen A, M.Kom.', 'Senin', '08:00', '10:30', 'Lab 1'],
            ['IF302', 'Dosen B, M.Kom.', 'Selasa', '10:00', '12:30', 'Lab 2'],
            ['IF303', 'Dosen C, M.T.', 'Rabu', '08:00', '10:30', 'R.201'],
            ['IF304', 'Dosen D, M.T.', 'Rabu', '09:00', '11:30', 'R.202'], // sengaja bentrok dengan IF303
            ['IF305', 'Dosen E, M.Cs.', 'Kamis', '13:00', '15:30', 'R.203'],
        ];
        foreach ($jadwalData as [$kode, $dosen, $hari, $mulai, $selesai, $ruang]) {
            Jadwal::create([
                'mata_kuliah_id' => $mk[$kode]->id,
                'tahun_ajaran' => Krs::TAHUN_AJARAN,
                'dosen' => $dosen,
                'hari' => $hari,
                'jam_mulai' => $mulai,
                'jam_selesai' => $selesai,
                'ruang' => $ruang,
                'kuota' => 40,
            ]);
        }

        // Riwayat semester lalu supaya halaman Nilai/IPK ada isinya
        $riwayat = [['IF101', 85], ['IF201', 72]];
        foreach ($riwayat as [$kode, $angka]) {
            $jadwalLama = Jadwal::create([
                'mata_kuliah_id' => $mk[$kode]->id,
                'tahun_ajaran' => '2025/2026-Genap',
                'dosen' => 'Dosen Lama',
                'hari' => 'Jumat',
                'jam_mulai' => '08:00',
                'jam_selesai' => '10:00',
                'ruang' => 'R.101',
                'kuota' => 40,
            ]);
            $krs = Krs::create([
                'mahasiswa_id' => $mhs->id,
                'jadwal_id' => $jadwalLama->id,
                'tahun_ajaran' => '2025/2026-Genap',
            ]);
            Nilai::create(['krs_id' => $krs->id, 'nilai_angka' => $angka]);
        }
    }
}
