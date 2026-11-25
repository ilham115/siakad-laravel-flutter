<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Presensi extends Model
{
    protected $table = 'presensis';

    protected $fillable = ['presensi_sesi_id', 'krs_id'];

    public function sesi(): BelongsTo
    {
        return $this->belongsTo(PresensiSesi::class, 'presensi_sesi_id');
    }

    public function krs(): BelongsTo
    {
        return $this->belongsTo(Krs::class);
    }
}
