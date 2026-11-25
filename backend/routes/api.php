<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\JadwalController;
use App\Http\Controllers\Api\KrsController;
use App\Http\Controllers\Api\NilaiController;
use Illuminate\Support\Facades\Route;

// Publik
Route::post('/login', [AuthController::class, 'login']);

// Wajib token Sanctum (header: Authorization: Bearer <token>)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/jadwal', [JadwalController::class, 'index']);

    Route::get('/krs', [KrsController::class, 'index']);
    Route::post('/krs', [KrsController::class, 'store']);
    Route::delete('/krs/{id}', [KrsController::class, 'destroy']);

    Route::get('/nilai', [NilaiController::class, 'index']);
});
