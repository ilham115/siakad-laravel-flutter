<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('jadwals', function (Blueprint $table) {
            // Pemilik kelas = akun dosen (users.role = 'dosen')
            $table->foreignId('dosen_id')->nullable()->after('tahun_ajaran')
                ->constrained('users')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('jadwals', function (Blueprint $table) {
            $table->dropConstrainedForeignId('dosen_id');
        });
    }
};
