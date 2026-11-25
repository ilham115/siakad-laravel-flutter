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
            ->orderBy('hari')
            ->orderBy('jam_mulai')
            ->get()
            ->map(fn (Jadwal $j) => $j->toApi());

        return response()->json($jadwals);
    }
}
