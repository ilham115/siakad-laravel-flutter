<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PresensiSesi extends Model
{
    protected $table = 'presensi_sesis';

    protected $fillable = ['jadwal_id', 'pertemuan_ke', 'kode', 'berlaku_sampai'];

    protected function casts(): array
    {
        return ['berlaku_sampai' => 'datetime'];
    }

    public function jadwal(): BelongsTo
    {
        return $this->belongsTo(Jadwal::class);
    }

    public function presensis(): HasMany
    {
        return $this->hasMany(Presensi::class);
    }
}
