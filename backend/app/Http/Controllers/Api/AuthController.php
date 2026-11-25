<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mahasiswa;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * POST /api/login  {username, password} -> {token, user}
     * Mahasiswa login dengan NIM, dosen login dengan email.
     */
    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $mahasiswa = Mahasiswa::with('user')->where('nim', $data['username'])->first();

        $user = $mahasiswa
            ? $mahasiswa->user
            : User::where('email', $data['username'])->where('role', 'dosen')->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return response()->json(['message' => 'NIM/email atau password salah.'], 401);
        }

        $token = $user->createToken('flutter-app')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $this->profil($user),
        ]);
    }

    /** GET /api/me */
    public function me(Request $request): JsonResponse
    {
        return response()->json($this->profil($request->user()));
    }

    /** POST /api/logout */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Berhasil keluar.']);
    }

    private function profil(User $user): array
    {
        $profil = [
            'nama' => $user->name,
            'role' => $user->role,
            'email' => $user->email,
        ];

        $m = $user->mahasiswa;
        if ($m) {
            $profil += [
                'nim' => $m->nim,
                'prodi' => $m->prodi,
                'angkatan' => $m->angkatan,
                'semester_aktif' => $m->semester_aktif,
            ];
        }

        return $profil;
    }
}
