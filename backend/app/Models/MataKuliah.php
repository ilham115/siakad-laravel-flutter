<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MataKuliah extends Model
{
    protected $table = 'mata_kuliahs';

    protected $fillable = ['kode', 'nama', 'sks', 'semester'];

    public function jadwals(): HasMany
    {
        return $this->hasMany(Jadwal::class);
    }
}
