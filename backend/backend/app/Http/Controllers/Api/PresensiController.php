<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Krs;
use App\Models\Presensi;
use App\Models\PresensiSesi;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PresensiController extends Controller
{
    /** GET /api/presensi -> rekap kehadiran per kelas di KRS aktif */
    public function index(Request $request): JsonResponse
    {
        $krsAktif = $this->krsAktif($request);

        $items = $krsAktif->map(function (Krs $k) {
            $total = PresensiSesi::where('jadwal_id', $k->jadwal_id)->count();
            $hadir = Presensi::where('krs_id', $k->id)->count();

            // Ada sesi yang masih dibuka dan mahasiswa ini belum mengisinya?
            $sesiAktif = PresensiSesi::where('jadwal_id', $k->jadwal_id)
                ->where('berlaku_sampai', '>', now())
                ->first();
            $perluPresensi = $sesiAktif
                && ! Presensi::where('presensi_sesi_id', $sesiAktif->id)->where('krs_id', $k->id)->exists();

            return $k->jadwal->toApi() + [
                'total_pertemuan' => $total,
                'hadir' => $hadir,
                'sesi_aktif' => (bool) $perluPresensi,
            ];
        })->values();

        return response()->json($items);
    }

    /** POST /api/presensi {kode} -> mahasiswa mengisi presensi dengan kode dari dosen */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'kode' => 'required|digits:6',
        ], [
            'kode.required' => 'Kode presensi wajib diisi.',
            'kode.digits' => 'Kode presensi harus 6 angka.',
        ]);

        $krsAktif = $this->krsAktif($request)->keyBy('jadwal_id');

        // Hanya sesi aktif dari kelas yang memang diambil mahasiswa ini
        $sesi = PresensiSesi::where('kode', $data['kode'])
            ->where('berlaku_sampai', '>', now())
            ->whereIn('jadwal_id', $krsAktif->keys()->all())
            ->first();

        if (! $sesi) {
            return response()->json(['message' => 'Kode salah atau sesi presensi sudah ditutup.'], 422);
        }

        $krs = $krsAktif[$sesi->jadwal_id];

        $sudah = Presensi::where('presensi_sesi_id', $sesi->id)->where('krs_id', $krs->id)->exists();
        if ($sudah) {
            return response()->json(['message' => 'Anda sudah presensi pada pertemuan ini.'], 422);
        }

        Presensi::create(['presensi_sesi_id' => $sesi->id, 'krs_id' => $krs->id]);

        return response()->json([
            'message' => 'Presensi '.$krs->jadwal->mataKuliah->nama.' pertemuan ke-'.$sesi->pertemuan_ke.' berhasil.',
        ], 201);
    }

    private function krsAktif(Request $request)
    {
        $mhs = $request->user()->mahasiswa;
        abort_if(! $mhs, 403, 'Hanya mahasiswa yang dapat melakukan presensi.');

        return Krs::with('jadwal.mataKuliah')
            ->where('mahasiswa_id', $mhs->id)
            ->where('tahun_ajaran', Krs::TAHUN_AJARAN)
            ->get();
    }
}
