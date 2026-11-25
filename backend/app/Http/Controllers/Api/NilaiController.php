<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Nilai;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NilaiController extends Controller
{
    /** GET /api/nilai -> KHS gabungan + IPK */
    public function index(Request $request): JsonResponse
    {
        $mhs = $request->user()->mahasiswa;
        abort_if(! $mhs, 403, 'Hanya mahasiswa yang dapat melihat nilai.');

        $nilais = Nilai::with('krs.jadwal.mataKuliah')
            ->whereHas('krs', fn ($q) => $q->where('mahasiswa_id', $mhs->id))
            ->get();

        $totalSks = 0;
        $totalMutu = 0.0;

        $items = $nilais->map(function (Nilai $n) use (&$totalSks, &$totalMutu) {
            $mk = $n->krs->jadwal->mataKuliah;
            $angka = (float) $n->nilai_angka;
            $huruf = Nilai::huruf($angka);
            $bobot = Nilai::bobot($huruf);

            $totalSks += $mk->sks;
            $totalMutu += $bobot * $mk->sks;

            return [
                'kode' => $mk->kode,
                'nama' => $mk->nama,
                'sks' => $mk->sks,
                'tahun_ajaran' => $n->krs->tahun_ajaran,
                'nilai_angka' => $angka,
                'nilai_huruf' => $huruf,
                'bobot' => $bobot,
            ];
        })->values();

        return response()->json([
            'ipk' => $totalSks > 0 ? round($totalMutu / $totalSks, 2) : 0.0,
            'total_sks' => $totalSks,
            'items' => $items,
        ]);
    }
}
