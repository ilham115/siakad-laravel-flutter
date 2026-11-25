<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Jadwal;
use App\Models\Krs;
use App\Models\Presensi;
use App\Models\PresensiSesi;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DosenPresensiController extends Controller
{
    /** Jumlah pertemuan maksimal per semester. */
    private const MAKS_PERTEMUAN = 16;

    /** GET /api/dosen/kelas/{id}/presensi -> semua pertemuan satu kelas */
    public function index(Request $request, int $id): JsonResponse
    {
        $jadwal = $this->kelasMilik($this->dosen($request), $id);

        $jumlahMahasiswa = Krs::where('jadwal_id', $jadwal->id)
            ->where('tahun_ajaran', Krs::TAHUN_AJARAN)
            ->count();

        $sesi = PresensiSesi::withCount('presensis')
            ->where('jadwal_id', $jadwal->id)
            ->orderByDesc('pertemuan_ke')
            ->get()
            ->map(fn (PresensiSesi $s) => $this->sesiApi($s));

        return response()->json([
            'jumlah_mahasiswa' => $jumlahMahasiswa,
            'sesi' => $sesi,
        ]);
    }

    /** POST /api/dosen/kelas/{id}/presensi {durasi_menit?} -> buka pertemuan baru */
    public function buka(Request $request, int $id): JsonResponse
    {
        $jadwal = $this->kelasMilik($this->dosen($request), $id);

        $data = $request->validate([
            'durasi_menit' => 'nullable|integer|min:1|max:120',
        ], [
            'durasi_menit.integer' => 'Durasi harus berupa angka.',
            'durasi_menit.min' => 'Durasi minimal 1 menit.',
            'durasi_menit.max' => 'Durasi maksimal 120 menit.',
        ]);

        $masihAktif = PresensiSesi::where('jadwal_id', $jadwal->id)
            ->where('berlaku_sampai', '>', now())
            ->exists();
        if ($masihAktif) {
            return response()->json([
                'message' => 'Masih ada sesi presensi yang aktif. Tutup dulu sebelum membuat yang baru.',
            ], 422);
        }

        $pertemuanKe = (int) PresensiSesi::where('jadwal_id', $jadwal->id)->max('pertemuan_ke') + 1;
        if ($pertemuanKe > self::MAKS_PERTEMUAN) {
            return response()->json([
                'message' => 'Jumlah pertemuan sudah mencapai '.self::MAKS_PERTEMUAN.'.',
            ], 422);
        }

        $sesi = PresensiSesi::create([
            'jadwal_id' => $jadwal->id,
            'pertemuan_ke' => $pertemuanKe,
            'kode' => $this->buatKode(),
            'berlaku_sampai' => now()->addMinutes($data['durasi_menit'] ?? 15),
        ]);

        return response()->json($this->sesiApi($sesi), 201);
    }

    /** POST /api/dosen/presensi/{sesiId}/tutup -> tutup pertemuan lebih awal */
    public function tutup(Request $request, int $sesiId): JsonResponse
    {
        $dosen = $this->dosen($request);
        $sesi = PresensiSesi::with('jadwal')->findOrFail($sesiId);

        if ((int) $sesi->jadwal->dosen_id !== (int) $dosen->id) {
            return response()->json(['message' => 'Anda tidak berhak mengelola kelas ini.'], 403);
        }

        $sesi->update(['berlaku_sampai' => now()]);

        return response()->json(['message' => 'Sesi presensi ditutup.']);
    }

    /** GET /api/dosen/presensi/{sesiId} -> siapa saja yang hadir pada satu pertemuan */
    public function detail(Request $request, int $sesiId): JsonResponse
    {
        $dosen = $this->dosen($request);
        $sesi = PresensiSesi::with('jadwal')->findOrFail($sesiId);

        if ((int) $sesi->jadwal->dosen_id !== (int) $dosen->id) {
            return response()->json(['message' => 'Anda tidak berhak mengelola kelas ini.'], 403);
        }

        // krs_id yang sudah hadir (dijadikan kunci agar pencarian cepat)
        $hadir = Presensi::where('presensi_sesi_id', $sesi->id)->pluck('krs_id')->flip();

        $peserta = Krs::with('mahasiswa.user')
            ->where('jadwal_id', $sesi->jadwal_id)
            ->where('tahun_ajaran', Krs::TAHUN_AJARAN)
            ->get()
            ->sortBy(fn (Krs $k) => $k->mahasiswa->nim)
            ->values()
            ->map(fn (Krs $k) => [
                'nim' => $k->mahasiswa->nim,
                'nama' => $k->mahasiswa->user->name,
                'hadir' => $hadir->has($k->id),
            ]);

        return response()->json([
            'sesi' => $this->sesiApi($sesi->loadCount('presensis')),
            'peserta' => $peserta,
        ]);
    }

    private function sesiApi(PresensiSesi $s): array
    {
        $sisa = max(0, $s->berlaku_sampai->getTimestamp() - now()->getTimestamp());

        return [
            'sesi_id' => $s->id,
            'pertemuan_ke' => $s->pertemuan_ke,
            'kode' => $s->kode,
            'aktif' => $sisa > 0,
            'sisa_detik' => $sisa,
            'jumlah_hadir' => $s->presensis_count ?? 0,
        ];
    }

    /** Kode 6 angka yang belum dipakai sesi aktif lain, supaya tidak bertabrakan. */
    private function buatKode(): string
    {
        do {
            $kode = (string) random_int(100000, 999999);
            $dipakai = PresensiSesi::where('kode', $kode)
                ->where('berlaku_sampai', '>', now())
                ->exists();
        } while ($dipakai);

        return $kode;
    }

    private function kelasMilik(User $dosen, int $id): Jadwal
    {
        return Jadwal::where('dosen_id', $dosen->id)
            ->where('tahun_ajaran', Krs::TAHUN_AJARAN)
            ->findOrFail($id);
    }

    private function dosen(Request $request): User
    {
        $user = $request->user();
        abort_unless($user->role === 'dosen', 403, 'Hanya dosen yang dapat mengakses fitur ini.');

        return $user;
    }
}
