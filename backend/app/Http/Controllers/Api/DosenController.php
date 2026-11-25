<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Jadwal;
use App\Models\Krs;
use App\Models\Nilai;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DosenController extends Controller
{
    /** GET /api/dosen/kelas -> kelas yang diampu dosen pada periode aktif */
    public function kelas(Request $request): JsonResponse
    {
        $dosen = $this->dosen($request);

        $kelas = Jadwal::with('mataKuliah')
            ->withCount(['krs' => fn ($q) => $q->where('tahun_ajaran', Krs::TAHUN_AJARAN)])
            ->where('dosen_id', $dosen->id)
            ->where('tahun_ajaran', Krs::TAHUN_AJARAN)
            ->orderByRaw("CASE hari WHEN 'Senin' THEN 1 WHEN 'Selasa' THEN 2 WHEN 'Rabu' THEN 3 WHEN 'Kamis' THEN 4 WHEN 'Jumat' THEN 5 WHEN 'Sabtu' THEN 6 ELSE 7 END")
            ->orderBy('jam_mulai')
            ->get()
            ->map(fn (Jadwal $j) => $j->toApi() + ['jumlah_mahasiswa' => $j->krs_count]);

        return response()->json($kelas);
    }

    /** GET /api/dosen/kelas/{id}/mahasiswa -> peserta satu kelas + nilainya */
    public function mahasiswa(Request $request, int $id): JsonResponse
    {
        $dosen = $this->dosen($request);

        // Hanya kelas milik dosen ini; kelas dosen lain -> 404
        $jadwal = Jadwal::with('mataKuliah')->where('dosen_id', $dosen->id)->findOrFail($id);

        $peserta = Krs::with(['mahasiswa.user', 'nilai'])
            ->where('jadwal_id', $jadwal->id)
            ->where('tahun_ajaran', Krs::TAHUN_AJARAN)
            ->get()
            ->sortBy(fn (Krs $k) => $k->mahasiswa->nim)
            ->values()
            ->map(function (Krs $k) {
                $angka = $k->nilai ? (float) $k->nilai->nilai_angka : null;

                return [
                    'krs_id' => $k->id,
                    'nim' => $k->mahasiswa->nim,
                    'nama' => $k->mahasiswa->user->name,
                    'nilai_angka' => $angka,
                    'nilai_huruf' => $angka !== null ? Nilai::huruf($angka) : null,
                ];
            });

        return response()->json([
            'kelas' => $jadwal->toApi(),
            'mahasiswa' => $peserta,
        ]);
    }

    /** PUT /api/dosen/nilai {krs_id, nilai_angka} -> simpan/ubah nilai */
    public function simpanNilai(Request $request): JsonResponse
    {
        $dosen = $this->dosen($request);

        $data = $request->validate([
            'krs_id' => 'required|integer|exists:krs,id',
            'nilai_angka' => 'required|numeric|min:0|max:100',
        ]);

        $krs = Krs::with('jadwal')->findOrFail($data['krs_id']);

        // Dosen hanya boleh menilai kelas miliknya sendiri
        if ((int) $krs->jadwal->dosen_id !== (int) $dosen->id) {
            return response()->json(['message' => 'Anda tidak berhak menilai kelas ini.'], 403);
        }

        Nilai::updateOrCreate(
            ['krs_id' => $krs->id],
            ['nilai_angka' => $data['nilai_angka']]
        );

        return response()->json(['message' => 'Nilai disimpan.']);
    }

    private function dosen(Request $request): User
    {
        $user = $request->user();
        abort_unless($user->role === 'dosen', 403, 'Hanya dosen yang dapat mengakses fitur ini.');

        return $user;
    }
}
