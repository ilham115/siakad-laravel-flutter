<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Mahasiswa extends Model
{
    protected $table = 'mahasiswas';

    protected $fillable = ['user_id', 'nim', 'prodi', 'angkatan', 'semester_aktif'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function krs(): HasMany
    {
        return $this->hasMany(Krs::class);
    }
}
