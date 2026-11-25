<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Satu baris = satu pertemuan yang dibuka dosen, dengan kode angka.
        Schema::create('presensi_sesis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('jadwal_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('pertemuan_ke');
            $table->string('kode', 6);
            $table->dateTime('berlaku_sampai');
            $table->timestamps();

            $table->unique(['jadwal_id', 'pertemuan_ke']);
        });

        // Satu baris = satu mahasiswa hadir pada satu pertemuan.
        Schema::create('presensis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('presensi_sesi_id')->constrained('presensi_sesis')->cascadeOnDelete();
            $table->foreignId('krs_id')->constrained('krs')->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['presensi_sesi_id', 'krs_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('presensis');
        Schema::dropIfExists('presensi_sesis');
    }
};
