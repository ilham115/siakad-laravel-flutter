<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mahasiswa;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /** POST /api/login  {nim, password} -> {token, user} */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'nim' => 'required|string',
            'password' => 'required|string',
        ]);

        $mahasiswa = Mahasiswa::with('user')->where('nim', $data['nim'])->first();

        if (! $mahasiswa || ! Hash::check($data['password'], $mahasiswa->user->password)) {
            return response()->json(['message' => 'NIM atau password salah.'], 401);
        }

        $token = $mahasiswa->user->createToken('flutter-app')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $this->profil($mahasiswa),
        ]);
    }

    /** GET /api/me */
    public function me(Request $request): JsonResponse
    {
        $mahasiswa = $request->user()->mahasiswa()->with('user')->first();
        abort_if(! $mahasiswa, 403, 'Akun ini bukan akun mahasiswa.');

        return response()->json($this->profil($mahasiswa));
    }

    /** POST /api/logout */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Berhasil keluar.']);
    }

    private function profil(Mahasiswa $m): array
    {
        return [
            'nama' => $m->user->name,
            'nim' => $m->nim,
            'prodi' => $m->prodi,
            'angkatan' => $m->angkatan,
            'semester_aktif' => $m->semester_aktif,
        ];
    }
}
