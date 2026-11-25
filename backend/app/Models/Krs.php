<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Krs extends Model
{
    /** Periode aktif untuk pengisian KRS (sederhana: konstanta). */
    public const TAHUN_AJARAN = '2026/2027-Ganjil';

    /** Batas maksimal SKS per semester. */
    public const MAKS_SKS = 24;

    protected $table = 'krs';

    protected $fillable = ['mahasiswa_id', 'jadwal_id', 'tahun_ajaran'];

    public function mahasiswa(): BelongsTo
    {
        return $this->belongsTo(Mahasiswa::class);
    }

    public function jadwal(): BelongsTo
    {
        return $this->belongsTo(Jadwal::class);
    }

    public function nilai(): HasOne
    {
        return $this->hasOne(Nilai::class);
    }
}
