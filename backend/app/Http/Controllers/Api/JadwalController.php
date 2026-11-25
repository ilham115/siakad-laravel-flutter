<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Jadwal;
use App\Models\Krs;
use Illuminate\Http\JsonResponse;

class JadwalController extends Controller
{
    /** GET /api/jadwal -> daftar kelas yang ditawarkan semester ini */
    public function index(): JsonResponse
    {
        $jadwals = Jadwal::with('mataKuliah')
            ->where('tahun_ajaran', Krs::TAHUN_AJARAN)
            ->orderByRaw("CASE hari WHEN 'Senin' THEN 1 WHEN 'Selasa' THEN 2 WHEN 'Rabu' THEN 3 WHEN 'Kamis' THEN 4 WHEN 'Jumat' THEN 5 WHEN 'Sabtu' THEN 6 ELSE 7 END")
            ->orderBy('jam_mulai')
            ->get()
            ->map(fn (Jadwal $j) => $j->toApi());

        return response()->json($jadwals);
    }
}
