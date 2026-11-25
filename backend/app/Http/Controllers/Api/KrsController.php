<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Jadwal;
use App\Models\Krs;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class KrsController extends Controller
{
    /** GET /api/krs -> KRS semester aktif milik mahasiswa yang login */
    public function index(Request $request): JsonResponse
    {
        $mhs = $this->mahasiswa($request);
        $krs = $this->krsAktif($mhs->id);

        return response()->json([
            'tahun_ajaran' => Krs::TAHUN_AJARAN,
            'total_sks' => $krs->sum(fn (Krs $k) => $k->jadwal->mataKuliah->sks),
            'maks_sks' => Krs::MAKS_SKS,
            'items' => $krs->map(fn (Krs $k) => ['krs_id' => $k->id] + $k->jadwal->toApi())->values(),
        ]);
    }

    /** POST /api/krs {jadwal_id} -> ambil satu kelas */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate(['jadwal_id' => 'required|integer|exists:jadwals,id']);

        $mhs = $this->mahasiswa($request);
        $jadwal = Jadwal::with('mataKuliah')->findOrFail($data['jadwal_id']);
        $krsAktif = $this->krsAktif($mhs->id);

        // Aturan 1: mata kuliah yang sama tidak boleh diambil dua kali
        if ($krsAktif->contains(fn (Krs $k) => $k->jadwal->mata_kuliah_id === $jadwal->mata_kuliah_id)) {
            return $this->tolak('Mata kuliah ini sudah ada di KRS Anda.');
        }

        // Aturan 2: batas maksimal SKS
        $totalSks = $krsAktif->sum(fn (Krs $k) => $k->jadwal->mataKuliah->sks);
        if ($totalSks + $jadwal->mataKuliah->sks > Krs::MAKS_SKS) {
            return $this->tolak('Total SKS melebihi batas '.Krs::MAKS_SKS.' SKS.');
        }

        // Aturan 3: tidak boleh bentrok jadwal (hari sama, jam beririsan)
        $bentrok = $krsAktif->contains(fn (Krs $k) => $k->jadwal->hari === $jadwal->hari
            && $k->jadwal->jam_mulai < $jadwal->jam_selesai
            && $jadwal->jam_mulai < $k->jadwal->jam_selesai);
        if ($bentrok) {
            return $this->tolak('Jadwal bentrok dengan kelas lain di KRS Anda.');
        }

        // Aturan 4: kuota kelas
        $terisi = Krs::where('jadwal_id', $jadwal->id)->where('tahun_ajaran', Krs::TAHUN_AJARAN)->count();
        if ($terisi >= $jadwal->kuota) {
            return $this->tolak('Kuota kelas sudah penuh.');
        }

        Krs::create([
            'mahasiswa_id' => $mhs->id,
            'jadwal_id' => $jadwal->id,
            'tahun_ajaran' => Krs::TAHUN_AJARAN,
        ]);

        return response()->json(['message' => 'Kelas berhasil ditambahkan ke KRS.'], 201);
    }

    /** DELETE /api/krs/{id} -> batalkan satu kelas */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $mhs = $this->mahasiswa($request);

        $krs = Krs::where('mahasiswa_id', $mhs->id)
            ->where('tahun_ajaran', Krs::TAHUN_AJARAN)
            ->findOrFail($id);
        $krs->delete();

        return response()->json(['message' => 'Kelas dibatalkan dari KRS.']);
    }

    private function mahasiswa(Request $request)
    {
        $mhs = $request->user()->mahasiswa;
        abort_if(! $mhs, 403, 'Hanya mahasiswa yang dapat mengakses KRS.');

        return $mhs;
    }

    private function krsAktif(int $mahasiswaId)
    {
        return Krs::with('jadwal.mataKuliah')
            ->where('mahasiswa_id', $mahasiswaId)
            ->where('tahun_ajaran', Krs::TAHUN_AJARAN)
            ->get();
    }

    private function tolak(string $pesan): JsonResponse
    {
        return response()->json(['message' => $pesan], 422);
    }
}
