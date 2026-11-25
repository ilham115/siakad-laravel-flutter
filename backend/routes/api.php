<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DosenController;
use App\Http\Controllers\Api\DosenPresensiController;
use App\Http\Controllers\Api\JadwalController;
use App\Http\Controllers\Api\KrsController;
use App\Http\Controllers\Api\NilaiController;
use App\Http\Controllers\Api\PresensiController;
use Illuminate\Support\Facades\Route;

// Publik
Route::post('/login', [AuthController::class, 'login']);

// Wajib token Sanctum (header: Authorization: Bearer <token>)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Mahasiswa
    Route::get('/jadwal', [JadwalController::class, 'index']);

    Route::get('/krs', [KrsController::class, 'index']);
    Route::post('/krs', [KrsController::class, 'store']);
    Route::delete('/krs/{id}', [KrsController::class, 'destroy']);

    Route::get('/nilai', [NilaiController::class, 'index']);

    Route::get('/presensi', [PresensiController::class, 'index']);
    // Dibatasi 10 percobaan per menit agar kode 6 angka tidak bisa ditebak beruntun
    Route::post('/presensi', [PresensiController::class, 'store'])->middleware('throttle:10,1');

    // Dosen (peran dicek di dalam controller)
    Route::get('/dosen/kelas', [DosenController::class, 'kelas']);
    Route::get('/dosen/kelas/{id}/mahasiswa', [DosenController::class, 'mahasiswa']);
    Route::put('/dosen/nilai', [DosenController::class, 'simpanNilai']);

    Route::get('/dosen/kelas/{id}/presensi', [DosenPresensiController::class, 'index']);
    Route::post('/dosen/kelas/{id}/presensi', [DosenPresensiController::class, 'buka']);
    Route::get('/dosen/presensi/{sesiId}', [DosenPresensiController::class, 'detail']);
    Route::post('/dosen/presensi/{sesiId}/tutup', [DosenPresensiController::class, 'tutup']);
});
