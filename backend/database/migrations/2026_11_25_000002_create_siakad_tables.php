<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mahasiswas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('nim')->unique();
            $table->string('prodi');
            $table->unsignedSmallInteger('angkatan');
            $table->unsignedTinyInteger('semester_aktif')->default(1);
            $table->timestamps();
        });

        Schema::create('mata_kuliahs', function (Blueprint $table) {
            $table->id();
            $table->string('kode')->unique();
            $table->string('nama');
            $table->unsignedTinyInteger('sks');
            $table->unsignedTinyInteger('semester');
            $table->timestamps();
        });

        Schema::create('jadwals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mata_kuliah_id')->constrained()->cascadeOnDelete();
            $table->string('tahun_ajaran'); // periode kelas ini dibuka
            $table->string('dosen');
            $table->string('hari'); // Senin..Sabtu
            $table->time('jam_mulai');
            $table->time('jam_selesai');
            $table->string('ruang');
            $table->unsignedSmallInteger('kuota')->default(40);
            $table->timestamps();
        });

        Schema::create('krs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mahasiswa_id')->constrained()->cascadeOnDelete();
            $table->foreignId('jadwal_id')->constrained()->cascadeOnDelete();
            $table->string('tahun_ajaran'); // contoh: 2026/2027-Ganjil
            $table->timestamps();

            $table->unique(['mahasiswa_id', 'jadwal_id', 'tahun_ajaran']);
        });

        Schema::create('nilais', function (Blueprint $table) {
            $table->id();
            $table->foreignId('krs_id')->unique()->constrained('krs')->cascadeOnDelete();
            $table->decimal('nilai_angka', 5, 2);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('nilais');
        Schema::dropIfExists('krs');
        Schema::dropIfExists('jadwals');
        Schema::dropIfExists('mata_kuliahs');
        Schema::dropIfExists('mahasiswas');
    }
};
